# frozen_string_literal: true

require_relative "lib/backy/version"

Gem::Specification.new do |spec|
  spec.name = "backy"
  spec.version = Backy::VERSION
  spec.authors = ["Alexey Kharchenko", "Martin Ulleberg", "Pål André Sundt"]
  spec.email = ["akharchenko@gmail.com", "martin.ulleberg@gmail.com", "pal@rubynor.com"]

  spec.summary = "Backy is a powerful and user-friendly database backup gem designed specifically for Ruby on Rails applications. It streamlines the backup process, ensuring your data is safe, secure, and easily retrievable. With its versatile features and easy integration, Backy is the go-to solution for Rails developers looking to protect their valuable information."
  spec.description = "Backy is a comprehensive database backup solution for Ruby on Rails applications, created to help developers manage and safeguard their data with ease. This robust gem offers a wide range of features"
  spec.homepage = "https://rubynor.com"
  spec.required_ruby_version = ">= 2.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rubynor/backy"
  spec.metadata["changelog_uri"] = "https://github.com/rubynor/backy/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.44"
  spec.add_development_dependency "standard", "~> 1.24"
  spec.add_development_dependency "brakeman", "~> 5.4"
  spec.add_development_dependency "rubocop-rspec", "~> 2.18"
  spec.add_development_dependency "rubocop-performance", "~> 1.15"
  spec.add_development_dependency "rubocop-rake", "~> 0.6.0"
  spec.add_development_dependency "timecop", "~> 0.9.6"
  spec.add_development_dependency "activerecord", ">= 4.0"
  spec.add_development_dependency "activesupport", ">= 4.0"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
