class CreateReportCategories < ActiveRecord::Migration
  def change
    create_table :report_categories do |t|
      t.string :name
      t.string :group_name
      t.string :description
      t.float :weight
      t.string :display_name

      t.timestamps null: false
    end
  end
end
