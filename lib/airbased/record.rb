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

    # Sets the fields of the record, transforming the keys to strings.
    #
    # @param fields [Hash] The fields to set, with keys that will be transformed to strings.
    # @return [void]
    def fields=(fields)
      @fields = fields.transform_keys(&:to_s)
    end

    # Checks if the record has been destroyed.
    #
    # @return [Boolean] True if the record is destroyed, false otherwise.
    def destroyed?
      !!@destroyed
    end

    # Deletes a record from an Airtable table.
    #
    # @return a frozen [Record] of the deleted record
    def delete
      Airtable.delete("/#{@table.base_id}/#{@table.id}/#{@id}")
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
                   Airtable.put("/#{@table.base_id}/#{@table.id}/#{@id}", { fields:, typecast: })
                 else
                   Airtable.patch("/#{@table.base_id}/#{@table.id}/#{@id}", { fields:, typecast: })
                 end
      assign(response[:fields])
      self
    end

    # Assigns new values to the record's fields.
    #
    # @param new_fields [Hash] The new values to assign to the record's fields.
    # @return [void] Always returns nil.
    def assign(new_fields)
      new_fields.each_pair { |k, v| @fields[k.to_s] = v }
      nil
    end

    # Retrieves the value of the specified field.
    #
    # @param field [String, Symbol] The field name to retrieve the value for.
    # @return [Object] The value of the specified field.
    def [](field)
      @fields[field.to_s]
    end

    # Sets the value of the specified field.
    #
    # @param key [String, Symbol] The field name to set the value for.
    # @param value [Object] The value to set for the specified field.
    # @return [void]
    def []=(key, value)
      @fields[key.to_s] = value
    end
  end
end
