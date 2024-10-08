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

    # Fetches the schema of the Airtable base and updates the @tables variable.
    #
    # @return [Array<Airbased::Table>] the tables associated with the base
    def schema
      response = Airtable.get("/meta/bases/#{@base_id}/tables")
      @tables = response[:tables].map { |table| Airbased::Table.new(**table, base_id: @base_id) }
    end

    # Retrieves a table from the base by its id or name. Makes an API request to fetch the schema if tables have not been loaded yet.
    #
    # @param table_key [String] the key of the table to retrieve. This can be either the table's ID or name.
    # @return [Airbased::Table, nil] the table with the specified key, or nil if no such table exists.
    def [](table_key)
      schema if @tables.nil?
      table = @tables.find { |table| table.id == table_key || table.name == table_key }
      raise Airbased::Error.new("Table with '#{table_key}' not found in schema") if table.nil?

      table
    end

    # Creates a new table in the Airtable base.
    #
    # @param name [String] the name of the new table
    # @param fields [Array<Hash>] the fields of the new table
    # @param description [String, nil] an optional description for the new table
    # @return [Airbased::Table] the newly created table
    def create_table(name:, fields:, description: nil)
      response = Airbased::Airtable.post("/meta/bases/#{@base_id}/tables", { name:, fields:, description: })
      Table.new(**response, base_id: @base_id)
    end
  end
end
