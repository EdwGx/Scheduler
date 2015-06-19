Rails.application.routes.draw do
  root 'home#index'

  devise_for :users

  get '/users/:id' => 'home#show', as: :user

  #get '/tournaments/:id', to: redirect('/tournaments/:id/matches')
  post '/tournaments/generate' => 'tournaments#auto_generate'
  resources :tournaments, only: [:show, :new, :create, :destroy] do
    resources :matches, only: [:show, :new, :create, :edit, :update, :destroy]
    get '/calendar' => 'tournaments#calendar'
    post '/calendar' => 'tournaments#update_calendar'
    post '/send' => 'tournaments#send_schedule'
  end


  resources :teams, only: [:show, :new, :create, :destroy] do
    resources :players, except: [:index, :show] do
      post '/verify' => 'players#verify'
    end

    post '/reg_toggle' => 'teams#toggle_registration'
    post '/email' => 'teams#email', as: :email

    get '/form/edit' => 'registration_forms#edit', as: :add_form
    post '/form/edit' => 'registration_forms#update'

    get '/form/edit/:info_id' => 'registration_forms#edit', as: :edit_form
    post '/form/edit/:info_id' => 'registration_forms#update'
    delete '/form/edit/:info_id' => 'registration_forms#destroy'

  end

  resources :fields, except: [:index] do
    put '/schedule' => 'fields#update_schedule'
    resources :timeslots, except: [:index]
  end

  post '/import' => 'home#xlsx_import'
  get '/test' => 'home#test'

  get  '/register/:token' => 'teams#registration_form', as: :register
  post '/register/:token' => 'teams#registration_submit'

  post '/tournaments/:tournament_id/team/add' => 'tournaments#add_team'
  get '/tournaments/:tournament_id/team/:type' => 'tournaments#edit_teams', as: :edit_tournament_team
  post '/tournaments/:tournament_id/team/:type' => 'tournaments#update_teams'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
