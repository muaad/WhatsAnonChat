json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :phone_number, :gender, :age, :country, :username, :opted_id
  json.url contact_url(contact, format: :json)
end
