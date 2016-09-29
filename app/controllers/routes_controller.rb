class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  respond_to :json

  def index
    @routes = route.all
    respond_with(@routes)
  end

  def show
    respond_with(@route)
  end

  def new
    @route = route.new
    respond_with(@route)
  end

  def edit
  end

  def create
    @route = route.new(route_params)
    @route.save
    respond_with(@route)
  end

  def update
    @route.update(route_params)
    respond_with(@route)
  end

  def destroy
    @route.destroy
    respond_with(@route)
  end

  private
    def set_route
      @route = route.find(params[:id])
    end

    def route_params
      params.require(:route).permit(:start_point, :end_point, :route_response, :crime_day_time)
    end
end
