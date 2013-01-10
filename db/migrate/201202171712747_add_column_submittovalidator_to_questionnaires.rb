#-- encoding: UTF-8

class AddColumnSubmittovalidatorToQuestionnaires < ActiveRecord::Migration
 def self.up
   add_column :questionnaires, :submit_to_validator, :boolean, :default => 0
 end

 def self.down
   remove_column :questionnaires, :submit_to_validator
 end
end
