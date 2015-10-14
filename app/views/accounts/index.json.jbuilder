json.array!(@accounts) do |account|
  json.extract! account, :id, :name, :setup, :account_type, :email
  json.url account_url(account, format: :json)
end
