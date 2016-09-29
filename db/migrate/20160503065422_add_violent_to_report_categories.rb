class AddViolentToReportCategories < ActiveRecord::Migration
  def up
    add_column :report_categories, :violent, :boolean, default: false

    ReportCategory.find_by(name: 'Gun violence').update!(violent: true)
    ReportCategory.find_by(name: 'Rape').update!(violent: true)
    ReportCategory.find_by(name: 'Assault').update!(violent: true)
  end

  def down
    remove_column :report_categories, :violent
  end
end
