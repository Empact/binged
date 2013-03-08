module Binged
  module Search
    class Error < StandardError
    end

    # @abstract Subclass and set @source to implement a custom Searchable class
    class Base
      include Enumerable
      attr_reader :client, :query, :source

      BASE_URI = 'https://api.datamarket.azure.com/Data.ashx/Bing/Search/'

      SUPPORTED_ADULT_OPTIONS = [:off, :moderate, :strict]

      # @param [Binged::Client] client
      # @param [String] query The search term to be sent to Bing
      def initialize(client, query=nil)
        @client = client
        @callbacks = []
        reset_query
        containing(query) if query && query.strip != ''
      end

      # Add query to search
      #
      # @param [String] query The search term to be sent to Bing
      # @return [self]
      def containing(query)
        @query[:Query] << query
        self
      end

      def adult(adult_option)
        @query[:Adult] = adult_option if SUPPORTED_ADULT_OPTIONS.include?(adult_option)
        self
      end
      alias safe_search adult

      def market(market_option)
        @query[:Market] = market_option if market_option.match(/\w{2}-\w{2}/)
        self
      end
      
      # Clears all filters to perform a new search
      def clear
        @fetch = nil
        reset_query
        self
      end

      # Retrieve results of the web search. Limited to first 1000 results.
      #
      # @return [Hash] A hash of the results returned from Bing
      def fetch
        if @fetch.nil?
          response = perform
          @fetch = Hashie::Mash.new(response["d"])
        end

        @fetch
      end

      def connection
        Faraday.new.tap do |faraday|
          faraday.basic_auth(@client.account_key, @client.account_key)
        end
      end

      # Performs a GET call to Bing API
      #
      # @return [Hash] Hash of Bing API response
      def perform
        url = URI.parse [BASE_URI, self.source.to_s.capitalize].join
        query = @query.dup
        query[:Query] = query[:Query].join(' ')
        callbacks.each {|callback| callback.call(query) }
        query.each do |key, value|
          query[key] = %{'#{value}'} unless key[0] == '$' || ['Latitude', 'Longitude'].include?(key)
        end
        query_options = default_options.merge(query).to_query
        query_options.gsub! '%2B', '+'
        url.query = query_options



        response = connection.get(url)
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise Error, response.body.strip
        end
      end

      # @yieldreturn [Hash] A result from a Bing query
      def each
        fetch().results.each { |r| yield r }
      end

      protected

        attr_reader :callbacks

      private

        def default_options
          { '$format' => 'JSON' }
        end

        def reset_query
          @query = { :Query => [] }
        end

    end

  end
end
