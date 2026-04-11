Rails.application.routes.draw do
  root to: 'homes#top'
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :records, only: [:index]
  resources :logs, only: [:index]

  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
