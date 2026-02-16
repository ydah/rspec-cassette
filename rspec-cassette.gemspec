# frozen_string_literal: true

require_relative "lib/rspec/cassette/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-cassette"
  spec.version = RSpec::Cassette::VERSION
  spec.authors = ["Yudai Takada"]
  spec.email = ["t.yudai92@gmail.com"]
  spec.summary = "Replay test suite's HTTP interactions as WebMock stubs in RSpec."
  spec.description = "Load test suite's HTTP interactions and register WebMock stubs for RSpec."
  spec.homepage = "https://github.com/ydah/rspec-cassette"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ydah/rspec-cassette"
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "webmock", ">= 3.14"
  spec.add_dependency "rspec-core", ">= 3.12"
end
