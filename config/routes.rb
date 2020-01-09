Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :orders, :only => [] do
    collection do
      get :quadpay_cancel
      get :quadpay_confirm
    end
  end
  # NOTE: Make routes working for our project
  # Removed path parameter for namespace below.
  namespace :admin do
    resources :quad_pay_settings, :only => [] do
      collection do
        get :edit
        put :update
      end
    end
  end
end
