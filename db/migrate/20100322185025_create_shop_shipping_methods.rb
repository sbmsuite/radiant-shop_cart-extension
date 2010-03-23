class CreateShopShippingMethods < ActiveRecord::Migration
  def self.up
    create_table :shop_shipping_methods do |t|
      t.string :service
      t.string :method
      t.integer :rate
      t.integer :address_id
      t.integer :order_id
      t.integer :status_id
      t.timestamps
    end
  end

  def self.down
    drop_table :shop_shipping_methods
  end
end
