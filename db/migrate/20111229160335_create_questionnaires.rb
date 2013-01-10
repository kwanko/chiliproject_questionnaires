#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class CreateQuestionnaires < ActiveRecord::Migration

  def self.up
    create_table :questionnaires, :force => true do |t|
      t.column :title, :string
      t.column :description, :text
      t.column :starts_on, :date
      t.column :ends_on, :date
      t.column :revival, :integer
      t.column :published, :boolean
      t.column :send_mail_after_recipient_response, :boolean
      t.column :project_id, :integer, :default => 0, :null => false
      t.column :created_by, :integer, :default => 0, :null => false
      t.column :validate_by, :integer, :default => 0, :null => true

      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp

    end
  end

  def self.down
    drop_table :questionnaires
  end
end
