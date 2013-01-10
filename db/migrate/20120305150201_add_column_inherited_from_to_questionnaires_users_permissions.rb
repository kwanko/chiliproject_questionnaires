#-- encoding: UTF-8
class AddColumnInheritedFromToQuestionnairesUsersPermissions < ActiveRecord::Migration
 def self.up
   add_column :questionnaires_users_permissions, :inherited_from, :integer, :default => 0
 end

 def self.down
   remove_column :questionnaires_users_permissions, :inherited_from
 end
end
