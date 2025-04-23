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
      post :check_in
    end
  end
  resources :statuses
  resources :rooms do
    resource :qr_code, controller: "room_qr_codes", only: [ :show ]
    get "qr_code/image", to: "room_qr_codes#image", as: "qr_code_image"
  end
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
