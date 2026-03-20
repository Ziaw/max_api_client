# frozen_string_literal: true

require_relative "lib/max_api_client/version"

Gem::Specification.new do |spec|
  spec.name = "max_api_client"
  spec.version = MaxApiClient::VERSION
  spec.authors = ["Alexandr Zimin"]
  spec.email = ["ziminav@gmail.com"]

  spec.summary = "Ruby client scaffold for Max Bot API"
  spec.description = "Ruby gem for Max Bot API. This repository also embeds the official TypeScript client as a reference implementation for Ruby API parity."
  spec.homepage = "https://github.com/Ziaw/max_api_client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Ziaw/max_api_client"
  spec.metadata["changelog_uri"] = "https://github.com/Ziaw/max_api_client/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
