module Airbased
  # The Validation module provides methods for validating Airtable-related values.
  module Validation
    # Converts a hash or record to a hash representation.
    #
    # @param value [Array<Hash, Record>] The array of hashes or records to convert.
    # @param id_required [Boolean] Whether an ID is required for each record.
    # @return [Array<Hash>] An array of hashes representing the records.
    # @raise [Airbased::Error] If a record is missing an ID when id_required is true.
    def hash_or_record_to_hash(value, id_required: false)
      built_records = value.map do |record_object|
        if id_required && ((record_object.is_a?(Hash) && record_object&.dig(:id).nil? && record_object&.dig("id").nil?) || (record_object.is_a?(Record) && record_object.new_record?))
          raise Airbased::Error.new("id in records are mandatory for update. Use upsert with merge_on: for records not yet persisted")
        end

        if record_object.is_a?(Hash)
          new_record(**record_object)
        elsif record_object.is_a?(Airbased::Record)
          record_object
        else
          raise Airbased::Error.new("You need to pass an array of records or a record hashes but #{record_object} is a #{record_object.class}.")
        end
      end
      built_records.map(&:to_api_hash)
    end
  end
end