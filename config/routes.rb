Rails.application.routes.draw do
  get 'games/index'
  root to: 'homes#top'
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :records, only: [:index, :create]
  resources :logs, only: [:index]

  resources :games, only: [:index, :create]
  namespace :games do
    resources :crickets, only: [:new, :index, :create]
    resources :zero_ones, only: [:new, :index, :create]
  end
  get 'games/:id/zero_one', to: 'games/zero_ones#show', as: :games_zero_one
  get 'games/:id/cricket',  to: 'games/crickets#show',  as: :games_cricket

  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
