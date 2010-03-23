module ShopCart
  module ApplicationControllerExt
    def self.included(base)
      base.class_eval {
        def initialize_cart
          if session[:shopping_cart]
            @cart = ShopOrder.find(session[:shopping_cart])
          else
            @cart = ShopOrder.create(:status => 'new')
            session[:shopping_cart] = @cart.id
          end
        end
      }
    end
  end
end
