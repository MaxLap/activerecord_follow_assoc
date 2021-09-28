require_relative 'lib/active_record_follow_assoc/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "activerecord_follow_assoc"
  spec.version       = ActiveRecordFollowAssoc::VERSION
  spec.authors       = ["Maxime Lapointe"]
  spec.email         = ["hunter_spawn@hotmail.com"]

  spec.summary       = %q{Follow associations within your ActiveRecord queries}

  spec.description   = %q{In ActiveRecord, allows you to query the association of the records that your current query would return. If you need the comments of some posts: `Post.where(...).follow_assoc(:comments)`. You can then chain `where` on the comments.}
  spec.homepage      = "https://github.com/MaxLap/activerecord_follow_assoc"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.1.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/MaxLap/activerecord_follow_assoc"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  lib_files = `git ls-files -z lib`.split("\x0")
  spec.files = [*lib_files, "LICENSE.txt", "README.md"]

  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.1.0"

  spec.add_development_dependency "bundler", ">= 1.15"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", ">= 10.0"

  spec.add_development_dependency "deep-cover"
  spec.add_development_dependency "rubocop", "0.54.0"
  spec.add_development_dependency "simplecov"

  # Useful for the examples
  spec.add_development_dependency "niceql", ">= 0.1.23"

  # Normally, testing with sqlite3 is good enough
  spec.add_development_dependency "sqlite3"

  # Using conditions because someone might not even be able to install the gems
  spec.add_development_dependency "pg" if ENV["CI"] || ENV["ALL_DB"] || ["pg", "postgres", "postgresql"].include?(ENV["DB"])
end
