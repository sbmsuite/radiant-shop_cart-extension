require File.dirname(__FILE__) + '/../spec_helper'

describe ShopShippingStatus do
  before(:each) do
    @shop_shipping_status = ShopShippingStatus.new
  end

  it "should be valid" do
    @shop_shipping_status.should be_valid
  end
end
