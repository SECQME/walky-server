class Api::V1::ReportGroupsController < BaseApiController
	respond_to :json

	def index
		@report_groups = ReportGroup.all.includes(:report_categories)
		respond_with(@report_groups)
	end
end
