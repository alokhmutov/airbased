# frozen_string_literal: true

module Airbased
  # Represents a table in the Airtable base, and provides a way to interact with it.
  class Table
    attr_accessor :id, :name, :base_id, :api_key, :fields, :primary_field_id, :views, :description

    # Initializes a new Table object.
    #
    # @param id [String, nil] The ID of the table.
    # @param name [String, nil] The name of the table.
    # @param base_id [String, nil] The ID of the base containing the table.
    # @param api_key [String, nil] The API key to access the table.
    # @param fields [Array<Hash>, nil] The list of fields in the table.
    # @param primary_field_id [String, nil] The ID of the primary field in the table.
    # @param views [Array<Hash>, nil] The list of views in the table.
    # @param description [String, nil] The description of the table.
    #
    # @raise [Airbased::Error] if both id and name are nil.
    #
    # @return [Airbased::Table] A new Table object.
    def initialize(
      id: nil,
      name: nil,
      base_id: nil,
      api_key: nil,
      fields: nil,
      primary_field_id: nil,
      views: nil,
      description: nil
    )
      raise Airbased::Error.new("You need to pass an id or a name for the table") if id.nil? && name.nil?

      @id = id
      @name = name
      @base_id = base_id
      @fields = fields
      @primary_field_id = primary_field_id
      @views = views
      @description = description

      # only define api_key if passed specifically for this table, will otherwise use module's api key
      @api_key = api_key if api_key
    end
  end
end
