# frozen_string_literal: true

module Airbased
  # The Record class represents an individual record within an Airtable table.
  class Record
    attr_reader :id, :created_time, :table
    attr_accessor :fields

    # Initializes a new Record instance.
    #
    # @param id [String] The ID of the record.
    # @param fields [Hash] The fields of the record.
    # @param created_time [String] The creation time of the record.
    # @param table [Table] The table object to which the record belongs, expected to have `base_id` and `id` attributes.
    def initialize(fields:, table:, id: nil, created_time: nil)
      @id = id
      @created_time = Time.parse(created_time) if created_time
      @fields = fields
      @table = table
    end

    # Deletes a record from an Airtable table.
    #
    # @return [Record] of the deleted record, otherwise hash with error message
    def delete
      response = Airtable.delete("/#{@table.base_id}/#{@table.id}/#{@id}")
      self if response.dig(:deleted)
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
      Record.new(id: response[:id], fields: response[:fields], created_time: response[:created_time], table: @table)
    end
  end
end
