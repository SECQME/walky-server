class ExternalAuth < ActiveRecord::Base
  belongs_to :user  
  validates_uniqueness_of :provider, scope: :user_id
  validates_uniqueness_of :uid, scope: :provider
end
