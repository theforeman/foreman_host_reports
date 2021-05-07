module Fhr
  class Engine < ::Rails::Engine
    isolate_namespace Fhr
    engine_name 'foreman_host_reports'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/lib"]

    # Add any db migrations
    initializer 'foreman_host_reports.load_app_instance_data' do |app|
      Fhr::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_host_reports.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_host_reports do
        requires_foreman '>= 2.4.0'

        # Add Global files for extending foreman-core components and routes
        register_global_js_file 'global'

        # Add permissions
        security_block :foreman_host_reports do
          permission :view_foreman_host_reports, { :'foreman_host_reports/example' => [:new_action],
                                                      :'react' => [:index] }
        end

        # Add a new role called 'Discovery' if it doesn't exist
        role 'ForemanHostReports', [:view_foreman_host_reports]

        # add menu entry
        sub_menu :top_menu, :plugin_template, icon: 'pficon pficon-enterprise', caption: N_('Plugin Template'), after: :hosts_menu do
          menu :top_menu, :welcome, caption: N_('Welcome Page'), engine: Fhr::Engine
          menu :top_menu, :new_action, caption: N_('New Action'), engine: Fhr::Engine
        end

        # add dashboard widget
        widget 'foreman_host_reports_widget', name: N_('Foreman plugin template widget'), sizex: 4, sizey: 1
      end
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do

      begin
        Host::Managed.send(:include, Fhr::HostExtensions)
        HostsHelper.send(:include, Fhr::HostsHelperExtensions)
      rescue => e
        Rails.logger.warn "ForemanHostReports: skipping engine hook (#{e})"
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        Fhr::Engine.load_seed
      end
    end

    initializer 'foreman_host_reports.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_host_reports'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
