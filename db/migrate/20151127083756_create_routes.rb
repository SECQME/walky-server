class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.st_point  :start_point, geographic: true
      t.st_point  :end_point, geographic: true
      t.jsonb     :route_response, default: {}
      t.integer   :crime_day_time

      t.timestamps null: false
    end

    add_index :routes, :start_point, using: :gist
    add_index :routes, :end_point, using: :gist
    add_index :routes, :route_response, using: :gin
  end
end