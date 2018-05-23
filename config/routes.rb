Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :orders, :only => [] do
    collection do
      get :quadpay_cancel
      get :quadpay_confirm
    end
  end

  namespace :admin, path: Spree.admin_path do
    resources :quad_pay_settings, :only => [] do
      collection do
        get :edit
        put :update
      end
    end
  end
end
