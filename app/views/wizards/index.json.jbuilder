json.array!(@wizards) do |wizard|
  json.extract! wizard, :id, :name, :account_id
  json.url wizard_url(wizard, format: :json)
end
