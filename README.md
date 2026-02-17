# rspec-cassette

Replay test suite's HTTP interactions as WebMock stubs in RSpec.

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

RSpec::Cassette.configure do |config|
  config.cassettes_dir = "spec/fixtures/cassettes"
  config.default_match_on = %i[method uri]
  config.allow_http_connections_when_no_cassette = false
  config.ignore_localhost = true
  config.ignore_hosts = ["selenium-hub", "chromedriver"]
  config.ignore_request { |request| URI(request.uri).port == 9200 }
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

VCR metadata compatibility style:

```ruby
it "fetches users", vcr: true do
  # cassette name is auto-generated from example descriptions
end

it "matches request body", vcr: { cassette_name: "users/index", match_requests_on: %i[method uri body] } do
  # ...
end
```

To pass match options per example:

```ruby
it "matches body", use_cassette: "users/index", cassette_options: { match_on: %i[method uri body] } do
  # ...
end
```

## Network Connection Controls

By default, `rspec-cassette` now blocks outgoing HTTP connections when no cassette is active:

```ruby
RSpec::Cassette.configure do |config|
  config.allow_http_connections_when_no_cassette = false
end
```

Allow passthrough for localhost or specific hosts:

```ruby
RSpec::Cassette.configure do |config|
  config.ignore_localhost = true
  config.ignore_hosts = ["selenium-hub", "chromedriver"]
end
```

Use `ignore_request` for custom conditions:

```ruby
RSpec::Cassette.configure do |config|
  config.ignore_request do |request|
    URI(request.uri).port == 9200
  end
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
| `allow_http_connections_when_no_cassette` | `false` | Allow real HTTP when no cassette is active |
| `ignore_localhost` | `false` | Allow localhost requests while other outgoing requests are blocked |
| `ignore_hosts` | `[]` | Allow specific hosts while other outgoing requests are blocked |
| `ignore_request` | none | Register predicate blocks to allow specific requests |

## Development

After checking out the repo, run `bundle install` to install dependencies. Then run `bundle exec rspec` to execute the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ydah/rspec-cassette.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
