#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class CreateQuestionnairesUsersPermissions < ActiveRecord::Migration

  def self.up
    create_table :questionnaires_users_permissions, :force => true do |t|
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :project_id, :integer, :default => 0, :null => false
      t.column :permissions, :text
      
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp

    end
  end

  def self.down
    drop_table :questionnaires_users_permissions
  end
end
