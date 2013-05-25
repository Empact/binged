module Binged
  module Search

    # A class that encapsulated the Bing Spelling Suggestions Search source
    class Spelling < Base
      include Filter
      include Pageable

      # @param [Binged::Client] client
      # @param [String] query The search term to be sent to Bing
      # @param [Hash] options
      def initialize(client, query=nil, options={})
        super(client, query)
        @source = :spelling_suggestions
        set_paging_defaults
      end


      def suggestions
        fetch.results.map{|r| r.value }
      end

    end
  end
end
