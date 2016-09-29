object false

child :@clusters => :clusters do
  collection :@clusters
  extends 'api/v2/reports/_cluster'
end

child :@reports => :reports do
  collection :@reports
  extends 'api/v2/reports/_report'
end
