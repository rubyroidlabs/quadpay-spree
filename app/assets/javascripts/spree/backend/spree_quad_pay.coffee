class QuadPayPaymentMethod
  selectors =
    quadPayPaymentMethodType: "select[name='payment_method[type]']"

  constructor: (content) ->
    return unless $(content).length > 0
    # init some variables here
    @_execute()

  bindingProviderChanged: ->
    $(selectors.quadPayPaymentMethodType).on 'change', (e) ->
      if e.currentTarget.value == 'Spree::BillingIntegration::QuadPayCheckout'
        $('[data-hook="auto_capture"').hide()
        $('#billing_integration_quad_pay_checkout_preferred_test_mode').hide()
        $('[for="billing_integration_quad_pay_checkout_preferred_test_mode"').hide()
        $('#billing_integration_quad_pay_checkout_preferred_server').hide()
        $('[for="billing_integration_quad_pay_checkout_preferred_server"').hide()
      else
        $('[data-hook="auto_capture"').show()
        $('#billing_integration_quad_pay_checkout_preferred_test_mode').show()
        $('[for="billing_integration_quad_pay_checkout_preferred_test_mode"').show()
        $('#billing_integration_quad_pay_checkout_preferred_server').show()
        $('[for="billing_integration_quad_pay_checkout_preferred_server"').show()
    $(selectors.quadPayPaymentMethodType).trigger('change')

  _execute: ->
    @bindingProviderChanged()

$ ->
  new QuadPayPaymentMethod($('[data-hook="admin_payment_method_form_fields"]'))
