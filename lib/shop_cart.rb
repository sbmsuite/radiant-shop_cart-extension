# See LICENSE file in the root for details
module ShopCart 
  require 'yaml'
  require 'active_merchant'

  # included is called from the Controller when you inject this module
  def self.included(base)
    base.extend ClassMethods
  end

  # declare the class level helper methods which will load the relevant instance methods defined below when invoked
  module ClassMethods
    def minimal_cart
      include ShopCart::ShoppingCart
    end
  end

  module ShoppingCart
    def add_cart(id)
      begin
        item = ShopProduct.find(id)
        get_cart.add item
      rescue Exception => e
        raise 'Error adding product to cart: ' + e.message
      end
    end

    def remove_cart(id)
      begin
        get_cart.remove id.to_i
      rescue Exception => e
        raise 'Error removing product: ' + e.message
      end
    end

    def update_cart(id, quantity)
      begin
        get_cart.update id, quantity
      rescue Exception => e
        raise 'Error updating the quantity of a product: ' + e.message
      end
    end

    def clear_cart
      get_cart.clear
    end

    def subtotal_cart
      return get_cart.price
    end

    def total_cart
      tax = MinimalTax::Tax.calculate get_cart
      shipping = MinimalShipping::Shipping.calculate get_cart
      return subtotal_cart + tax + shipping
    end

    def ship_to(shipping)
      #raise 'Invalid Customer data in Customer object' if !customer.valid?
      begin
        customer = get_cart.shipment.update_attributes!(shipping)
        session[:ship_to] = get_cart.shipment
      rescue Exception => exp
        raise 'Invalid Customer data in Customer object.<br>' + exp.to_s
      end
    end
    
    def bill_to(billing_info)
      begin
        billing = get_billing
        billing.card_type = billing_info[:credit_card]
        billing.card_number = billing_info[:card_number]
        billing.expiration_month = billing_info[:expiration_month]
        billing.expiration_year = billing_info[:expiration_year]
        billing.cvn = billing_info[:card_verification_number]
        
        session[:bill_to] = billing
      rescue Exception => exp
        raise 'Invalid Customer data in Customer object.<br>' + exp.to_s
        return
      end
      
      process_card
    end
    
    private
    def get_cart
      return session[:shopping_cart]
    end

    private
    def get_billing
      return session[:bill_to] ||= Billing.new
    end

    private
    def get_ship_to
      return session[:ship_to] ||= get_cart.shipment
    end

    private
    def process_card
      billing = get_billing
      customer = billing.customer
      order = get_cart
      credit_card = ActiveMerchant::Billing::CreditCard.new(:first_name => customer.first_name, :last_name => customer.last_name, :number => billing.card_number, :month => billing.expiration_month, :year => billing.expiration_year, :type => billing.card_type)
      raise 'Credit card is invalid.' if !credit_card.valid?
      options = {
        :address => {},
        :billing_address => {
          :name => customer.first_name + ' ' + customer.last_name, 
          :address1 => order.billing.address.street, 
          :city => order.billing.address.city, 
          :state => order.billing.address.state, 
          :country => order.billing.address.country, 
          :zip => order.billing.address.postal_code#, 
          #:phone => customer.phone
        }
      }
      config = ShopConfig.new
      begin
        gateway = ActiveMerchant::Billing::Base.gateway(config.name.to_s).new(:login => config.user_name.to_s, :password => config.password.to_s)    
      rescue
        raise 'Invalid ActiveMerchant Gateway'
      end
      amount_to_charge = total_cart
      response = gateway.authorize(amount_to_charge, credit_card, options)  
      if response.success?
        gateway.capture(amount_to_charge, response.authorization)
      else 
        raise "ActiveMerchant failed to authorize the charge ( #{amount_to_charge}$ ): " + response.message
      end
    end 

    def check_out
      session[:bill_to] = nil
      session[:ship_to] = nil
      session[:shopping_cart] = nil
    end
  end
  
  class ShopConfig
    attr_reader :name
    attr_reader :user_name
    attr_reader :password

    attr_reader :ups_login
    attr_reader :ups_password
    attr_reader :ups_key
    attr_reader :usps_login
    attr_reader :fedex_login
    attr_reader :fedex_password

    def initialize
      config = YAML::load(File.open("#{RAILS_ROOT}/vendor/extensions/shop_cart/config/shop_cart.yml"))
      raise "Please configure the ActiveMerchant Gateway" if config['merchant_account'] == nil

      # Configure active_merchant   
      @name = config['merchant_account']['name'].to_s
      @user_name = config['merchant_account']['user_name'].to_s
      @password  = config['merchant_account']['password'].to_s

      # Configure ups
      unless config['ups_shipping'] == nil
        @ups_login = config['ups_shipping']['ups_login'].to_s
        @ups_password = config['ups_shipping']['ups_password'].to_s
        @ups_key = config['ups_shipping']['ups_key'].to_s
      end

      # Configure usps
      unless config['usps_shipping'] == nil
        @usps_login = config['usps_shipping']['usps_login'].to_s
      end

      # Configure fedex
      unless config['fedex_shipping'] == nil
        @fedex_login = config['fedex_shipping']['fedex_login'].to_s
        @fedex_password = config['fedex_shipping']['fedex_login'].to_s
      end
    end
  end 
end 


module MinimalTax
  class Tax
    class << self
      def calculate(cart)
        raise 'Cannot calculate tax on an empty Cart' if cart == nil
        vat_tax_rate = ShopVatTax.find_by_iso(cart.addresses.find_by_atype("shipping").country).rate || 0.0
        state_tax_rate = ShopStateTax.find_by_state_and_country(cart.shipments.first.address.state, cart.shipments.first.address.country).rate || 0.0
        total_vat_tax = (cart.price * vat_tax_rate) / 100.00 unless tax_rate == -1.0
        total_state_tax = (cart.price * state_tax_rate) / 100.00 unless tax_rate == -1.0
        return (total_vat_tax + total_state_tax)
      end
    end
  end
end


module MinimalShipping
  class Shipping
    class << self 
      def calculate(cart,shipping)
        raise 'Cannot calculate shipping on an empty Cart' if cart == nil
        shipping_rate = 0.0
        cart.shipments.each do |shipment|
          shipping_rate += shipment.rate.to_f
        end
        shipping_rate *= 0.01
      end
    end
  end
end
