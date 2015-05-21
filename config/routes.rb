Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :chats
  resources :sessions

  post "incoming" => "commands#incoming"
  # post "/help" => "commands#help", as: "help"
  # post "/invite" => "commands#invite", as: "invite"
  # post "/search" => "commands#search", as: "search"
  # post "/friends" => "commands#friends", as: "friends"
  # post "/spin" => "commands#spin", as: "spin"

  get 'commands/outgoing'

  post "/send_message" => "chats#send_message", as: "send_message"
  post "/send_image" => "chats#send_image", as: "send_image"

  resources :contacts

  root to: 'visitors#index'
  devise_for :users
end
