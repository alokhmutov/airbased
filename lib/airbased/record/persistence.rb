# frozen_string_literal: true

module Airbased
  class Record
    # API methods for Airtable records.
    module Persistence
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
    end
  end
end