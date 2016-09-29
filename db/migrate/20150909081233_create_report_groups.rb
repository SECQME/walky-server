class CreateReportGroups < ActiveRecord::Migration
  def change
    create_table :report_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
