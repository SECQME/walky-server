require 'spec_helper'

describe EdgeBasedRouteEngine do
  context 'in Chicago' do
    # let(:route_engine) { EdgeBasedRouteEngine.new 41.92957, -87.64600, 41.90331, -87.71428, EdgeBasedRouteEngine::DAYTIME }
    let(:route_engine) { EdgeBasedRouteEngine.new 41.92793, -87.72774, 41.92689, -87.72476, EdgeBasedRouteEngine::DAYTIME }

    subject { route_engine }

    it { is_expected.to respond_to(:origin_lat) }
    it { is_expected.to respond_to(:origin_lng) }
    it { is_expected.to respond_to(:origin_edge) }
    it { is_expected.to respond_to(:destination_lat) }
    it { is_expected.to respond_to(:destination_lng) }
    it { is_expected.to respond_to(:destination_edge) }
    it { is_expected.to respond_to(:route) }

    it 'should have route start with from origin_edge' do
      route = route_engine.route
      expect(route.first).to eq(route_engine.origin_edge)
    end

    it 'should have route end in destination_edge' do
      route = route_engine.route
      expect(route.last).to eq(route_engine.destination_edge)
    end
  end
end
