object :@report_category

extends('api/v1/report_categories/_object')
child(:report_group) do
  extends('api/v1/report_groups/_object')
end
