module Binged
  class Synonyms
    include Enumerable
    attr_reader :client, :query
    
    BASE_URI = 'https://api.datamarket.azure.com/Bing/Synonyms/GetSynonyms'
    
    # @param [Binged::Client] client
    # @param [String] query The search term to be sent to Bing
    def initialize(client, query=nil)
      @client = client
      @query = { :Query => [] }
      related(query) if query && query.strip != ''
    end
    
    def fetch
      if @fetch.nil?
        response = perform
        @fetch = Hashie::Mash.new(response["d"])
      end
      @fetch
    end
    
    # Add query to search
    #
    # @param [String] query The search term to be sent to Bing
    # @return [self]
    def related(query)
      @query[:Query] << query
      self
    end
    
    def perform
      url = URI.parse BASE_URI
      query = @query.dup
      query[:Query] = query[:Query].join(' ')
      query.each do |key, value|
        query[key] = %{'#{value}'} unless key[0] == '$'
      end
      
      query_options = default_options.merge(query).to_query
      query_options.gsub! '%2B', '+'
      url.query = query_options

      response = connection.get(url)
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise StandardError, response.body.strip
      end
    end
    
    def connection
      Faraday.new.tap do |faraday|
        faraday.basic_auth(@client.account_key, @client.account_key)
      end
    end
    
    # @yieldreturn [Hash] A result from a Bing query
    def each
      fetch().results.each { |r| yield r }
    end
    
    private

    def default_options
      { '$format' => 'JSON' }
    end
  end
end