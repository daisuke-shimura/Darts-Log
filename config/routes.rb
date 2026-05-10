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
    get  :count_up, to: 'games/count_ups#show'
    post :count_up, to: 'games/count_ups#create'
    get  :center_count_up, to: 'games/center_count_ups#show'
    post :center_count_up, to: 'games/center_count_ups#create'
  end
  namespace :games do
    resources :zero_ones, only: [:new]
    resources :crickets, only: [:new]
    resources :count_ups, only: [:new]
    resources :center_count_ups, only: [:new]
  end

  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
