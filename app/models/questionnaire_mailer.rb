#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2011-2012  : C2B NETAFFILIATION SA
# Author : Arnauld NYAKU


class QuestionnaireMailer < Mailer
  
  def notification_to_validator(questionnaire)
    redmine_headers 'Project' => questionnaire.project.identifier,
                    'questionnaire-Id' => questionnaire.id,
                    'questionnaire-Author' => questionnaire.author.login

    recipients questionnaire.validator.mail
    cc questionnaire.author.mail
    
    subject "[#{questionnaire.project.name} - #{l(:label_questionnaire_new, :locale => questionnaire.send_mail_language)} - #{l(:label_questionnaire, :locale => questionnaire.send_mail_language)}##{questionnaire.id}] #{questionnaire.title}"
    body :questionnaire => questionnaire,
         :questionnaire_url => url_for(:controller => 'questionnaires', :action => 'edit', :project_id => questionnaire.project, :id => questionnaire)

    content_type "multipart/alternative"

    render_multipart("questionnaire_add_notification_to_validator", body)
  end

  def notification_to_recipients(questionnaire, state)
    redmine_headers 'Project' => questionnaire.project.identifier,
                   'questionnaire-Id' => questionnaire.id,
                   'questionnaire-Author' => questionnaire.author.login

    cc_addresses = [ questionnaire.author.mail ]
    cc_addresses << questionnaire.validator.mail unless questionnaire.validator.nil?
    
    recipients recipients_mails(questionnaire).compact.uniq
    cc cc_addresses

    subject "[#{questionnaire.project.name} - #{l(:label_questionnaire_new, :locale => questionnaire.send_mail_language)} - #{l(:label_questionnaire, :locale => questionnaire.send_mail_language)}##{questionnaire.id}] #{questionnaire.title}"
    body :project => questionnaire.project,
         :questionnaire => questionnaire,
         :questionnaire_url => url_for(:controller => 'questionnaires', :action => 'reply', :project_id => questionnaire.project, :questionnaire_id => questionnaire),
         :state => state
       
    content_type "multipart/alternative"

    render_multipart("questionnaire_create_notification_to_recipients", body)

  end

  def notification_after_recipient_replies(questionnaire)
    redmine_headers 'Project' => questionnaire.project.identifier,
                   'questionnaire-Id' => questionnaire.id,
                   'questionnaire-Author' => questionnaire.author.login

    recipients questionnaire.author.mail
    cc questionnaire.validator.mail if questionnaire.validator

    subject "[#{questionnaire.project.name} - #{l(:label_questionnaire_new, :locale => questionnaire.send_mail_language)} - #{l(:label_questionnaire, :locale => questionnaire.send_mail_language)}##{questionnaire.id}] #{questionnaire.title}"
    body :questionnaire => questionnaire,
         :questionnaire_url => url_for(:controller => 'questionnaires', :action => 'show_replies', :project_id => questionnaire.project, :questionnaire_id => questionnaire)

    content_type "multipart/alternative"

    render_multipart("questionnaire_replies_notification_to_creator", body)
  end

  def notification_for_revival_to_recipients(questionnaire,state = 0)
    redmine_headers 'Project' => questionnaire.project.identifier,
                   'questionnaire-Id' => questionnaire.id,
                   'questionnaire-Author' => questionnaire.author.login

    cc_addresses = [ questionnaire.author.mail ]
    cc_addresses << questionnaire.validator.mail unless questionnaire.validator.nil?

    recipients recipients_not_yet_responded_required_question(questionnaire).compact.uniq
    cc cc_addresses

    subject "[#{questionnaire.project.name} - #{l(:label_questionnaire_new, :locale => questionnaire.send_mail_language)} - #{l(:label_questionnaire, :locale => questionnaire.send_mail_language)}##{questionnaire.id}] #{questionnaire.title}"
    body :project => questionnaire.project,
         :questionnaire => questionnaire,
         :questionnaire_url => url_for(:controller => 'questionnaires', :action => 'reply', :project_id => questionnaire.project, :questionnaire_id => questionnaire),
         :state => state
       
    content_type "multipart/alternative"

    render_multipart("questionnaire_revival_notification_to_recipients", body)
  end

  def notifcation_at_end_to_creator(questionnaire)
    redmine_headers 'Project' => questionnaire.project.identifier,
                   'questionnaire-Id' => questionnaire.id,
                   'questionnaire-Author' => questionnaire.author.login

    cc_addresses = [ questionnaire.author.mail ]
    cc_addresses << questionnaire.validator.mail unless questionnaire.validator.nil?

    recipients cc_addresses

    subject "[#{questionnaire.project.name} - #{l(:label_questionnaire_new, :locale => questionnaire.send_mail_language)} - #{l(:label_questionnaire, :locale => questionnaire.send_mail_language)}##{questionnaire.id}] #{questionnaire.title}"
    body :questionnaire => questionnaire,
         :questionnaire_url => url_for(:controller => 'questionnaires', :action => 'show_replies', :project_id => questionnaire.project, :questionnaire_id => questionnaire)

    content_type "multipart/alternative"

    render_multipart("questionnaire_end_notification_to_creator", body)
  end

  private
  def recipients_mails(questionnaire)
    questionnaire.recipients.collect(&:user).collect(&:mail)
  end

  def reponses_viewers_mails(questionnaire)
    questionnaire.reponses_viewers.collect(&:user).collect(&:mail)
  end

  def recipients_not_yet_responded_required_question(questionnaire)
     recipients_emails = []
     questionnaire.recipients.collect(&:user).each do |recipient|
       for question in questionnaire.questions
          recipients_emails << recipient.mail if question.answer_required and question.answer_of(recipient).nil?
       end
     end
     recipients_emails
  end
  
end

