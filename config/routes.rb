Rails.application.routes.draw do
  get "home/index"
  devise_for :users

  root "home#index" 

  resources :check_ins
  resources :bookings
  resources :statuses
  resources :rooms
  resources :users

  namespace :api do
    get "check_ins/create"
    resources :rooms, only: [:index, :show]
    resources :bookings, only: [:index, :create, :show, :destroy] do
      member do
        get 'generate_qr'
      end
    end
    resources :check_ins, only: [:create]
  end
end
