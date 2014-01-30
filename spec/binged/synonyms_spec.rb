require 'spec_helper'

module Binged
    describe "Synonyms" do
     
      before(:each) do
        @client = Binged::Client.new(:account_key => 'binged')
        @search = Synonyms.new(@client)
      end

      it "should initialize with a search term" do
        Synonyms.new(@client, 'ruby').query[:Query].should include('ruby')
      end


      context "fetching" do
        before(:each) do
          stub_get "https://binged:binged@api.datamarket.azure.com/Bing/Synonyms/GetSynonyms?%24format=JSON&Query=%27ruby%27", "synonyms.curl"
          @search.related('ruby')
          @response = @search.fetch
        end

        it "should cache fetch to eliminate multiple calls to the api" do
          Synonyms.should_not_receive(:perform)
          @search.fetch
        end

        it "should return the results of the search" do
          @response.results.size.should == 2
        end

        it "should support dot notation" do
          first = @response.results.first
          first.synonym == 'rubies'
        end

      end

      context "iterating over results" do

        before(:each) do
          stub_get "https://binged:binged@api.datamarket.azure.com/Bing/Synonyms/GetSynonyms?%24format=JSON&Query=%27ruby%27", "synonyms.curl"
          @search.related('ruby')
        end

        it "should be able to iterate through results" do
          @search.should respond_to(:each)
        end

        it "should have items" do
          @search.each {|result| result.should_not be_nil }
        end

      end

    end

end
