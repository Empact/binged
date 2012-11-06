# encoding: utf-8
require 'spec_helper'

module Binged
  module Search

    describe "Web" do
      include AnyFilter
      include AnyPageable

      before(:each) do
        @client = Binged::Client.new(:account_key => 'binged')
        @search = Web.new(@client)
      end

      it "should initialize with a search term" do
        Web.new(@client, 'binged').query[:Query].should include('binged')
      end

      it "should be able to set a file type" do
        @search.file_type(:pdf)
        @search.query['Web.FileType'].should == :pdf
      end

      context "fetching" do

        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/Web?%24format=JSON&%24skip=0&%24top=20&Query=%27ruby%27", 'web.json')
          @search.containing("ruby")
          @response = @search.fetch
        end

        it "should cache fetch to eliminate multiple calls to the api" do
          Web.should_not_receive(:perform)
          @search.fetch
        end

        it "should return the results of the search" do
          @response.results.size.should == 20
        end

        it "should support dot notation" do
          result = @response.results.first
          result.title.should == "Ruby Programming Language"
          result.description.should == "Participate in a friendly and growing community. Mailing Lists: Talk about Ruby with programmers from all around the world. User Groups: Get in contact with Rubyists ..."
          result.url.should == "http://www.ruby-lang.org/"
        end

      end

      context "iterating over results" do

        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/Web?%24format=JSON&%24skip=0&%24top=20&Query=%27ruby%27", 'web.json')
          @search.containing("ruby")
        end

        it "should be able to iterate over results" do
          @search.respond_to?(:each).should be_true
        end

        it "should have items" do
          @search.each {|item| item.should_not be_nil }
        end

      end

    end

  end
end
