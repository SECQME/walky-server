class CreateExternalAuths < ActiveRecord::Migration
  def change
    create_table :external_auths do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider
      t.string :uid

      t.timestamps null: false
    end
    
    add_index :external_auths, [:user_id, :provider], :unique => true
    add_index :external_auths, [:provider, :uid], :unique => true
  end
end
