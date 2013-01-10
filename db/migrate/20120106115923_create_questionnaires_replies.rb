#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class CreateQuestionnairesReplies < ActiveRecord::Migration
  def self.up
    create_table :questionnaires_replies, :force => true do |t|
      t.column :values, :text
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :question_id, :integer, :default => 0, :null => false
      t.column :questionnaire_id, :integer, :default => 0, :null => false

      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp

    end
  end

  def self.down
    drop_table :questionnaires_replies
  end
end
