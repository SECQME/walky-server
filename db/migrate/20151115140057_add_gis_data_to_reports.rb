class AddGisDataToReports < ActiveRecord::Migration

  def change
    change_table :reports do |t|
      t.st_point :location, geographic: true
    end

    add_index :reports, :location, using: :gist
  end
end
