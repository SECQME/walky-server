class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.references :user, index: true, foreign_key: true
      t.string :access_token
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :api_keys, :access_token, unique: true
    add_index :api_keys, :deleted_at
  end
end
