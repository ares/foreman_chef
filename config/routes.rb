Rails.application.routes.draw do

  namespace :foreman_chef do
    resources :environments, :only => [:index] do
      collection do
        get :import_environments
        post :obsolete_and_new
      end
    end
  end

end
