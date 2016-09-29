class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :name
      t.string :description
      t.integer :total_votes
      t.boolean :completed, default: false
      t.boolean :archived, default: false
      t.boolean :notified, default: false
      t.timestamps null: false
    end
  end
end
