Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :orders, :only => [] do
    resource :checkout, :controller => 'checkout', :path => '' do
      member do
        get :quadpay_cancel
        get :quadpay_confirm
      end
    end
  end
end
