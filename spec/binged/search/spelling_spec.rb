# encoding: utf-8
require 'spec_helper'

module Binged
  module Search

    describe "Spelling" do
      include AnyFilter
      include AnyPageable

      before(:each) do
        @client = Binged::Client.new(:account_key => 'binged')
        @search = Spelling.new(@client)
      end

      it "should initialize with a search term" do
        Spelling.new(@client, 'binged').query[:Query].should include('binged')
      end

      context 'errors' do
        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/SpellingSuggestions?%24format=JSON&%24skip=0&%24top=20&Query=%27ruby%27",
            'bad_request.curl')
        end

        it 'raises' do
          @search.containing('ruby')
          expect {
            @search.fetch
          }.to raise_error(Binged::Search::Error, 'The authorization type you provided is not supported.  Only Basic and OAuth are supported')
        end
      end

      # curl -v "https://6yPcv6TxoRi6Rrkq2HjicGHZz1NnE2MGx3Xk7XLJrM0:6yPcv6TxoRi6Rrkq2HjicGHZz1NnE2MGx3Xk7XLJrM0@api.datamarket.azure.com/Data.ashx/Bing/Search/SpellingSuggestions?%24format=JSON&%24skip=0&%24top=20&Query=%27amstrong%27"

      context "fetching" do

        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/SpellingSuggestions?%24format=JSON&%24skip=0&%24top=20&Query=%27propaghandhi%27", 'spelling.curl')
          @search.containing("propaghandhi")
          @response = @search.fetch
        end

        it "should cache fetch to eliminate multiple calls to the api" do
          Spelling.should_not_receive(:perform)
          @search.fetch
        end

        it "should return the results of the search" do
          @response.results.size.should == 1
        end

        it "should support dot notation" do
          result = @response.results.first
          result.value.should == "propagandhi"
        end

      end

      context "iterating over results" do

        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/SpellingSuggestions?%24format=JSON&%24skip=0&%24top=20&Query=%27propaghandhi%27", 'spelling.curl')
          @search.containing("propaghandhi")
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
