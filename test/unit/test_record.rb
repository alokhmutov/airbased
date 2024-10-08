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

    symbol_keys = { Name: "Updated Record", Value: 99 }
    @record.fields = symbol_keys
    assert_equal new_fields, @record.fields

    new_fields = { "Name" => "Updated x2 Record" }
    @record.fields = new_fields
    assert_equal new_fields, @record.fields
  end

  def test_assign
    new_fields = { "Name" => "Updated Record", "Value" => 99 }
    @record.assign(new_fields)
    assert_equal new_fields, @record.fields

    symbol_keys = { Name: "Updated Record", Value: 99 }
    @record.assign(symbol_keys)
    assert_equal new_fields, @record.fields

    new_fields = { "Name" => "Updated x2 Record" }
    @record.assign(new_fields)
    assert_equal "Updated x2 Record", @record.fields["Name"]
    assert_equal 99, @record.fields["Value"]
    assert_equal "Updated x2 Record", @record.fields[:Name]
    assert_equal 99, @record.fields[:Value]
  end

  def test_new_record?
    assert_equal false, @record.new_record?
    @record.instance_variable_set(:@id, nil)
    assert_equal true, @record.new_record?
  end

  def test_destroyed?
    assert_equal false, @record.destroyed?
    @record.instance_variable_set(:@destroyed, true)
    assert_equal true, @record.destroyed?
  end

  def test_fields_value_accessor
    assert_equal "Test Record", @record["Name"]
    assert_equal 42, @record[:Value]
  end

  def test_fields_value_assignment
    @record["Name"] = "Updated Record"
    @record[:Value] = 99

    assert_equal "Updated Record", @record["Name"]
    assert_equal "Updated Record", @record[:Name]
    assert_equal 99, @record["Value"]
    assert_equal 99, @record[:Value]
  end

  def test_indifferent_fields_access
    assert_equal "Test Record", @record.fields["Name"]
    assert_equal "Test Record", @record.fields[:Name]
    assert_equal 42, @record.fields["Value"]
    assert_equal 42, @record.fields[:Value]
  end

  def test_return_nil_on_missing_value
    assert_nil @record["Missing"]
    assert_nil @record[:Missing]
  end

  def test_equality
    new_fields = { "Name" => "Test Record", "Value" => 42 }
    new_record = Airbased::Record.new(id: @id, fields: new_fields, created_time: @created_time, table: @table)

    assert_equal @record, new_record
    refute_equal @record, new_fields
    refute_equal @record, [@record]
  end

  def test_hashification
    assert_equal @record.to_h, { id: @id, fields: @fields, created_time: Time.parse(@created_time), table: @table.table_key, base: @table.base_id }
    assert_equal @record.to_h[:fields]["Name"], @record["Name"]
  end

  def test_link
    assert_equal @record.link, "https://airtable.com/#{@base_id}/#{@table_id}/#{@id}"

    @record.instance_variable_set(:@id, nil)

    assert_raises(Airbased::Error) { @record.link }

    @table = Airbased::Table.new(base_id: @base_id, name: "Table 1")
    @record = Airbased::Record.new(id: @id, fields: @fields, created_time: @created_time, table: @table)

    assert_raises(Airbased::Error) { @record.link }

    @table.instance_variable_set(:@id, "tbl111")

    assert_equal @record.link, "https://airtable.com/#{@table.base_id}/#{@table.id}/#{@record.id}"
  end
end
