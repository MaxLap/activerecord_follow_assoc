require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# Not using Rake::RDocTask because it won't update things if only the stylesheet changed
desc "Generate documentation for the gem"
task :run_rdoc do
  args = ["rdoc"]
  args << "--template-stylesheets=docs_customization.css"
  args << "--title=activerecord_follow_assoc"
  args << "--output=docs"
  args << "--show-hash"
  args << "lib/active_record_follow_assoc/query_methods.rb"

  Bundler.with_clean_env do
    exit(1) unless system(*args)
  end

  rdoc_css_path = File.join(__dir__, "docs/css/rdoc.css")
  rdoc_css = File.read(rdoc_css_path)
  # A little bug in rdoc's generated stuff... the urls in the CSS are wrong!
  rdoc_css.gsub!("url(images", "url(../images")
  File.write(rdoc_css_path, rdoc_css)

  query_methods_path = File.join(__dir__, "docs/ActiveRecordFollowAssoc/QueryMethods.html")
  query_methods = File.read(query_methods_path)
  # A little bug in rdoc's generated stuff. The links to headings are broken!
  query_methods.gsub!(/#(label[^"]+)/, "#module-ActiveRecordWhereAssoc::RelationReturningMethods-\\1")
  File.write(query_methods_path, query_methods)
end

task :generate_run_tests_on_head_workflow do
  require 'yaml'
  config = YAML.load_file('.github/workflows/run_tests.yml')
  config['name'] = 'Test future versions'
  config['env']['CACHE_DEPENDENCIES'] = false
  config['jobs']['test']['strategy']['matrix']['include'] = [
      {'gemfile' => 'gemfiles/rails_head.gemfile', 'ruby_version' => 'head'},
      {'gemfile' => 'gemfiles/rails_head.gemfile', 'ruby_version' => 3.2},
      {'gemfile' => 'gemfiles/rails_7_1.gemfile', 'ruby_version' => 'head'},
  ]

  #
  config['jobs']['test']['continue-on-error'] = true

  header = <<-TXT
# This file is generated from run_tests.yml, changes here will be lost next time `rake` is run
  TXT

  File.write('.github/workflows/run_tests_on_head.yml', header + config.to_yaml)
end

task test: :spec

task default: [:generate_run_tests_on_head_workflow, :run_rdoc, :spec]
