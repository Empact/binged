module Binged

  # A client which encapsulates the Bing API
  class Client

    attr_accessor :account_key

    # @param [Hash] options the options to create a client with.
    # @option options [String] :account_key The Bing API key used to make all API calls.
    def initialize(options = {})
      invalid_options = options.keys - [:account_key]
      raise ArgumentError, "Invalid options: #{invalid_options.inspect}." unless invalid_options.empty?
      @account_key = options[:account_key] || Binged.account_key
    end

    # Create a web search through Bing
    #
    # @param [String] query The search term to be sent to Bing
    def web(query='')
      Search::Web.new(self,query)
    end

    # Create a image search through Bing
    #
    # @param [String] query The search term to be sent to Bing
    def image(query='')
      Search::Image.new(self,query)
    end

    # Create a video search through Bing
    #
    # @param [String] query The search term to be sent to Bing
    def video(query='')
      Search::Video.new(self,query)
    end
    
    # Create a synonyms search through Bing
    #
    # @param [String] query The search term to be sent to Bing
    def synonyms(query='')
      Synonyms.new(self,query)
    end

  end

end
