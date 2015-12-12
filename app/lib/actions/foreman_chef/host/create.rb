module Actions
  module ForemanChef
    module Host
      class Create < Actions::EntryAction

        def plan(host)
          action_subject(host)
          client_exists_in_chef = host.chef_proxy.show_client(host.name)

          sequence do
            if client_exists_in_chef
              plan_action Actions::ForemanChef::Client::Destroy, host.name, host.chef_proxy
            end

            client_creation = plan_action Actions::ForemanChef::Client::Create, host.name, host.chef_proxy
            self.output.update :client => client_creation.output
            # TODO: clarify if needed to trigger finalize
            plan_self
          end
        rescue => e
          Rails.logger.debug "Unable to communicate with Chef proxy, #{e.message}"
          Rails.logger.debug e.backtrace.join("\n")
          raise ::ForemanChef::ProxyException.new(N_('Unable to communicate with Chef proxy, %s' % e.message))
        end

        def run
        end

        def finalize
          binding.pry
        end

        def humanized_name
          _("Create client")
        end

        def humanized_input
          input[:name]
        end
      end
    end
  end
end

