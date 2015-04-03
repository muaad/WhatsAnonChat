json.array!(@chats) do |chat|
  json.extract! chat, :id, :contact_id, :friend_id, :active
  json.url chat_url(chat, format: :json)
end
