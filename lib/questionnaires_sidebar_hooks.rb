#-- encoding: UTF-8
# Questionnaires plugin for Chiliproject
# Copyright (C) 2011 Arnauld NYAKU

class QuestionnairesSidebarHooks < Redmine::Hook::ViewListener
  render_on :view_layouts_base_sidebar, :partial => 'questionnaires/infosidebar'
end


