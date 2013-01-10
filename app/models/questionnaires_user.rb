#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuestionnairesUser < ActiveRecord::Base
  unloadable
  
  ROLES = ['RECIPIENT','RESPONSES_VIEWER']

  belongs_to :questionnaire
  belongs_to :user
  
  validates_presence_of :role, :in => ROLES
end
