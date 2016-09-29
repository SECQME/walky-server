require 'spec_helper'

describe Api::V2::ReportsController, type: :controller do
  # before(:all) do
  #   RecentReport.refresh
  # end

  describe 'GET #index' do
    context 'in Chicago city' do
      context 'with zoom level 9' do
        let(:zoom_level) { 9 }
        before do
          get :index, format: :json, zoom_level: zoom_level, bounds: '40.884314,-87.651581|41.891023,-87.641453'
        end

        it { is_expected.to respond_with 200 }
        it 'has empty reports' do
          expect(json_response).to include(reports: [])
        end
        it 'has maximum 12 clusters' do
          expect(json_response[:clusters].size).to be <= 12
        end
        it 'has clusters with null violent' do
          expect(json_response[:clusters]).to all(include(violent: nil))
        end
      end

      context 'with zoom level 14' do
        let(:zoom_level) { 14 }
        before do
          get :index, format: :json, zoom_level: zoom_level, bounds: '40.884314,-87.651581|41.891023,-87.641453'
        end

        it { is_expected.to respond_with 200 }
        it 'has empty reports' do
          expect(json_response).to include(reports: [])
        end
        it 'has maximum 16 clusters' do
          expect(json_response[:clusters].size).to be <= 16
        end
        it 'has no clusters with null violent' do
          expect(json_response[:clusters]).not_to include(include(violent: nil))
        end
      end

      context 'with zoom level 17' do
        let(:zoom_level) { 17 }
        before do
          get :index, format: :json, zoom_level: zoom_level, bounds: '40.884314,-87.651581|41.891023,-87.641453'
        end

        it { is_expected.to respond_with 200 }
        it 'sets the proper pagination headers' do
          expect(response.headers['X-Per-Page'].to_i).to be >= 0
          expect(response.headers['X-Total'].to_i).to be >= 0
        end

        it 'has maximum 25 reports' do
          expect(json_response[:reports].size).to be <= 25
        end
        it 'has empty clusters' do
          expect(json_response).to include(clusters: [])
        end
      end
    end
  end
end
