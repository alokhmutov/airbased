# Airbased

Ruby interface to the Airtable’s API.

## Note

The library is in early development, so breaking changes are possible. It implements all records API methods (including
batch operations), except Sync CSV data and attachment upload.

Feedback and contributions are most welcome!

## Start using Airbased

Define an API key, then define a base.

```ruby
Airbased.api_key = "patxxx"

# define a new base
MyBase = Airbased::Base.new("appxxxxxxxxxxxxxx")

# define a table from the base's schema
MyTable = MyBase["Table 1"] # you can use table name or id

# ... or though an ad-hoc definition
MyTable = Airbased.table(Airbased.api_key, "appxxxxxxxxxxxxxx", "tblxxxxxxxxxxxxxx")

# create a record
new_record = MyTable.create({"Name" => "a new name"})

# ... or many records at once, Airbased will take care of batching!
fields = [{ "Name" => "a new name 2" }, {"Name" => "a new name 3"}]
records = MyTable.create(fields)

# delete a record
new_record.delete

# fetch records
records = MyTable.all

# update records
record = records[0]
record["Name"] = "newer name"
record.save

# upsert records
records = MyTable.upsert(fields, merge_on: ["Name"])

# if something goes wrong...
Airbased.debug = true
# will write requests info into stdout
```
