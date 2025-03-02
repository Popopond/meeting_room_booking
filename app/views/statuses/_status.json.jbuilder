json.extract! status, :id, :status_name, :created_at, :updated_at
json.url status_url(status, format: :json)
