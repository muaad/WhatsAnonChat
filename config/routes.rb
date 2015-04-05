Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :chats

  post "incoming" => "commands#incoming"
  # post "/help" => "commands#help", as: "help"
  # post "/invite" => "commands#invite", as: "invite"
  # post "/search" => "commands#search", as: "search"
  # post "/friends" => "commands#friends", as: "friends"
  # post "/spin" => "commands#spin", as: "spin"

  get 'commands/outgoing'

  resources :contacts

  root to: 'visitors#index'
  devise_for :users
end
