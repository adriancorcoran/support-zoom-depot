# frozen_string_literal: true

Rails.application.routes.draw do
  get 'services/ping', to: 'shopify_cloud/ping#ping'
  get 'services/status', to: 'shopify_cloud/status#status'
end
