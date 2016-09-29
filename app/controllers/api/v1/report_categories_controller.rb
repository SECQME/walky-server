class Api::V1::ReportCategoriesController < BaseApiController
	respond_to :json

	def index
		@report_categories = ReportGroup.all.includes(:report_categories)
		respond_with(@report_categories)
	end
end
