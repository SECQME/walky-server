class AddPhotoToTips < ActiveRecord::Migration
  def change
    add_column :tips, :photo_id, :string
  end
end
