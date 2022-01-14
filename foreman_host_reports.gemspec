require File.expand_path('lib/foreman_host_reports/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_host_reports'
  s.version     = ForemanHostReports::VERSION
  s.metadata    = { 'is_foreman_plugin' => 'true' }
  s.license     = 'GPL-3.0'
  s.authors     = ['Lukas Zapletal']
  s.email       = ['lukas-x@zapletalovi.com']
  s.homepage    = 'https://github.com/theforeman/foreman_host_reports'
  s.summary     = 'Foreman reporting engine'
  s.description = 'Fast and efficient reporting capabilities'

  s.files = Dir['{app,config,db,lib,locale,webpack}/**/*'] + ['LICENSE', 'README.md', 'package.json']
  s.test_files = Dir['test/**/*'] + Dir['webpack/**/__tests__/*.js']

  s.required_ruby_version = '>= 2.5.0'

  # Pin rdoc, which pulls in psych 4.0 since 6.4.0, but
  # Rails 6.0 does not work with psych 4.0 (https://github.com/theforeman/foreman/pull/9012)
  s.add_development_dependency 'rdoc', '< 6.4.0'
end
