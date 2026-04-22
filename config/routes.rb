Rails.application.routes.draw do
  root to: 'homes#top'
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :records, only: [:index, :create]
  resources :logs, only: [:index]

  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'target', to: 'records#target'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
