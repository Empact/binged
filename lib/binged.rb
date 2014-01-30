require 'active_support/core_ext/object/to_query'
require 'json'
require 'hashie'
require 'faraday'
require 'uri'

require 'binged/hashie_extensions'

# The module that contains everything Binged related
#
# * {Binged::Client} is used to interact with the Bing API
# * {Binged::Search} contains different Bing search sources
module Binged
  autoload :Client, "binged/client"
  autoload :Search, "binged/search"
  autoload :Synonyms, "binged/synonyms"

  extend self

  # Configure global options for Binged
  #
  # For example:
  #
  #     Binged.configure do |config|
  #       config.account_key = 'account_key'
  #     end
  attr_accessor :account_key

  def configure
    yield self
    true
  end

end
