module ForemanHostReports
  class Engine < ::Rails::Engine
    isolate_namespace ForemanHostReports
    engine_name 'foreman_host_reports'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/lib"]

    # Add any db migrations
    initializer 'foreman_host_reports.load_app_instance_data' do |app|
      ForemanHostReports::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_host_reports.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_host_reports do
        requires_foreman '>= 3.2.0'

        apipie_documented_controllers ["#{ForemanHostReports::Engine.root}/app/controllers/api/v2/*.rb"]
        # Add Global files for extending foreman-core components and routes
        register_global_js_file 'global'

        # Add permissions
        security_block :foreman_host_reports do
          permission :view_host_reports, { host_reports: %i[index show auto_complete_search],
                                           'api/v2/host_reports': %i[index show export] }, resource_type: 'HostReport'
          permission :create_host_reports, { 'api/v2/host_reports': [:create] }, resource_type: 'HostReport'
          permission :destroy_host_reports, { 'api/v2/host_reports': [:destroy] }, resource_type: 'HostReport'
        end

        role 'Host reports manager', %i[view_host_reports create_host_reports destroy_host_reports]

        # add menu entry
        menu :top_menu, :host_reports, url: '/host_reports',
          url_hash: { controller: :host_reports, action: :index },
          caption: N_('Host Reports'),
          parent: :monitor_menu,
          before: :reports
      end
    end

    # Include concerns in this config.to_prepare block
    # rubocop:disable Style/RescueStandardError
    config.to_prepare do
      Host::Managed.include ForemanHostReports::HostExtensions
      SmartProxy.include ForemanHostReports::HostExtensions
    rescue => e
      Rails.logger.warn "ForemanHostReports: skipping engine hook (#{e})"
    end
    # rubocop:enable Style/RescueStandardError

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanHostReports::Engine.load_seed
      end
    end

    initializer 'foreman_host_reports.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_host_reports'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
