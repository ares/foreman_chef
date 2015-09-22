module ForemanChef
  class EnvironmentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch

    def import_environments
      opts = params[:proxy].blank? ? {} : {:url => SmartProxy.find(params[:proxy]).url}
      opts[:env] = params[:env] unless params[:env].blank?
      @importer = ChefServerImporter.new(opts)
      @changed = @importer.changes
    end

    def obsolete_and_new
      if (errors = ChefServerImporter.new.obsolete_and_new(params[:changed])).empty?
        notice _("Successfully updated environments")
      else
        error _("Failed to update environments: %s") % errors.to_sentence
      end
      redirect_to environments_path
    end

    def index
      @chef_environments = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    end

    protected

    def model_of_controller
      ChefEnvironment
    end

    def controller_permission
      'chef_environments'
    end

    def action_permission
      case params[:action]
        when 'import_environments'
          'import'
        else
          super
      end
    end
  end
end
