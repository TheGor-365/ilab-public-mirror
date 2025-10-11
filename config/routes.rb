Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  resources :owned_gadgets do
    resources :images, only: [ :create, :destroy ]
  end

  resources :categories do
    resources :images, only: [ :create, :destroy ]
  end

  resources :products do
    resources :images, only: [ :create, :destroy ]
    member do
      get :product_description
    end
    collection do
      get :catalog_tree     # JSON: SKU/опции/чекбоксы
      get :catalog_phones   # JSON: автокомплит/полный список моделей
    end
  end

  resources :universities do
    resources :images, only: [ :create, :destroy ]
  end
  resources :quizzes do
    resources :images, only: [ :create, :destroy ]
  end
  resources :answers do
    resources :images, only: [ :create, :destroy ]
  end
  resources :quiz_questions do
    resources :images, only: [ :create, :destroy ]
  end
  resources :cources do
    resources :images, only: [ :create, :destroy ]
  end
  resources :chapters do
    resources :images, only: [ :create, :destroy ]
  end
  resources :posts do
    resources :images, only: [ :create, :destroy ]
  end
  resources :articles do
    resources :images, only: [ :create, :destroy ]
  end
  resources :order_items, only: [ :create, :update, :update_all, :destroy, :destroy_all ] do
    resources :images, only: [ :create, :destroy ]
    collection do
      delete :destroy_all
    end
  end
  resources :generations do
    resources :images, only: [ :create, :destroy ]
  end
  resources :models do
    resources :images, only: [ :create, :destroy ]
  end
  resources :mods do
    resources :images, only: [ :create, :destroy ]
  end
  resources :spare_parts do
    resources :images, only: [ :create, :destroy ]
  end
  resources :repairs do
    resources :images, only: [ :create, :destroy ]
  end
  resources :defects do
    resources :images, only: [ :create, :destroy ]
  end
  resources :phones do
    resources :images, only: [ :create, :destroy ]
  end
  resources :apple_watches do
    resources :images, only: [ :create, :destroy ]
  end
  resources :airpods do
    resources :images, only: [ :create, :destroy ]
  end
  resources :ipads do
    resources :images, only: [ :create, :destroy ]
  end
  resources :imacs do
    resources :images, only: [ :create, :destroy ]
  end
  resources :makbooks do
    resources :images, only: [ :create, :destroy ]
  end

  namespace :admin do
    resources :products
    namespace :catalog do
      get :families
      get :generations
      get :options
      get :models
    end
  end

  delete 'cart', to: 'order_items#destroy_all'
  post   'cart', to: 'order_items#update_all'
  match 'cart',  to: 'cart#show', via: [ :get, :post ]
  match 'store', to: 'pages#store', via: [ :get, :post ]

  get 'terms',    to: 'pages#terms',    as: 'terms'
  get 'contacts', to: 'pages#contacts', as: 'contacts'

  get   'profiles/:username',              to: 'profiles#profile',      as: 'account'
  get   'profiles/:username/edit_profile', to: 'profiles#edit_profile', as: 'edit_account'
  patch 'profiles/:username',              to: 'profiles#update'

  get 'phones/phone_title/:id',    to: 'phones#phone_title',    as: 'phone_title'
  get 'phones/phone_image/:id',    to: 'phones#phone_image',    as: 'phone_photo'
  get 'phones/phone_video/:id',    to: 'phones#phone_video',    as: 'phone_video'
  get 'phones/phone_overview/:id', to: 'phones#phone_overview', as: 'phone_overview'

  get 'phones_block', to: 'phones#phones_block', as: 'phones_block'
  get 'phones_table', to: 'phones#phones_table', as: 'phones_table'

  get 'edit_phone_generation/:id/edit',     to: 'phones#edit_phone_generation',     as: 'edit_phone_generation'
  get 'edit_phone_title/:id/edit',          to: 'phones#edit_phone_title',          as: 'edit_phone_title'
  get 'edit_phone_avatar/:id/edit',         to: 'phones#edit_phone_avatar',         as: 'edit_phone_avatar'
  get 'edit_phone_images/:id/edit',         to: 'phones#edit_phone_images',         as: 'edit_phone_images'
  get 'add_more_phone_images/:id/edit',     to: 'phones#add_more_phone_images',     as: 'add_more_phone_images'
  get 'delete_phone_images/:id/edit',       to: 'phones#delete_phone_images',       as: 'delete_phone_images'
  get 'edit_phone_model_overview/:id/edit', to: 'phones#edit_phone_model_overview', as: 'edit_phone_model_overview'
  get 'edit_phone_videos/:id/edit',         to: 'phones#edit_phone_videos',         as: 'edit_phone_videos'

  get 'phones/new_phone_generation/new',     to: 'phones#new_phone_generation',     as: 'new_phone_generation'
  get 'phones/new_phone_title/new',          to: 'phones#new_phone_title',          as: 'new_phone_title'
  get 'phones/new_phone_avatar/new',         to: 'phones#new_phone_avatar',         as: 'new_phone_avatar'
  get 'phones/new_phone_images/new',         to: 'phones#new_phone_images',         as: 'new_phone_images'
  get 'phones/new_phone_model_overview/new', to: 'phones#new_phone_model_overview', as: 'new_phone_model_overview'
  get 'phones/new_phone_videos/new',         to: 'phones#new_phone_videos',         as: 'new_phone_videos'

  get 'generations/generation_title/:id',             to: 'generations#generation_title',             as: 'generation_title'
  get 'generations/generation_production_period/:id', to: 'generations#generation_production_period', as: 'generation_production_period'
  get 'generations/generation_features/:id',          to: 'generations#generation_features',          as: 'generation_features'
  get 'generations/generation_vulnerability/:id',     to: 'generations#generation_vulnerability',     as: 'generation_vulnerability'
  get 'generations/generation_image/:id',             to: 'generations#generation_image',             as: 'generation_photo'
  get 'generations/generation_video/:id',             to: 'generations#generation_video',             as: 'generation_video'

  get 'generations_block', to: 'generations#generations_block', as: 'generations_block'
  get 'generations_table', to: 'generations#generations_table', as: 'generations_table'

  get 'edit_generation_title/:id/edit',                  to: 'generations#edit_generation_title',                  as: 'edit_generation_title'
  get 'edit_generation_videos/:id/edit',                 to: 'generations#edit_generation_videos',                 as: 'edit_generation_videos'
  get 'edit_generation_images/:id/edit',                 to: 'generations#edit_generation_images',                 as: 'edit_generation_images'
  get 'edit_generation_avatar/:id/edit',                 to: 'generations#edit_generation_avatar',                 as: 'edit_generation_avatar'
  get 'edit_generation_production_period/:id/edit',      to: 'generations#edit_generation_production_period',      as: 'edit_generation_production_period'
  get 'edit_generation_vulnerability/:id/edit',          to: 'generations#edit_generation_vulnerability',          as: 'edit_generation_vulnerability'
  get 'edit_generation_features/:id/edit',               to: 'generations#edit_generation_features',               as: 'edit_generation_features'
  get 'add_more_generation_images/:id/edit',             to: 'generations#add_more_generation_images',             as: 'add_more_generation_images'
  get 'add_more_generation_videos/:id/edit',             to: 'generations#add_more_generation_videos',             as: 'add_more_generation_videos'
  get 'change_generation_images/:id/edit',               to: 'generations#change_generation_images',               as: 'change_generation_images'
  get 'change_generation_videos/:id/edit',               to: 'generations#change_generation_videos',               as: 'change_generation_videos'
  get 'delete_generation_images/:id/edit',               to: 'generations#delete_generation_images',               as: 'delete_generation_images'

  get 'generations/new_generation_title/new',              to: 'generations#new_generation_title',              as: 'new_generation_title'
  get 'generations/new_generation_avatar/new',             to: 'generations#new_generation_avatar',             as: 'new_generation_avatar'
  get 'generations/new_generation_images/new',             to: 'generations#new_generation_images',             as: 'new_generation_images'
  get 'generations/new_generation_videos/new',             to: 'generations#new_generation_videos',             as: 'new_generation_videos'
  get 'generations/new_generation_production_period/new',  to: 'generations#new_generation_production_period',  as: 'new_generation_production_period'
  get 'generations/new_generation_features/new',           to: 'generations#new_generation_features',           as: 'new_generation_features'
  get 'generations/new_generation_vulnerability/new',      to: 'generations#new_generation_vulnerability',      as: 'new_generation_vulnerability'

  get 'video_recordings', to: 'video_recordings#new', as: 'video_recordings'
end
