class CrimeType < ActiveRecord::Base
  belongs_to :report_category
end
