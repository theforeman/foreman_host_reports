# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

def read_report(file, override_proxy = "localhost")
  json = File.expand_path(File.join('..', 'snapshots', file), __FILE__)
  json = JSON.parse(File.read(json))
  json["proxy"] = override_proxy
  json.to_s
end
