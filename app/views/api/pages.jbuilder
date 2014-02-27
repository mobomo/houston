json.array! @pages do |page|
  json.(page, :id, :parent_id, :title, :space, :url, :version)
end