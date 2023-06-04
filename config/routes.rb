# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post :sessions, to: 'sessions#create'
      delete :sessions, to: 'sessions#destroy'

      resources :notifications, only: [:index, :show]

      namespace :admin do
        resources :notifications, only: [:index, :show, :create] do
          scope module: 'notifications' do
            resources :assignments, only: [:index, :create]
          end
        end
      end
    end
  end
end
