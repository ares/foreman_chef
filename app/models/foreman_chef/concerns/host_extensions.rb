module ForemanChef
  module Concerns
    module HostExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :set_hostgroup_defaults, :chef_attributes
        attr_accessible :chef_private_key

        # even with autosave, save is called only if there's some change in attributes
        has_one :cached_run_list, :autosave => true, :class_name => 'ForemanChef::CachedRunList', :foreign_key => :host_id
        attr_accessible :run_list
      end

      def run_list
        self.cached_run_list || ForemanChef::CachedRunList.parse(['role[default]'], self.build_cached_run_list)
      end

      def run_list=(run_list)
        # returns CachedRunList instance, if there was one for host, return that one with modified attributes
        @run_list = ForemanChef::CachedRunList.parse(run_list, self.cached_run_list)
        # this ensures that host#save will save the cached run list too
        self.cached_run_list = @run_list
      end

      def set_hostgroup_defaults_with_chef_attributes
        set_hostgroup_defaults_without_chef_attributes
        return unless hostgroup
        assign_hostgroup_attributes(['chef_proxy_id', 'chef_environment_id'])
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :run_list
end
