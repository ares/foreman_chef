require 'deface'
require 'foreman_tasks'

module ForemanChef
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inhereits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanChef::Engine.load_seed
      end
    end

    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]

    initializer 'foreman_chef.load_default_settings', :before => :load_config_initializers do
      require_dependency File.expand_path('../../../app/models/setting/foreman_chef.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer "foreman_chef.load_app_instance_data" do |app|
      ForemanChef::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer "foreman_chef.register_paths" do |app|
      ForemanTasks.dynflow.config.eager_load_paths.concat(%W[#{ForemanChef::Engine.root}/app/lib/actions])
    end

    initializer 'foreman_chef.register_plugin', :after => :finisher_hook do |app|
      Foreman::Plugin.register :foreman_chef do
        requires_foreman '>= 1.11'
        allowed_template_helpers :chef_bootstrap

        permission :import_chef_environments, { :environments => [:import_environments] }, :resource_type => 'ChefEnvironment'

        divider :top_menu, :caption => N_('Chef'), :parent => :configure_menu, :after => :common_parameters
        menu :top_menu, :chef_environments,
             url_hash: { controller: 'foreman_chef/environments', action: :index },
             caption: N_('Environments'),
             parent: :configure_menu,
             after: :common_parameters
      end
    end

    initializer 'foreman_chef.chef_proxy_form' do |app|
      ActionView::Base.send :include, ChefProxyForm
      ActionView::Base.send :include, ForemanChef::Concerns::Renderer
    end

    initializer 'foreman_chef.dynflow_world', :before => 'foreman_tasks.initialize_dynflow' do |app|
       ForemanTasks.dynflow.require!
    end

    #Include extensions to models in this config.to_prepare block
    config.to_prepare do
      ::Host::Managed.send :include, ForemanChef::HostExtensions
      ::Hostgroup.send :include, ForemanChef::HostgroupExtensions
      ::Host::Managed.send :include, ChefProxyAssociation
      ::Hostgroup.send :include, ChefProxyAssociation
      ::SmartProxy.send :include, SmartProxyExtensions
      ::FactImporter.register_fact_importer(:foreman_chef, ForemanChef::FactImporter)
      ::FactParser.register_fact_parser(:foreman_chef, ForemanChef::FactParser)
      ::Host::Base.send :include, ForemanChef::Concerns::HostActionSubject
      ::HostsController.send :include, ForemanChef::Concerns::HostsControllerRescuer
      # Renderer Concern needs to be injected to controllers, ForemanRenderer was already included
      (TemplatesController.descendants + [TemplatesController]).each do |klass|
        klass.send(:include, ForemanChef::Concerns::Renderer)
      end
      ::PuppetclassesAndEnvironmentsHelper.send(:include, ForemanChef::EnvironmentsImport)
    end

    config.after_initialize do
      ::Foreman::Renderer.send :include, ForemanChef::Concerns::Renderer
    end
  end
end
