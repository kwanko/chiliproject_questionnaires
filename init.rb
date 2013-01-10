#-- encoding: UTF-8
# questionnaire plugin for Chiliproject
# Copyright (C) 2011-2012  Arnauld NYAKU

require 'redmine'

# require all files in lib
Dir::foreach(File.join(File.dirname(__FILE__), 'lib')) do |file|
  next unless /\.rb$/ =~ file
  require file
end

Redmine::Plugin.register :chiliproject_questionnaires_plugin do
  name 'Chiliproject Questionnaires plugin'
  author 'Arnauld NYAKU'
  description 'This is a questionnaire plugin for Chiliproject'
  version '0.0.1'
  url ''
  author_url 'mailto:arnauld.nyaku@c2bsa.com'

  project_module :questionnaires do
    permission :view_questionnaires, {:questionnaires => [:index, :show]}, :public => true
    permission :add_questionnaire, {:questionnaires => [:new, :edit, :create, :update, :preview, :destroy]}, :require => :member
    permission :valid_questionnaire, {:questionnaires => [:edit, :update, :preview]}, :require => :member
    permission :questionnaires_settings, {:questionnaires_settings => [:manage_settings, :new_permission, :edit_permission, :destroy_permission, :autocomplete_for_questionnaire_user, :validate_options]}, :require => :member
  end

  menu :project_menu, :questionnaires, { :controller => 'questionnaires', :action => 'index' }, :caption => :label_questionnaire_plural, :param => :project_id

  Redmine::Search.available_search_types << 'questionnaires'
end

