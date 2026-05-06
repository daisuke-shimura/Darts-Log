Rails.application.routes.draw do
  get 'games/index'
  root to: 'homes#top'
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :records, only: [:index, :create]
  resources :logs, only: [:index]

  resources :games, only: [:index, :create] do
    get  :zero_one, to: 'games/zero_ones#show'
    post :zero_one, to: 'games/zero_ones#create'
    get  :cricket,  to: 'games/crickets#show'
    post :cricket,  to: 'games/crickets#create'
  end
  namespace :games do
    resources :zero_ones, only: [:new]
    resources :crickets, only: [:new]
  end

  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
