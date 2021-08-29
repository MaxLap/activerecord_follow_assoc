require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :generate_run_tests_on_head_workflow do
  require 'yaml'
  config = YAML.load_file('.github/workflows/run_tests.yml')
  config['name'] = 'Test future versions'
  config['env']['CACHE_DEPENDENCIES'] = false
  config['jobs']['test']['strategy']['matrix']['include'] = [
      {'gemfile' => 'gemfiles/rails_head.gemfile', 'ruby_version' => 'head'},
      {'gemfile' => 'gemfiles/rails_head.gemfile', 'ruby_version' => 3.0},
      {'gemfile' => 'gemfiles/rails_6_1.gemfile', 'ruby_version' => 'head'},
  ]

  #
  config['jobs']['test']['continue-on-error'] = true

  header = <<-TXT
# This file is generated from run_tests.yml, changes here will be lost next time `rake` is run
  TXT

  File.write('.github/workflows/run_tests_on_head.yml', header + config.to_yaml)
end

task default: [:generate_run_tests_on_head_workflow, :spec]
