module ForemanChef
  module EnvironmentsImport
    extend ActiveSupport::Concern

    included do
      alias_method_chain(:import_proxy_links, :chef_proxies)
    end

    def import_proxy_links_with_chef_proxies(hash, classes = nil)
      import_proxy_links_without_chef_proxies(hash, classes = nil) +
      SmartProxy.with_features('Chef').map do |proxy|
        display_link_if_authorized(_("Import from %s chef server") % proxy.name,
                                   hash_for_import_environments_foreman_chef_environments_path(:proxy => proxy),
                                   { :class=>classes, :"data-no-turbolink" => true })
      end.flatten
    end
  end
end
