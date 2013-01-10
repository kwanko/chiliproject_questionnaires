#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

module QuestionnairesSettingsHelper
  def isGroup?(group_id)
    Principal.find(group_id).is_a?(Group)
  end
end

