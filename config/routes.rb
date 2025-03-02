Rails.application.routes.draw do
  devise_for :users

  root "bookings#index"

  resources :check_ins
  resources :bookings
  resources :statuses
  resources :rooms
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  namespace :api do
    get "check_ins/create"
    get "bookings/index"
    get "bookings/create"
    get "bookings/show"
    get "bookings/destroy"
    get "rooms/index"
    get "rooms/show"
    resources :rooms, only: [:index, :show]
    resources :bookings, only: [:index, :create, :show, :destroy] do
      member do
        get 'generate_qr'
      end
    end
    resources :check_ins, only: [:create]
  end
end
