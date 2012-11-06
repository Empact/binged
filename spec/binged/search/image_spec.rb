require 'spec_helper'

module Binged
  module Search

    describe "Image" do
      include AnyFilter
      include AnyPageable

      before(:each) do
        @client = Binged::Client.new(:account_key => 'binged')
        @search = Image.new(@client)
      end

      it "should initialize with a search term" do
        Image.new(@client, 'binged').query[:Query].should include('binged')
      end

      context "filtering" do

        describe "size" do
          it "should filter by small images" do
            @search.small
            @search.query['Image.Filters'].should include('Size:Small')
          end

          it "should filter by medium images" do
            @search.medium
            @search.query['Image.Filters'].should include('Size:Medium')
          end

          it "should filter by large images" do
            @search.large
            @search.query['Image.Filters'].should include('Size:Large')
          end

        end

        describe "adult" do
          [:off, :moderate, :strict].each do |level|
            it "should filter with adult content #{level}" do
              @search.adult(level)
              @search.query[:Adult].should == level
            end

            it "should filter with safe search #{level}" do
              @search.safe_search(level)
              @search.query[:Adult].should == level
            end
          end
        end

        describe "size" do

          it "should filter for images with a specified height in pixels" do
            @search.height 100
            @search.query['Image.Filters'].should include('Size:Height:100')
          end

          it "should filter for images with a specified width in pixels" do
            @search.width 150
            @search.query['Image.Filters'].should include('Size:Width:150')
          end

        end

        describe "aspect" do

          %w(Square Wide Tall).each do |aspect|

            it "should restrict image results to those with #{aspect} aspect ratios" do
              @search.send aspect.downcase.to_sym
              @search.query['Image.Filters'].should include("Aspect:#{aspect}")
            end

          end

        end

        describe "color" do

          %w(Color Monochrome).each do |color|

            it "should restrict image results to those which are in #{color}" do
              @search.send color.downcase.to_sym
              @search.query["Image.Filters"].should include("Color:#{color}")
            end

          end

        end

        describe "style" do

          %w(Photo Graphics).each do |style|

            it "should restrict image results to those which have a #{style} style" do
              @search.send style.downcase.to_sym
              @search.query["Image.Filters"].should include("Style:#{style}")
            end

          end

        end

        describe "faces" do

          %w(Face Portrait).each do |face|

            it "should restrict image results to those which contain a #{face}" do
              @search.send face.downcase.to_sym
              @search.query["Image.Filters"].should include("Face:#{face}")
            end

          end

        end

      end

      context "fetching" do

        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/Image?%24format=JSON&%24skip=0&%24top=20&Query=%27ruby%27", 'images.curl')
          @search.containing("ruby")
          @response = @search.fetch
        end

        it "should cache fetch to eliminate multiple calls to the api" do
          Image.should_not_receive(:perform)
          @search.fetch
        end

        it "should return the results of the search" do
          @response.results.size.should == 20
        end

        it "should support dot notation" do
          result = @response.results.first
          result.title.should == "Ruby | ANGEL JEWEL Custom Design Hand Made Jewellery, Mumbai"
          result.media_url.should == "http://www.angeljewel.com/wp-content/uploads/2009/08/Ruby_by_Punksim1.jpg"
          result.source_url.should == "http://angeljewel.com/index.php/materials/ruby"
          result.width.should == "700"
          result.height.should == "682"
          result.file_size.should == "90134"
          result.content_type.should == 'image/jpeg'
        end

      end

      context "iterating over results" do

        before(:each) do
          stub_get("https://binged:binged@api.datamarket.azure.com:443/Data.ashx/Bing/Search/Image?%24format=JSON&%24skip=0&%24top=20&Query=%27ruby%27", 'images.curl')
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
