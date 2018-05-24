Spree::Admin::RefundsController.class_eval do
  after_action :check_error_flashes, only: :create

  private
    def check_error_flashes
      error_msg = @object.errors.full_messages.join('. ')
      flash[:error] = error_msg if error_msg.present?
    end
end
