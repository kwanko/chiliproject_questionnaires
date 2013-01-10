#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2011-2012  Arnauld NYAKU

require_dependency 'projects_helper'

module QuestionnairesProjectsHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, ProjectsHelperMethodsQuestionnaires)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :project_settings_tabs, :questionnaires
    end

  end
end

module ProjectsHelperMethodsQuestionnaires
  def project_settings_tabs_with_questionnaires
    tabs = project_settings_tabs_without_questionnaires
    action = {:name => 'questionnaires_settings', :controller => 'questionnaires_settings', :action => :manage_settings, :partial => 'questionnaires_settings/manage_settings', :label => :label_questionnaire_plural}
    tabs << action if User.current.allowed_to?(action, @project)

    tabs
  end

  
end

ProjectsHelper.send(:include, QuestionnairesProjectsHelperPatch)
