# frozen_string_literal: true
Rails.application.routes.draw do
  scope '(:locale)' do
    # admin
    get 'admin', to: 'admin#index'

    # session / login
    controller :sessions do
      get 'login' => :new
      post 'login' => :create
      get 'logout' => :destroy
      delete 'logout' => :destroy
    end

    # models
    resources :users
    resources :products do
      get :who_bought, on: :member
    end
    resources :orders
    resources :line_items
    resources :carts
    # custom
    get '/my_cart', to: 'carts#index', as: "my_cart"

    root 'store#index', as: 'store_index'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
