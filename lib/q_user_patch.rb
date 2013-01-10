#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2011-2012 Arnauld NYAKU

class QUser < ActiveRecord::Base
  unloadable

  set_table_name 'users'
  has_many :questionnaires_permissions, :class_name => 'QuestionnairesUsersPermission', :dependent => :destroy
end
