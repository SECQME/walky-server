object @report

extends('api/v1/reports/_object')
child(:report_category) do
  extends('api/v1/report_categories/show')
end
child(:user) do
  extends('api/v1/users/_object')
end
