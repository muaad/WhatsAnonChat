Rails.application.routes.draw do
  post "incoming" => "commands#incoming"
  post "/help" => "commands#help", as: "help"
  post "/invite" => "commands#invite", as: "invite"

  get 'commands/outgoing'

  resources :contacts

  root to: 'visitors#index'
  devise_for :users
end
