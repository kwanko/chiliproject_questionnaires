#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class CreateQuestionnairesQuestions < ActiveRecord::Migration
  def self.up
    create_table :questionnaires_questions, :force => true do |t|
      t.column :entitled, :string
      t.column :nature, :string
      t.column :nature_values, :text
      t.column :answer_required, :boolean
      t.column :position, :integer, :default => 0, :null => false
      t.column :questionnaire_id, :integer, :default => 0, :null => false

      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp

    end
  end

  def self.down
    drop_table :questionnaires_questions
  end
end
