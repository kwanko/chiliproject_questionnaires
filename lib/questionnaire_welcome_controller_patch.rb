#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2011 Arnauld NYAKU

module QuestionnaireWelcomeControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      alias_method_chain :index, :reload
    end
  end
  module InstanceMethods
    def index_with_reload
      index_without_reload
      system('touch tmp/restart.txt')
    end
  end
end

require 'dispatcher'

Dispatcher.to_prepare do
  WelcomeController.send(:include, QuestionnaireWelcomeControllerPatch)
end
