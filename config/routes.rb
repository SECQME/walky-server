Rails.application.routes.draw do

  devise_for :users
  resources :saferstreets_report do
  end
  resources :safe_direction
  resources :routes
  resources :profiler

  api_version(:module => "Api::V1", :path => {:value => "v1"}, :defaults => {:format => :json}) do
    match 'auth/:provider', to: 'sessions#external', via: :post
    resources :crime_data, only: [:index]
    resources :cities, only: [:index]
    resources :features do
      post 'vote', on: :member
    end
    # resources :directions do
    #   get 'routes', on: :collection
    # end

    match 'directions/routes', to: 'routing#routes', via: :get

    resources :routing do
      get 'routes', on: :collection
    end

    resources :report_categories, only: [:index]
    resources :report_groups, only: [:index]
    resources :reports, only: [:index, :create]
    resources :sessions do
      post 'external/:provider', on: :collection, action: :external
    end
    resources :tips, only: [:index, :create]
    match 'heartbeat', to: 'reports#heartbeat', via: :get
    match 'env', to: 'reports#env', via: :get
    resources :users do
      get 'me', on: :collection, action: :show_me
      put 'me', on: :collection, action: :update_me
    end
  end

  api_version(:module => "Api::V2", :path => {:value => "v2"}, :defaults => {:format => :json}) do
    resources :reports, only: [:index, :create]
  end
end
