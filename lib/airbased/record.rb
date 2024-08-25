# frozen_string_literal: true

module Airbased
  # The Record class represents an individual record within an Airtable table.
  class Record
    include Record::Persistence
    attr_reader :id, :fields, :created_time, :table, :destroyed

    # Initializes a new Record instance.
    #
    # @param id [String] The ID of the record.
    # @param fields [Hash] The fields of the record.
    # @param created_time [String] The creation time of the record.
    # @param table [Table] The table object to which the record belongs, expected to have `base_id` and `id` attributes.
    def initialize(fields:, table:, id: nil, created_time: nil)
      @id = id
      @created_time = Time.parse(created_time) if created_time
      self.fields = fields
      @table = table
    end

    # Overwrites the fields of the record, transforming the keys to strings.
    #
    # @param fields [Hash] The fields to set, with keys that will be transformed to strings.
    # @return [void]
    def fields=(fields)
      @fields = Hash.new { |hash, key| hash[key.to_s] if key.is_a?(Symbol) }
      fields.each do |key, value|
        @fields[key.to_s] = value
      end
    end

    # Assigns new values to the record's fields, transforming the keys to strings.
    #
    # @param new_fields [Hash] The new values to assign to the record's fields.
    # @return [void] Always returns nil.
    def assign(new_fields)
      @fields.update(new_fields.transform_keys(&:to_s))
      nil
    end

    # Checks if the record is new (i.e., does not have an id).
    #
    # @return [Boolean] True if the record is new, false otherwise.
    def new_record?
      !id
    end

    # Checks if the record has been destroyed.
    #
    # @return [Boolean] True if the record is destroyed, false otherwise.
    def destroyed?
      !!destroyed
    end

    # Retrieves the value of the specified field.
    #
    # @param field [String, Symbol] The field name to retrieve the value for.
    # @return [Object] The value of the specified field.
    def [](field)
      @fields[field]
    end

    # Sets the value of the specified field.
    #
    # @param key [String, Symbol] The field name to set the value for.
    # @param value [Object] The value to set for the specified field.
    # @return [void]
    def []=(key, value)
      @fields[key.to_s] = value
    end

    # Compares the current record with another object for equality.
    #
    # @param other [Object] The object to compare with.
    # @return [Boolean] True if the other object is a Record and has the same id and fields, false otherwise.
    def ==(other)
      other.is_a?(Record) && id == other.id && fields == other.fields
    end

    # Converts the record to a hash representation.
    #
    # @return [Hash] A hash containing the record's id, fields, created_time, table key, and base id.
    def to_h
      {
        id: @id,
        fields: @fields,
        created_time: @created_time,
        table: @table.table_key,
        base: @table.base_id
      }
    end

    def to_api_hash
      {
        "id" => @id,
        "fields" => @fields
      }.compact
    end

    # Generates a link to the record in the Airtable table.
    #
    # @raise [Airbased::Error] If the table does not have an id (name only won't work in this case), or if a record does not have an id.
    # @return [String] The URL link to the record.
    def link
      raise Airbased::Error.new("Record's table needs a table id to generate a link") unless @table.id
      raise Airbased::Error.new("Record does not have an id to generate a link, it must be saved first") unless @id

      "https://airtable.com/#{@table.base_id}/#{@table.id}/#{@id}"
    end
  end
end
