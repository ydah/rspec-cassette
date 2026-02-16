# rspec-cassette

Replay VCR YAML cassettes as WebMock stubs in RSpec.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add rspec-cassette
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install rspec-cassette
```

## Usage

Require the RSpec integration in your `spec_helper.rb` or `rails_helper.rb`:

```ruby
require "rspec/cassette/rspec_helper"

Rspec::Cassette.configure do |config|
  config.cassettes_dir = "spec/fixtures/cassettes"
  config.default_match_on = %i[method uri]
end
```

Helper method style:

```ruby
describe "API client" do
  it "fetches users" do
    use_cassette("users/index")
    # ...
  end
end
```

Metadata style:

```ruby
it "fetches users", use_cassette: "users/index" do
  # ...
end
```

To pass match options per example:

```ruby
it "matches body", use_cassette: "users/index", cassette_options: { match_on: %i[method uri body] } do
  # ...
end
```

## Migration Guide

Before:

```ruby
it "fetches users" do
  VCR.use_cassette("users/index") do
    # ...
  end
end
```

After:

```ruby
it "fetches users", use_cassette: "users/index" do
  # ...
end
```

## Configuration Options

| Option | Default | Description |
| --- | --- | --- |
| `cassettes_dir` | `spec/fixtures/cassettes` | Base directory for cassette files |
| `default_match_on` | `[:method, :uri]` | WebMock matchers to apply |

## Development

After checking out the repo, run `bundle install` to install dependencies. Then run `bundle exec rspec` to execute the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ydah/rspec-cassette.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
