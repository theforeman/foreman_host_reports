# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

def read_report(file)
  json = File.expand_path(File.join('..', 'snapshots', file), __FILE__)
  File.read(json)
end
