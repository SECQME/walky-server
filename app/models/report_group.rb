class ReportGroup < ActiveRecord::Base
	has_many :report_categories
end
