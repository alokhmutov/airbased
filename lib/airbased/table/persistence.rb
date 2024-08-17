# frozen_string_literal: true

module Airbased
  class Table
    # Persistence API methods for Airtable tables
    module Persistence
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

      # Deletes records from the Airtable base.
      #
      # The records_or_record_ids parameter can either be an array of Record objects or an array of record IDs.
      #
      # @param records_or_record_ids [Array<Record, String>] The records or record IDs to be deleted.
      # @return [Array<Record, String>] The records or record IDs that were passed in.
      # @raise [Airbased::Error] if an element in the array is neither a Record object nor a String.
      def delete(records_or_record_ids)
        records_or_record_ids.each_slice(10).flat_map do |slice|
          ids = slice.map do |record|
            if record.is_a?(Record)
              record.id
            elsif record.is_a?(String)
              record
            else
              raise Airbased::Error.new("You need to pass an array of records or a record ids but #{record} is a #{record.class}.")
            end
          end
          response = Airtable.delete("/#{@base_id}/#{table_key}?" + URI.encode_www_form("records[]": ids), options)[:records]
          records_or_record_ids
        end
      end

      private

      # Creates new records in the Airtable base in slices of up to 10 records
      # from an array of hashes, where each hash represents a record.
      #
      # @param slice [Array<Hash>] The slice of records to be created. Each record is represented as a hash.
      # @return [Array<Record>] An array of Record objects created from the response of the Airtable API.
      def create_slice(slice, typecast:)
        records = Airtable.post("/#{@base_id}/#{table_key}", { records: slice, typecast: }, options)[:records]
        records.map do |record|
          Record.new(id: record[:id], fields: record[:fields], created_time: record[:created_time], table: self)
        end
      end
    end
  end
end
