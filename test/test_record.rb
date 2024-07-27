# frozen_string_literal: true

require "test_helper"
require "time"

class RecordTest < Minitest::Test
  def setup
    @id = "rec123"
    @fields = { "Name" => "Test Record", "Value" => 42 }
    @created_time = "2023-01-01T12:00:00Z"
    @table_id = "tbl123"
    @base_id = "base123"
    @table = Airbased::Table.new(base_id: @base_id, id: @table_id)

    @record = Airbased::Record.new(id: @id, fields: @fields, created_time: @created_time, table: @table)
  end

  def test_initialize
    assert_equal @id, @record.id
    assert_equal @fields, @record.fields
    assert_equal Time.parse(@created_time), @record.created_time
    assert_equal @table, @record.table
    assert_equal @table_id, @table.id
    assert_equal @base_id, @table.base_id
  end

  def test_fields_accessor
    new_fields = { "Name" => "Updated Record", "Value" => 99 }
    @record.fields = new_fields
    assert_equal new_fields, @record.fields
  end
end
