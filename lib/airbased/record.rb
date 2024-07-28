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
    def initialize(id:, fields:, created_time:, table:)
      @id = id
      @created_time = Time.parse(created_time)
      @fields = fields
      @table = table
    end

    # Deletes a record from an Airtable table.
    #
    # @return [Record] of the deleted record, otherwise hash with error message
    def delete
      response = Airtable.delete("/#{@table.base_id}/#{@table.id}/#{@id}")
      self if response.dig("deleted")
    end
  end
end