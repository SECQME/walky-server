class CreateFeaturesUsers < ActiveRecord::Migration
  def change
    create_table :features_users do |t|
      t.belongs_to :features
      t.belongs_to :users
      t.timestamps null: false
    end
  end
end
