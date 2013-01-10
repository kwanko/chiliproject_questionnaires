#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuestionnairesQuestion < ActiveRecord::Base

 unloadable

 belongs_to :questionnaire
 has_many :replies, :class_name => "QuestionnairesReply", :foreign_key => "question_id", :dependent => :destroy


 NATURES = ['FREE_TEXT','YES_NO','UNIQUE_CHOICE_LIST','MULTI_CHOICE_LIST']

 validates_presence_of :entitled, :allow_blank => false
 validates_presence_of :nature, :in => NATURES
 validates_presence_of :nature_values, :if => Proc.new {|q| ['UNIQUE_CHOICE_LIST','MULTI_CHOICE_LIST'].include?(q.nature)}, :allow_blank => false

 serialize :nature_values

 def answer_of(user)
   QuestionnairesReply.find_by_question_id_and_user_id(self.id,user.id).nil? ? nil : QuestionnairesReply.find_by_question_id_and_user_id(self.id,user.id).values
 end

 def responded_with(response)
   QuestionnairesReply.find_all_by_question_id_and_values(self.id,response)
 end
end
