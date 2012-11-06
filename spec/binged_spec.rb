require 'spec_helper'

describe "Binged" do

  it "should configure the account_key for easy access" do
    Binged.configure do |config|
      config.account_key = 'account_key'
    end

    client = Binged::Client.new
    client.account_key.should == 'account_key'
  end

  describe "Flexible interface" do

    before(:each) do
      @client = Binged::Client.new
    end

    it "should provide an interface to web search" do
      @client.web.should be_instance_of(Binged::Search::Web)
    end

    it "should provide an interface to image search" do
      @client.image.should be_instance_of(Binged::Search::Image)
    end

    it "should provide an interface to video search" do
      @client.video.should be_instance_of(Binged::Search::Video)
    end

  end

end
