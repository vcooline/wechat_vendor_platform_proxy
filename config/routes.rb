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
    concern :with_branches do
      resources :bank_branches, only: [:index]
    end

    resources :personal_banks, param: :bank_alias_code, only: [:index], concerns: [:with_branches]
    resources :corporate_banks, param: :bank_alias_code, only: [:index], concerns: [:with_branches]
  end
end
