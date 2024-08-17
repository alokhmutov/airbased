# frozen_string_literal: true

module Airbased
  # Represents a table in the Airtable base, and provides a way to interact with it.
  class Table
    include Query
    include Persistence
    attr_accessor :id, :name, :base_id, :api_key, :fields, :primary_field_id, :views, :description

    TABLE_MATCHER = /^tbl[[:alnum:]]+$/

    # Initializes a new Table object.
    #
    # @param base_id [String] The ID of the base containing the table.
    # @param id [String, nil] The ID of the table.
    # @param name [String, nil] The name of the table.
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
      base_id:,
      id: nil,
      name: nil,
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

    # Creates a new record instance associated with the table.
    #
    # @param fields [Hash] The fields of the new record.
    # @return [Record] A new Record object with the provided fields and associated with the current table.
    def new_record(fields)
      Record.new(fields:, table: self)
    end

    def table_key
      @id || CGI.escape_uri_component(@name)
    end

    # A shortcut for a hash with a table's api key in requests.
    #
    # @return [Hash] Hash with API key, or with nil value if no special api key set for table.
    def options
      { api_key: }
    end

    # Airrecord-style shorthand table definition.
    # Creates a new Table instance with the provided API key, base ID, and table key (table id or name).
    #
    # @param [String] api_key The API key to access the Airtable API.
    # @param [String] base_id The ID of the Airtable base.
    # @param [String] table_key The name or id of the table within the base.
    # @return [Table] A new Table instance.
    def Airbased.table(api_key, base_id, table_key)
      table_id = nil
      table_name = nil

      # Deducing whether the passed key is a name or id.
      if table_key.match?(TABLE_MATCHER)
        table_id = table_key
      else
        table_name = table_key
      end

      Table.new(api_key:, base_id:, id: table_id, name: table_name)
    end
  end
end
