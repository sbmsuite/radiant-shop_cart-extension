module ShopCart
  module ShopOrderExt
    def self.included(base)
      base.class_eval {
        has_one :shipment, :class_name => 'ShopShippingMethod', :foreign_key => 'order_id'
        has_one :billing, :class_name => 'ShopBillingMethod', :foreign_key => 'order_id'

        def add(product)
          if self.line_items.exists?({:product_id => product.id})
            new_qty = self.line_items.first(:conditions => {:product_id => product.id}).quantity += 1
            self.line_items.first(:conditions => {:product_id => product.id}).update_attribute(:quantity, new_qty)
          else
            self.line_items.create(:product_id => product.id, :quantity => 1)
          end
        end

        def remove(id)
          begin
            self.line_items.first(:conditions => {:product_id => id}).destroy
          rescue IndexError
            raise 'No order found on ShopOrder.remove'
          end          
        end

        def update(id, quantity)
          if quantity.to_i == 0
            remove(id)
          else
            begin 
              self.line_items.first(:conditions => {:product_id => id}).quantity = quantity.to_i
            rescue IndexError
              raise 'No order found on ShopOrder.update'
            end
          end          
        end

        def clear
          self.line_items.destroy_all        
        end

#        def balance
#          # Add up all payments
#          total_payments = 0
#          unless self.payments.empty?
#            self.payments.each do |payment|
#              total_payments += payment.amount
#            end
#          end

#          order_total = self.sub_total # After we add taxes,etc we'll need to update this to sub_total + taxes + shipping
#          (order_total - total_payments)
#        end

        def price
          subtotal = 0
          self.line_items.each do |item|
            subtotal += item.calc_price
          end
          subtotal
        end

        def weight
          weight_total = 0
          self.line_items.each do |item|
            weight_total += item.calc_weight
          end
          weight_total
        end

      }
    end    
  end
end
