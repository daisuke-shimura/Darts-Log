Rails.application.routes.draw do
  get 'games/index'
  root to: 'homes#top'
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :records, only: [:index, :create]

  resources :games, only: [:index, :create] do
    get  :zero_one, to: 'games/zero_ones#show'
    post :zero_one, to: 'games/zero_ones#create'
    get  :cricket,  to: 'games/crickets#show'
    post :cricket,  to: 'games/crickets#create'
    get  :count_up, to: 'games/count_ups#show'
    post :count_up, to: 'games/count_ups#create'
    get  :center_count_up, to: 'games/center_count_ups#show'
    post :center_count_up, to: 'games/center_count_ups#create'
    get  :cricket_count_up, to: 'games/cricket_count_ups#show'
    post :cricket_count_up, to: 'games/cricket_count_ups#create'
    get  :shoot_out, to: 'games/shoot_outs#show'
    post :shoot_out, to: 'games/shoot_outs#create'
  end
  namespace :games do
    resources :zero_ones, only: [:new]
    resources :crickets, only: [:new]
    resources :count_ups, only: [:new]
    resources :center_count_ups, only: [:new]
    resources :cricket_count_ups, only: [:new]
    resources :shoot_outs, only: [:new]
  end

  resources :logs, only: [:index]
  get 'logs/line_graph', to: 'logs#line_graph'
  get 'logs/histogram', to: 'logs#histogram'
  get 'logs/cumulative', to: 'logs#cumulative'
  get 'logs/rayleigh', to: 'logs#rayleigh'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
