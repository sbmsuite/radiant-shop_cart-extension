class CreateShopBillingMethods < ActiveRecord::Migration
  def self.up
    create_table :shop_billing_methods do |t|
      t.string :method_id
      t.string :status_id
      t.integer :address_id
      t.integer :order_id
      t.timestamps
    end
  end

  def self.down
    drop_table :shop_billing_methods
  end
end
