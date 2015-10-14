Rails.application.routes.draw do

  resources :accounts

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "contacts#new", :as => "signup"

  get "contacts/:id/verification" => "contacts#verification", :as => "verification"
  post "contacts/:id/verify" => "contacts#verify", as: "verify"

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

  get "contacts/:auth_token/friends" => "contacts#friends", :as => "friends"

  match 'bots/updates', to: 'telegram#handle_updates', as: 'handle_updates', via: 'post'

  resources :contacts

  root to: 'home#index'
  devise_for :users
end
