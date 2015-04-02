Rails.application.routes.draw do
  post "incoming" => "commands#incoming"

  get 'commands/outgoing'

  resources :contacts

  root to: 'visitors#index'
  devise_for :users
end
