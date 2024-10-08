# frozen_string_literal: true

require_relative "lib/airbased/version"

Gem::Specification.new do |spec|
  spec.name = "airbased"
  spec.version = Airbased::VERSION
  spec.authors = ["Aleks Lokhmutov"]
  spec.email = ["43987794+alokhmutov@users.noreply.github.com"]

  spec.summary = "Ruby interface to the Airtable’s API."
  spec.homepage = "https://github.com/alokhmutov/airbased"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alokhmutov/airbased"
  spec.metadata["changelog_uri"] = "https://github.com/alokhmutov/airbased/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "httparty"

end
