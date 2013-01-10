#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2011-2012 Arnauld NYAKU

module QuestionnairesProjectPatch
  def self.included(base) # :nodoc: 
    base.class_eval do
       unloadable
       has_many :questionnaires_permissions, :class_name => 'QuestionnairesUsersPermission', :dependent => :destroy
       has_many :q_users, :through => :questionnaires_permissions, :source => :q_user
       has_one :questionnaires_option


      def q_validators
         self.questionnaires_permissions.all(:conditions => "permissions like '%valid_questionnaire%'").collect(&:q_user)
      end
    end
  end
end

require 'dispatcher'

Dispatcher.to_prepare do
  Project.send(:include, QuestionnairesProjectPatch)
end


