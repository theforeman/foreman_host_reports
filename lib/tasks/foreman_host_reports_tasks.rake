require 'rake/testtask'

# Tasks
namespace :foreman_host_reports do
  namespace :example do
    desc 'Example Task'
    task task: :environment do
      # Task goes here
    end
  end
end

# Tests
namespace :test do
  desc 'Test ForemanHostReports'
  Rake::TestTask.new(:foreman_host_reports) do |t|
    test_dir = File.expand_path('../../test', __dir__)
    t.libs << 'test'
    t.libs << test_dir
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_host_reports do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_host_reports) do |task|
        task.patterns = ["#{ForemanHostReports::Engine.root}/app/**/*.rb",
                         "#{ForemanHostReports::Engine.root}/lib/**/*.rb",
                         "#{ForemanHostReports::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_host_reports'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_host_reports']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:foreman_host_reports', 'foreman_host_reports:rubocop']
end
