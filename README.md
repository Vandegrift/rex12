[![CircleCI](https://circleci.com/gh/Vandegrift/rex12.svg?style=shield&circle-token=43575a1d75c0a4b93cfdde39ec725d1c47974036)](https://circleci.com/gh/Vandegrift/rex12)

# REX12

A simple gem to read EDI data in the ASNI X.12 format.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rex12'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rex12

## Usage

To simply read all data from an EDI data file into a REX12::Document...

*NOTE - All public REX12 methods for parsing EDI data (REX12#document, REX12#each_segment, and REX12#each_transaction) can receive a string path, a Pathname, an IO, or Tempfile object as the means for supplying your EDI data to the methods*

```ruby
require 'rex12'

document = REX12.document 'path/to/file.edi'

# yielded segments are of type REX12::Segment
document.segments.each do |segment|
  if segment.isa_segment?
    # Print out the sender from the ISA segment
    puts "Reading an EDI document from '#{segment[8]}'"
  else
    if segment.segment_type == "DTM"
      # Look for a specific date
      if segment[1] == "056"
        puts "Sender sent an '056' date of #{segment[2]}"
      else
        puts "This is not the date you're looking for."
      end
    end
  end
end
```

To get each individual transaction (.ie each individual unit defined between ST - SE segment pairs) yielded to your code:

```ruby
File.open("/path/to/file.edi", "r") do |file|
  REX12.each_transaction(file) do |transaction|
    # transaction is type REX12::Transaction
    edi_type = transaction.segments[0][1]
    if edi_type == "850"
      process_purchase_order(transaction)
    elsif edi_type == "856"
      process_shipment(transaction)
    else
      puts "Not sure what to do with #{edi_type} documents."
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releases (Repository Owners Only)

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Vandegrift/rex12. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
