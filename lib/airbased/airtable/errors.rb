# frozen_string_literal: true

module Airbased
  class Airtable
    module Errors
      class AirtableError < StandardError; end

      class BadRequest < AirtableError; end
      class Unauthorized < AirtableError; end
      class Forbidden < AirtableError; end
      class NotFound < AirtableError; end
      class PayloadTooLarge < AirtableError; end
      class InvalidRequest < AirtableError; end
      class TooManyRequests < AirtableError; end
      class InternalServerError < AirtableError; end
      class BadGateway < AirtableError; end
      class ServiceUnavailable < AirtableError; end

      def Airtable.with_error_handling
        response = yield

        case response.code
        when 200
          response
        when 400
          raise BadRequest, response["error"]["message"]
        when 401
          raise Unauthorized, response["error"]["message"]
        when 403
          raise Forbidden, response["error"]["message"]
        when 404
          raise NotFound, response["error"]["message"]
        when 413
          raise PayloadTooLarge, response["error"]["message"]
        when 422
          raise InvalidRequest, response["error"]["message"]
        when 429
          raise TooManyRequests, response["error"]["message"]
        when 500
          raise InternalServerError, response["error"]["message"]
        when 502
          raise BadGateway, response["error"]["message"]
        when 503
          raise ServiceUnavailable, response["error"]["message"]
        end
      rescue Net
        puts "retrying"
        retry
      rescue BadGateway
        puts "retrying bad gateway"
        retry
      end
    end
  end
end
