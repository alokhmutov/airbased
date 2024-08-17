# frozen_string_literal: true

module Airbased
  # The Record class represents an individual record within an Airtable table.
  class Record
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

    # Assigns new values to the record's fields.
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

    # Deletes a record from an Airtable table.
    #
    # @return a frozen [Record] of the deleted record
    def delete
      Airtable.delete("/#{@table.base_id}/#{@table.table_key}/#{@id}", nil, table.options)
      @destroyed = true
      freeze
      self
    end

    # Updates the fields of a record in an Airtable table.
    #
    # @param fields [Hash] The fields to update.
    # @param overwrite [Boolean] Whether to overwrite the existing fields (default: false).
    # @param typecast [Boolean] Whether to enable typecasting for the fields (default: false).
    # @return [Record] The updated record.
    def update(fields, overwrite: false, typecast: false)
      response = if overwrite
                   Airtable.put("/#{@table.base_id}/#{@table.table_key}/#{@id}", { fields:, typecast: }, table.options)
                 else
                   Airtable.patch("/#{@table.base_id}/#{@table.table_key}/#{@id}", { fields:, typecast: }, table.options)
                 end
      self.fields = response[:fields]
      self
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

    # Saves the record to the Airtable table.
    #
    # @param typecast [Boolean] Whether to enable typecasting for the fields (default: false).
    # @return [Record] Returns the saved record.
    def save(typecast: false)
      if new_record?
        record = @table.create(@fields, typecast:)
        self.fields = record.fields
        @created_time = record.created_time
        @id = record.id
        self
      else
        update(@fields, typecast:)
      end
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
