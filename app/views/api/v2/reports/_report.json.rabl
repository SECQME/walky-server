object :@report

attributes :source_type, :id, :description, :report_time, :report_category_id, :latitude, :longitude, :street_name, :city, :state, :country, :postcode

child(:report_category) do
  extends('api/v1/report_categories/show')
end

node(:user) do |report|
  # { city: user.city, address: partial('users/address', object: m.address) }
  if report.user
    partial('api/v1/users/_object', object: report.user)
  else
    { id: 0, display_name: "walky" }
  end
end
