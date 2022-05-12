WechatVendorPlatformProxy::Engine.routes.draw do
  get 'welcome/index'
  root 'welcome#index'

  resources :wallet_transfers, only: [:show, :create] do
  end

  resources :bank_transfers, only: [:show, :create] do
  end

  namespace :business_coupon do
    resources :wxpay_callback_events, only: [:create]
  end

  namespace :capital do
    resources :personal_banks, only: [:index]
    resources :corporate_banks, only: [:index]
  end
end
