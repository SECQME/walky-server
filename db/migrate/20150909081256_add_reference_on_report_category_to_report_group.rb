class AddReferenceOnReportCategoryToReportGroup < ActiveRecord::Migration
  def change
  	add_column :report_categories, :report_group_id, :integer
  end
end
