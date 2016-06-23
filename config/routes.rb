Chessapp::Application.routes.draw do
  devise_for :players
  
  root 'static_pages#index'
  
  resources :games, except: [:index, :new, :edit, :destroy] do
    resources :pieces, only: :update
  end
end
