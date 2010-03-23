class AddColumnsToShopProducts < ActiveRecord::Migration
  def self.up    
    # Add weight and dimensions to ShopProduct
    add_column :shop_products, :weight, :float
    add_column :shop_products, :height, :float
    add_column :shop_products, :width, :float
    add_column :shop_products, :depth, :float
  end

  def self.down
    remove_column :shop_products, :weight
    remove_column :shop_products, :height
    remove_column :shop_products, :width
    remove_column :shop_products, :depth
  end
end
