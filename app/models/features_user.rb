class FeaturesUser < ActiveRecord::Base
  has_many :features
  has_many :users
end
