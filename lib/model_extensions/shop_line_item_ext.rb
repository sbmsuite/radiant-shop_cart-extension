module ShopCart
  module ShopLineItemExt
    def self.included(base)
      base.class_eval {
        def calc_price
          begin
            return ShopProduct.find(self.product_id).price.to_f * self.quantity.to_f
          rescue
            return 'Unable to calculate the weight of a Product'
          end          
        end

        def calc_weight
          begin
            return ShopProduct.find(self.product_id).weight.to_f * self.quantity.to_f
          rescue
            return 'Unable to calculate the weight of a Product'
          end
        end
      }
    end
  end
end
