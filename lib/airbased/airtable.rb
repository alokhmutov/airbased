require "httparty"

module Airbased
  class Airtable
    include HTTParty
    base_uri 'https://api.airtable.com/v0/'
    headers 'User-Agent' => "Airbased Ruby Gem/#{Airbased::VERSION}",
            'Content-Type' => 'application/json'

    class << self
      attr_accessor :requests

      def with_rate_limit
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

      def authorization(options)
        api_key = options.delete(:api_key) || Airbased.api_key
        options[:headers] ||= {Authorization: "Bearer #{api_key}"}
      end

      # formating request body to json
      def process_query(query)
        processed_query = query.compact
        processed_query = deep_transform_keys(processed_query) { |key| from_snake(key) }

        JSON.dump(processed_query)
      end

      def process_result(result)
        deep_transform_keys(result) { |key| to_snake(key) }
      end

      def deep_transform_keys(obj, &block)
        case obj
        when Hash
          obj.each_with_object({}) do |(key, value), result|
            new_key = yield(key.to_s).to_sym
            result[new_key] = if key.to_s == "fields"
                                value
                              else
                                deep_transform_keys(value, &block)
                              end
          end
        when Array
          obj.map { |e| deep_transform_keys(e, &block) }
        else
          obj
        end
      end

      def to_snake(str)
        str.gsub(/([A-Z])/, '_\1').downcase
      end

      def from_snake(str)
        str.gsub(/_(.)/) { Regexp.last_match(1).upcase }
      end
    end

    @requests = []

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
          response = super(path, options, &block)
          process_result(response.parsed_response)
        end
      end
    end
  end
end
