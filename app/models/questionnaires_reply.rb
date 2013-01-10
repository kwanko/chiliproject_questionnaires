#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuestionnairesReply < ActiveRecord::Base
  unloadable
  belongs_to :question, :class_name => "QuestionnairesQuestion", :foreign_key => "question_id"
  belongs_to :questionnaire

  serialize :values

end
