#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuestionnairesOption < ActiveRecord::Base
  unloadable

  belongs_to :q_user, :foreign_key => 'user_id'
  belongs_to :project

end
