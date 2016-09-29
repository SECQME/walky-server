class AddUserAndInvisibleInformationToReports < ActiveRecord::Migration
  def change
    add_column :reports, :invisible, :boolean, default: false
    add_column :reports, :user_id_string, :string
    add_column :reports, :user_id, :integer
  end
end
