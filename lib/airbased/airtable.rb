require "httparty"

module Airbased
  class Airtable
    include HTTParty
    base_uri 'https://api.airtable.com/v0/'
    headers 'User-Agent' => "Airbased Ruby Gem/#{Airbased::VERSION}"

    def self.authorization(options)
      api_key = options.delete(:api_key) || Airbased.api_key
      options[:headers] ||= {Authorization: "Bearer #{api_key}"}
    end

    # processing a custom api key option first, then making request
    [:get, :post, :patch, :put, :delete].each do |method|
      define_singleton_method(method) do |path, options = {}, &block|
        # setting API key in request
        authorization(options)

        # would output request info if enabled
        options[:debug_output] = $stdout if Airbased.debug

        # delegates to the HTTParty method
        super(path, options, &block)
      end
    end
  end
end
