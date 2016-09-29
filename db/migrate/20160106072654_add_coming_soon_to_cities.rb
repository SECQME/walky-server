class AddComingSoonToCities < ActiveRecord::Migration
  def up
    add_column :cities, :coming_soon, :boolean, default: true
    City.update_all(coming_soon: false)
  end

  def down
    remove_column :cities, :coming_soon
  end
end
