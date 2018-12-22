WechatVendorPlatformProxy::Engine.routes.draw do
  get 'welcome/index'
  root 'welcome#index'

  resources :wallet_transfers, only: [:show, :create] do
  end

  resources :bank_transfers, only: [:show, :create] do
  end

end
