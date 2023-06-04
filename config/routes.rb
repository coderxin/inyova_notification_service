# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post :sessions, to: 'sessions#create'
      delete :sessions, to: 'sessions#destroy'

      resources :notifications, only: [:index, :show]
    end
  end
end
