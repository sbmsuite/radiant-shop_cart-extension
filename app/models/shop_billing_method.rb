class ShopBillingMethod < ActiveRecord::Base
  belongs_to :order, :class_name => "ShopOrder"
  belongs_to :address, :class_name => "ShopAddress"
end
