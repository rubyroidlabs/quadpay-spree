module Spree
  class QuadPayOrder < Spree::Base
    belongs_to :payment
  end
end
