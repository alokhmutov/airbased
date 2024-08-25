# frozen_string_literal: true

module Airbased
  class Table
    # Persistence API methods for Airtable tables
    module Persistence
      include Airbased::Validation
      # Creates new records in the Airtable base.
      #
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

      # Updates existing records in the Airtable base.
      #
      # The records parameter can either be an array of Record objects or an array of hashes, where each hash represents a record.
      #
      # @param records [Array<Record, Hash>] The records to be updated. Must be an array of Record objects or hashes.
      # @param overwrite [Boolean] (false) Whether to overwrite existing records. If true, will clear the fields not in the request. Defaults to false.
      # @param typecast [Boolean] (false) Whether to automatically typecast values. Defaults to false.
      # @return [Array<Record>] The updated records.
      # @raise [Airbased::Error] If a record is missing an ID, since it is mandatory for update.
      def update(records, overwrite: false, typecast: false)
        record_hashes = hash_or_record_to_hash(records, id_required: true)

        record_hashes.each_slice(10).flat_map do |slice|
          update_slice(slice, overwrite:, typecast:)
        end
      end

      # Upserts records in the Airtable base.
      #
      # The records parameter can either be an array of Record objects or an array of hashes, where each hash represents a record.
      #
      # @param records [Array<Record, Hash>] The records to be upserted. Must be an array of Record objects or hashes.
      # @param merge_on [Array<String>] The fields to merge on. Must be an array of 1 to 3 field names.
      # @param overwrite [Boolean] (false) Whether to overwrite existing records. If true, will clear the fields not in the request. Defaults to false.
      # @param typecast [Boolean] (false) Whether to automatically typecast values. Defaults to false.
      # @raise [Airbased::Error] If merge_on is not an array of 1 to 3 field names.
      def upsert(records, merge_on:, overwrite: false, typecast: false)
        raise Airbased::Error.new("merge_on must be an array of 1 to 3 field names") unless
          merge_on.is_a?(Array) && merge_on.size.between?(1, 3)

        record_hashes = hash_or_record_to_hash(records)

        record_hashes.each_slice(10).flat_map do |slice|
          upsert_slice(slice, merge_on:, overwrite:, typecast:)
        end
      end

      # Deletes records from the Airtable base.
      #
      # The records_or_record_ids parameter can either be an array of Record objects or an array of record IDs.
      #
      # @param records_or_record_ids [Array<Record, String>] The records or record IDs to be deleted.
      # @return [Array<Record>] The IDs of the deleted records.
      # @raise [Airbased::Error] if an element in the array is neither a Record object nor a String.
      def delete(records_or_record_ids)
        responses = records_or_record_ids.each_slice(10).flat_map do |slice|
          ids = slice.map do |record|
            if record.is_a?(Record)
              record.id
            elsif record.is_a?(String)
              record
            else
              raise Airbased::Error.new("You need to pass an array of records or a record ids but #{record} is a #{record.class}.")
            end
          end
          Airtable.delete("/#{@base_id}/#{table_key}?" + URI.encode_www_form("records[]": ids), options)[:records]
        end
        responses.map { |r| r[:id] }
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

      def update_slice(slice, overwrite:, typecast:)
        records = if overwrite
                    Airtable.put("/#{@base_id}/#{table_key}", { records: slice, typecast: }, options)[:records]
                  else
                    Airtable.patch("/#{@base_id}/#{table_key}", { records: slice, typecast: }, options)[:records]
                  end

        records.map do |record|
          Record.new(id: record[:id], fields: record[:fields], created_time: record[:created_time], table: self)
        end
      end

      def upsert_slice(slice, merge_on:, overwrite:, typecast:)
        records = if overwrite
                    Airtable.put("/#{@base_id}/#{table_key}", { perform_upsert: { fields_to_merge_on: merge_on }, records: slice, typecast: }, options)[:records]
                  else
                    Airtable.patch("/#{@base_id}/#{table_key}", { perform_upsert: { fields_to_merge_on: merge_on }, records: slice, typecast: }, options)[:records]
                  end

        records.map do |record|
          Record.new(id: record[:id], fields: record[:fields], created_time: record[:created_time], table: self)
        end
      end
    end
  end
end
