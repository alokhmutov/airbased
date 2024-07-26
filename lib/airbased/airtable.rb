require "httparty"

module Airbased
  class Airtable
    include HTTParty
    base_uri 'https://api.airtable.com/v0/'
    headers 'User-Agent' => "Airbased Ruby Gem/#{Airbased::VERSION}"

    class << self
      attr_accessor :requests
    end
    @requests = []

    def self.with_rate_limit
      # Keep only the timestamps within the last second
      @requests.reject! { |timestamp| (now = Time.now) - timestamp > 1 }

      if @requests.size >= 5
        sleep_time = 1 - (now - @requests.first)
        if sleep_time > 0
          sleep(sleep_time)
        end
      end

      response = yield

      @requests << Time.parse(response.headers["date"]) rescue Time.now

      response
    end

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
        with_rate_limit do
          # delegates to the HTTParty method
          super(path, options, &block)
        end
      end
    end
  end
end
