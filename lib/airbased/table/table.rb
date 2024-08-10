# frozen_string_literal: true

module Airbased
  # Represents a table in the Airtable base, and provides a way to interact with it.
  class Table
    include SearchMethods
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

    def table_key
      @id || CGI.escape_uri_component(@name)
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

    # Fetches a specific record from an Airtable table.
    #
    # @param record_id [String] The ID of the record to retrieve.
    # @return [Record] A record instance with the record data.
    def find(record_id)
      # TODO: cellFormat and returnFieldsByFieldId
      response = Airtable.get("/#{@base_id}/#{table_key}/#{record_id}")
      Record.new(id: response[:id], fields: response[:fields], created_time: response[:created_time], table: self)
    end
    alias :get_record :find

    # Creates new records in the Airtable base.
    #
    # This method sends a POST request to the Airtable API to create new records.
    # The records parameter can either be a single hash or an array of hashes, where each hash represents a record.
    #
    # @param record_or_records [Hash, Array<Hash>] The records to be created. Must be a hash or an array of hashes.
    # @param typecast [Boolean] (false) Whether to automatically typecast values. Defaults to false.
    # @return [Record, Array<Record>] The created record(s). Returns a single record if one record is created, otherwise returns an array of records.
    def create(record_or_records, typecast: false)
      records = record_or_records.is_a?(Hash) ? [record_or_records] : record_or_records
      records.map! { |record| { fields: record } }

      returned_records = records.each_slice(10).map do |slice|
        create_slice(slice, typecast:)
      end.flatten
      returned_records.size == 1 ? returned_records.first : returned_records
    end

    # Creates new records in the Airtable base in slices of up to 10 records
    # from an array of hashes, where each hash represents a record.
    #
    # @param slice [Array<Hash>] The slice of records to be created. Each record is represented as a hash.
    # @return [Array<Record>] An array of Record objects created from the response of the Airtable API.
    def create_slice(slice, typecast:)
      records = Airtable.post("/#{@base_id}/#{table_key}", { records: slice, typecast: })[:records]
      records.map do |record|
        Record.new(id: record[:id], fields: record[:fields], created_time: record[:created_time], table: self)
      end
    end
  end
end
