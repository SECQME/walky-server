class RemoveUserIdStringFromReports < ActiveRecord::Migration
  def change
    remove_column :reports, :user_id_string, :string
  end
end
