class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.text :description, limit: 255
      t.st_point :location, geographic: true
      t.string :username
      t.string :user_id
      t.boolean :archived
      t.boolean :is_time_sensitive
      t.datetime :expiry_date
      t.timestamps null: false
    end

    add_index :tips, :location, using: :gist
  end
end
