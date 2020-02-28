Rails.application.routes.draw do
  resources :line_items
  resources :carts
  get '/my_cart', to: 'carts#index', as: "my_cart"
  root 'store#index', as: 'store_index'
  resources :products
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
