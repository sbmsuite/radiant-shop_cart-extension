# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'
require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/controller_extensions/application_controller_ext"
require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/model_extensions/shop_line_item_ext"
require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/model_extensions/shop_order_ext"
class ShopCartExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://github.com/crankin/radiant-shop_cart-extension"

  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :shop_cart
  #   end
  # end
  
  extension_config do |config|
    config.gem 'activemerchant', :version => '~> 1.4.2', :source => 'http://gemcutter.org'
    config.extension 'shop_tax'
  end

  def activate
    # tab 'Content' do
    #   add_item "Shop Cart", "/admin/shop_cart", :after => "Pages"
    # end
    ApplicationController.send(:include, ShopCart::ApplicationControllerExt)
    ShopOrder.send(:include, ShopCart::ShopOrderExt)
    ShopLineItem.send(:include, ShopCart::ShopLineItemExt)
  end
end
