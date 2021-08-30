require_relative 'lib/active_record_follow_assoc/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "activerecord_follow_assoc"
  spec.version       = ActiveRecordFollowAssoc::VERSION
  spec.authors       = ["Maxime Lapointe"]
  spec.email         = ["hunter_spawn@hotmail.com"]

  spec.summary       = %q{Describe your activerecord query by following associations}
  spec.description   = %q{In ActiveRecord, when building a query, you can now easily switch to querying an association. If you need the comments of some posts, but don't need the posts: `Post.where(...).follow_assoc(:comments)`. You can then chain `where` on the comments.}
  # TODO spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.1.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # TODO spec.metadata["homepage_uri"] = spec.homepage
  #TODO spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #TODO spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
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
