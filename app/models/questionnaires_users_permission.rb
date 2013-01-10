#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuestionnairesUsersPermission < ActiveRecord::Base
  unloadable
  
  belongs_to :q_user, :foreign_key => 'user_id'
  belongs_to :project


  serialize :permissions, Array

  PERMISSIONS = ['add_questionnaire', 'valid_questionnaire']
  
  validates_presence_of :permissions, :in => PERMISSIONS

  
  def self.user_perms(project, user)
     find(:first, :conditions => [ "? = project_id AND ? = user_id", project.id, user.id]).permissions
  end

  def deletable?
    self.inherited_from == 0
  end



end
