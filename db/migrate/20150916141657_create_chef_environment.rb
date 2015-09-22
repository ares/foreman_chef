class CreateChefEnvironment < ActiveRecord::Migration
  def up
    create_table :chef_environments do |t|
      t.string :name, :default => '', :null => false
      t.text :description, :default => ''
      t.timestamps
    end

    add_column :hosts, :chef_environment_id, :integer
    add_column :hostgroups, :chef_environment_id, :integer
  end

  def down
    remove_column :hostgroups, :chef_environment_id, :integer
    remove_column :hosts, :chef_environment_id, :integer

    drop_table :chef_environments
  end
end
