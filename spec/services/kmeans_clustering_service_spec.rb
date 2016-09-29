require 'spec_helper'

describe KmeansClusteringService do
  let(:bounding_box) { { south_west: { lat: 41.92793, lng: -87.72774 }, north_east: { lat: 41.92689, lng: -87.72476 } } }
  let(:clustering_service) { KmeansClusteringService.new bounding_box }
  subject { clustering_service }

  it { is_expected.to respond_to(:bounding_box) }

  describe '#clusters' do
    context 'no partition' do
      let(:num_cluster) { 4 }

      it 'should query database without PARTITION BY' do
        connection = double('Connection')
        expect(ActiveRecord::Base).to receive(:connection) { connection }
        expect(connection).to receive(:execute).with(%Q{
      SELECT kmeans, COUNT(*) AS total, ST_Centroid(ST_Collect(location::GEOMETRY)) AS centroid
      FROM (
        SELECT kmeans(ARRAY[longitude, latitude], #{num_cluster}) OVER (), location
        FROM (
          SELECT location, latitude, longitude
          FROM #{RecentReport.table_name}
          WHERE location && ST_MakeEnvelope(-87.72774, 41.92793, -87.72476, 41.92689, 4326)
        ) cd
      ) ksub
      GROUP BY kmeans
      ORDER BY kmeans;
    }) { [] }
        clustering_service.clusters(num_cluster)
      end

      it 'should return no more than specified clusters' do
        expect(clustering_service.clusters(num_cluster).size).to be <= num_cluster
      end
    end

    context 'with violent partition' do
      it 'should query database with PARTITION BY violent' do
        connection = double('Connection')
        expect(ActiveRecord::Base).to receive(:connection) { connection }
        expect(connection).to receive(:execute).with(%Q{
      SELECT violent, kmeans, COUNT(*) AS total, ST_Centroid(ST_Collect(location::GEOMETRY)) AS centroid
      FROM (
        SELECT kmeans(ARRAY[longitude, latitude], 4) OVER (PARTITION BY violent), location, violent
        FROM (
          SELECT location, latitude, longitude, violent
          FROM #{RecentReport.table_name}
          WHERE location && ST_MakeEnvelope(-87.72774, 41.92793, -87.72476, 41.92689, 4326)
        ) cd
      ) ksub
      GROUP BY violent, kmeans
      ORDER BY violent, kmeans;
    }) { [] }
        clustering_service.clusters(4, 'violent')
      end

      it 'should return no more than double of specified clusters' do
        expect(clustering_service.clusters(4).size).to be <= 8
      end
    end
  end
end
