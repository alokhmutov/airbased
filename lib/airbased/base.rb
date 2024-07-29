module Airbased
  # The `Airbased::Base` class represents an Airtable base and
  # provides methods to interact with the base.
  #
  # @attr_accessor [String] :base_id the unique identifier for the base
  # @attr_accessor [Array<Table>] :tables the tables associated with the base
  # @attr_accessor [String] :api_key the API key used for authentication
  class Base
    attr_accessor :base_id, :tables, :api_key

    # Initializes a new instance of the Base class.
    #
    # @param base_id [String] the unique identifier for the base
    # @param api_key [String, nil] the API key used for authentication (optional)
    def initialize(base_id, api_key: nil)
      @base_id = base_id
      @api_key = api_key || Airbased.api_key
    end
  end
end
