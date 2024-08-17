# frozen_string_literal: true

module Airbased
  class Table
    # Methods for querying tables.
    module Query
      # Fetches a specific record from an Airtable table.
      #
      # @param record_id [String] The ID of the record to retrieve.
      # @return [Record] A record instance with the record data.
      def find(record_id)
        # TODO: cellFormat and returnFieldsByFieldId
        response = Airtable.get("/#{@base_id}/#{table_key}/#{record_id}", nil, options)
        Record.new(id: response[:id], fields: response[:fields], created_time: response[:created_time], table: self)
      end
      alias :get_record :find

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

        # TODO: required params

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

      private

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

        response = Airtable.post("/#{@base_id}/#{table_key}/listRecords", {
          offset:, page_size:, max_records:, fields:, view:, sort:, filter_by_formula:,
          time_zone:, user_locale:, cell_format:, return_fields_by_field_id:, record_metadata:
        }, options)
        records = response[:records].map do |record|
          Record.new(id: record[:id], fields: record[:fields], created_time: record[:created_time], table: self)
        end

        { offset: response[:offset], records: }
      end
    end
  end
end
