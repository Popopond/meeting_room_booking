Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "sessions",
    registrations: "registrations"
  }

  root "home#index"

  resources :check_ins
  resources :bookings do
    member do
      delete :cancel
      post :add_participant
      delete :remove_participant
    end
  end
  resources :statuses
  resources :rooms
  resources :users

  namespace :api do
    get "check_ins/create"
    resources :rooms, only: [ :index, :show ]
    resources :bookings, only: [ :index, :create, :show, :destroy ] do
      member do
        get "generate_qr"
      end
    end
    resources :check_ins, only: [ :create ]
  end
end
