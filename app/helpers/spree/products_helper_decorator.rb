Spree::ProductsHelper.module_eval do
  def cache_key_for_product(product = @product)
    (
      common_product_cache_keys +
      [product.cache_key, product.possible_promotions] +
      [current_order.try(:id), current_order.try(:total).to_f]
    ).compact.join("/")
  end
end
