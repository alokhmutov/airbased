# frozen_string_literal: true

module Airbased
  class Table
    module SearchMethods
      def records_page(
        offset: nil,
        page_size: nil,
        max_records: nil,
        fields: nil,
        view: nil,
        sort: nil,
        filter_by_formula: nil,
        time_zone: nil,
        user_locale: nil,
        cell_format: nil,
        return_fields_by_field_id: nil,
        record_metadata: nil
      )
        # TODO: required params

        response = Airtable.post("/#{@base_id}/#{table_key}/listRecords",
                                 { offset:, page_size:, max_records:, fields:, view:, sort:, filter_by_formula:,
                                   time_zone:, user_locale:, cell_format:, return_fields_by_field_id:, record_metadata: },
                                 options)
        records = response[:records].map do |record|
          Record.new(id: record[:id], fields: record[:fields], created_time: record[:created_time], table: self)
        end

        { offset: response[:offset], records: }
      end

      # TODO: comment count
      # Retrieves records from an Airtable table.
      #
      # @param offset [String, nil] The starting point for the next page of records.
      # @param page_size [Integer, nil] The number of records to retrieve per page.
      # @param max_records [Integer, nil] The maximum number of records to retrieve.
      # @param fields [Array<String>, nil] The specific fields to retrieve. Returns all fields if empty.
      # @param view [String, nil] The view to retrieve records from.
      # @param sort [Array<Hash>, nil] The sort order for the records.
      # @param filter_by_formula [String, nil] The formula to filter records by.
      # @param time_zone [String, nil] The time zone for date fields.
      # @param user_locale [String, nil] The locale for user-specific fields.
      # @param cell_format [String, nil] The format for cell values.
      # @param return_fields_by_field_id [Boolean, nil] Whether to return fields by field ID.
      # @return [Array<Record>] An array of all records retrieved.
      def all(
        offset: nil,
        page_size: nil,
        max_records: nil,
        fields: nil,
        view: nil,
        sort: nil,
        filter_by_formula: nil,
        time_zone: nil,
        user_locale: nil,
        cell_format: nil,
        return_fields_by_field_id: nil,
        record_metadata: nil
      )
        records = []

        loop do
          result = records_page(
            offset:, page_size:, max_records:, fields:, view:, sort:, filter_by_formula:,
            time_zone:, user_locale:, cell_format:, return_fields_by_field_id:, record_metadata:
          )

          offset = result[:offset]
          page_records = result[:records]
          records.concat(page_records)
          break if offset.nil?
        end
        records
      end
      alias :records :all
    end
  end
end
