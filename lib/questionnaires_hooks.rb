#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2012 Arnauld NYAKU

class QuestionnairesHooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
        css = stylesheet_link_tag 'questionnaires', :plugin => 'chiliproject_questionnaires'
        css += stylesheet_link_tag 'modalbox', :plugin => 'chiliproject_questionnaires'
        js = javascript_include_tag 'questionnaires', :plugin => 'chiliproject_questionnaires'
        js += javascript_include_tag 'modalbox', :plugin => 'chiliproject_questionnaires'
        js += javascript_include_tag 'builder', :plugin => 'chiliproject_questionnaires'
        css + js
    end
end