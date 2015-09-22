module ForemanChef
  class ChefEnvironment < ActiveRecord::Base
    include Authorizable
    extend FriendlyId
    friendly_id :name

    has_many :hosts, :class_name => '::Host::Managed'
    has_many :hostgroups, :class_name => '::Hostgroup'

    validates :name, :uniqueness => true, :presence => true, :format => { :with => /\A[\w\d\.]+\z/, :message => N_('is alphanumeric and cannot contain spaces') }

    scoped_search :on => :name, :complete_value => true
    scoped_search :in => :hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup
    scoped_search :in => :hosts, :on => :name, :complete_value => true, :rename => :host


    def self.humanize_class_name(_name = nil)
      _('Chef environment')
    end

    def self.permission_name(action)
      "#{action}_chef_environments"
    end
  end
end
