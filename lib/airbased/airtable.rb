require "httparty"

module Airbased
  class Airtable
    include HTTParty
    base_uri 'https://api.airtable.com/v0/'
    headers 'User-Agent' => "Airbased Ruby Gem/#{Airbased::VERSION}",
            'Content-Type' => 'application/json'

    class << self
      attr_accessor :requests
    end
    @requests = []

    def self.with_rate_limit
      # Keep only the timestamps within the last second
      @requests.reject! { |timestamp| Time.now - timestamp > 1 }

      if @requests.size >= 5
        sleep_time = 1 - (Time.now - @requests.first)
        sleep(sleep_time) if sleep_time.positive?
      end

      response = yield

      request_time =
        begin
          Time.parse(response.headers["date"])
        rescue
          Time.now
        end

      @requests << request_time

      response
    end

    def self.authorization(options)
      api_key = options.delete(:api_key) || Airbased.api_key
      options[:headers] ||= {Authorization: "Bearer #{api_key}"}
    end

    # formating request body to json
    def self.process_query(query)
      JSON.dump(query.compact)
    end

    # processing a custom api key and debug options, formatting query, then making request
    [:get, :post, :patch, :put, :delete].each do |method|
      define_singleton_method(method) do |path, query = nil, options = {}, &block|
        # setting API key in request
        authorization(options)
        options[:body] = process_query(query) if query
        # would output request info if enabled
        options[:debug_output] = $stdout if Airbased.debug

        # processes rate limits
        with_rate_limit do
          # and then delegates to the HTTParty method
          super(path, options, &block)
        end
      end
    end
  end
end
