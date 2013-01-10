#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class CreateQuestionnairesOptions < ActiveRecord::Migration
  def self.up
    create_table :questionnaires_options, :force => true do |t|
      t.column :project_id, :integer, :default => 0, :null => false
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :must_have_validators, :boolean, :default => false, :null => false

      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp

    end
  end

  def self.down
    drop_table :questionnaires_options
  end
end
