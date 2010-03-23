require File.dirname(__FILE__) + '/../spec_helper'

describe ShopBillingStatus do
  before(:each) do
    @shop_billing_status = ShopBillingStatus.new
  end

  it "should be valid" do
    @shop_billing_status.should be_valid
  end
end
