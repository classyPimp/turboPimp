Rails.application.routes.draw do
  
  scope "api" do
    post "users/current_user" => "users#expose_current_user"  
    # BASIC AUTH
    get "sign_up" => "users#new"
    resources :users, except: [:new]
    get    'login'  => 'sessions#new'
    post   'login'  => 'sessions#create'
    delete 'logout' => 'sessions#destroy'
    #ACCOUNT ACTIVATION
    resources :account_activations, only: [:edit]
    #PASSWORD RESETS
    resources :password_resets, only: [:new, :create, :edit, :update]
  # END BASIC AUTH

    resources :pages

    resources :images 

    resources :menu_items, only: [:index, :update]

    resources :roles, only: [:index]  

    resources :chat_messages

    get "restricted_asset" => "faker#restricted_asset" 

    post "users/roles_feed" => "users#roles_feed"


    delete 'users/destroy_unregistered_user_with_proposals/:id' => 'users#destroy_unregistered_user_with_proposals'
    namespace :admin do
      resources :users
      resources :pages
    end

    namespace :blogger do
      get "blogs/last_ten" => "blogs#last_ten"
      put "blogs/toggle_published" => "blogs#toggle_published"
      resources :blogs
    end

    resources :blogs, only: [:index, :create, :update, :destroy, :edit]

    resources :appointments
    resources :appointment_availabilities

    post "doctor/users/doctors_feed" => "doctor/users#doctors_feed"
    
    namespace :doctor do
      resources :appointments
    end


    post 'appointment_scheduler/appointments/schedule_from_proposal' => 'appointment_scheduler/appointments#schedule_from_proposal'
    get 'appointment_scheduler/appointments/proposal_index' => 'appointment_scheduler/appointments#proposal_index'
    namespace :appointment_scheduler do
      resources :appointments
      resources :users
      resources :chat_messages
    end


    post "patients/patients_feed" => "patients#patients_feed"

  end

  get "/console" => "faker#console"
  root "faker#home"
  post "api/test" => "faker#test"
  get "/*path" => "faker#home"
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
