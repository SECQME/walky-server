class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :description
      t.datetime :report_time
      t.references :report_category
      t.float :latitude
      t.float :longitude
      t.string :street_name
      t.string :city
      t.string :state
      t.string :country
      t.string :postcode

      t.timestamps null: false
    end
  end
end
