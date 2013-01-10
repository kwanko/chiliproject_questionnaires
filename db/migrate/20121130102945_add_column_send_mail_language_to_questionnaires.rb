#-- encoding: UTF-8

class AddColumnSendMailLanguageToQuestionnaires < ActiveRecord::Migration
 def self.up
   add_column :questionnaires, :send_mail_language, :string
 end

 def self.down
   remove_column :questionnaires, :send_mail_language
 end
end
