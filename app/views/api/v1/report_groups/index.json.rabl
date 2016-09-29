collection :@report_groups
extends("api/v1/report_groups/_object")

child(:report_categories) do
  extends("api/v1/report_categories/_object")
end
