#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2008-2009  Arnauld NYAKU

class QuestionnairesController < ApplicationController

  unloadable
  
  layout 'base'
  
  include Redmine::Export::PDF
  include QuestionnairesHelper

  before_filter :find_project
  before_filter :questionnaire_create_authorize, :only => [:new, :create, :update]
  before_filter :questionnaire_valid_authorize, :only => [:edit, :update]
  before_filter :find_questionnaires, :except => [:preview]

  
  def index
  end

  def new
    @questionnaire = Questionnaire.new
  end

  def create
   @questionnaire = Questionnaire.new(:project_id => @project.id, :created_by => User.current.id)
    if request.post?
      # Get all members of project like recipients
       recipients = []
       if params[:all_members_for_recipients] and params[:all_members_for_recipients] == "1"
         recipients = @project.users.active.collect(&:id)
       elsif params[:recipients]
         recipients = principals_to_users(params[:recipients])
       end

       responses_viewers = []
       if params[:all_members_for_responses_viewers] and params[:all_members_for_responses_viewers] == "1"
         responses_viewers = @project.users.active.collect(&:id)
       elsif params[:all_recipients]
         responses_viewers = recipients
       elsif params[:responses_viewers]
         responses_viewers = principals_to_users(params[:responses_viewers])
       end

       @questionnaire.attributes = params[:questionnaire]

       recipients.each {|recipient| @questionnaire.recipients << QuestionnairesUser.new(:user_id => recipient, :role => 'RECIPIENT')} if recipients.any?
       responses_viewers.each {|responses_viewer| @questionnaire.recipients << QuestionnairesUser.new(:user_id => responses_viewer, :role => 'RESPONSES_VIEWER')} if responses_viewers.any?
    end

    respond_to do |format|
      if must_have_validator?(@project) and !@questionnaire.validate_by.is_a?(Integer)
         format.js {
            render(:update) {|page|  page.alert(l(:notice_must_have_validator))}
         }
      elsif must_have_validator?(@project) and @questionnaire.published and @questionnaire.created_by = User.current.id
         format.js {
            render(:update) {|page|  page.alert(l(:notice_can_be_published))}
         }
      else
         if @questionnaire.save
          # Send an email to a validator
          QuestionnaireMailer.deliver_notification_to_validator(@questionnaire) if @questionnaire.validate_by and !@questionnaire.validate_by.zero?
          
          # Send an email to recipients if questionnaire is published 
          QuestionnaireMailer.deliver_notification_to_recipients(@questionnaire, 0) if @questionnaire.published

          format.html { redirect_to :controller => 'questionnaires', :action => 'index', :project_id => @project }
          format.js { flash[:notice] = l(:notice_successful_create)
                      render(:update) {|page| page.redirect_to project_questionnaires_path(@project)}
          }
        else
          format.js {
            render(:update) {|page|
              errors = @questionnaire.errors.full_messages.flatten.uniq
              page.alert(l(:notice_failed_to_save_questionnaire, :errors => errors.join(', ')))
            }
          }
        end
      end
    end
  end

  def show
    @questionnaire = Questionnaire.find(params[:id])
    respond_to do |format|
      format.html { render :template => 'questionnaires/show.html.erb', :layout => !request.xhr? }
      format.pdf  { send_data(questionnaire_to_pdf(@questionnaire), :type => 'application/pdf', :filename => "#{@project}-questionnaire-#{@questionnaire.id}.pdf") }
    end
    rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def edit
    @questionnaire = @my.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    
    if request.put?
      # Get all members of project like recipients
       recipients = []
       if params[:all_members_for_recipients] and params[:all_members_for_recipients] == "1"
         recipients = @project.users.active.collect(&:id)
       elsif params[:recipients]
         recipients = principals_to_users(params[:recipients])
       end

       responses_viewers = []
       if params[:all_members_for_responses_viewers] and params[:all_members_for_responses_viewers] == "1"
         responses_viewers = @project.users.active.collect(&:id)
       elsif params[:all_recipients]
         responses_viewers = recipients
       elsif params[:responses_viewers]
         responses_viewers = principals_to_users(params[:responses_viewers])
       end
       
    respond_to do |format|
        if must_have_validator?(@project) and params[:questionnaire][:validate_by].blank?
         format.js {
            render(:update) {|page|  page.alert(l(:notice_must_have_validator))}
         }
      else
         if @questionnaire.update_attributes(params[:questionnaire])
           # Delete all old recipients
            @questionnaire.recipients.destroy_all
            recipients.each {|recipient| @questionnaire.recipients.create(:user_id => recipient, :role => 'RECIPIENT')} if recipients.any?
          # Delete all old recipients
            @questionnaire.responses_viewers.destroy_all
            responses_viewers.each {|responses_viewer| @questionnaire.responses_viewers.create(:user_id => responses_viewer, :role => 'RESPONSES_VIEWER') } if responses_viewers.any?

         # Send a mail to a validator
            QuestionnaireMailer.deliver_notification_to_validator(@questionnaire) if @questionnaire.validate_by and !@questionnaire.validate_by.zero?

         # Send an email to recipients if questionnaire is published
            QuestionnaireMailer.deliver_notification_to_recipients(@questionnaire, 0) if @questionnaire.published

            format.html { redirect_to :controller => 'questionnaires', :action => 'index', :project_id => @project }
            format.js { flash[:notice] = l(:notice_successful_update)
                        render(:update) {|page| page.redirect_to project_questionnaires_path(@project)}
          }
        else
            format.html { render :edit }
            format.js {
             render(:update) {|page|
              errors = @questionnaire.errors.full_messages.flatten.uniq
              page.alert(l(:notice_failed_to_update_questionnaire, :errors => errors.join(', ')))
            }
          }
         end
        end
      end
    end
  end

  def destroy
    @questionnaire = Questionnaire.find(params[:id])
    if request.delete?
      @questionnaire.destroy
      redirect_to project_questionnaires_path(@project)
    end
  end

  def publish
    @questionnaire = @my.find(params[:questionnaire_id])

    respond_to do |format|
      if @questionnaire.update_attribute(:published, true)
         # Send an email to recipients if questionnaire is published
          QuestionnaireMailer.deliver_notification_to_recipients(@questionnaire, 0) if @questionnaire.published

         format.js { render(:update) {|page| page.redirect_to project_questionnaires_path(@project)} }
      else
         format.js { render(:update) {|page| page.alert(l(:notice_can_not_published_questionnaire))}}
      end
    end
  end

 def unpublish
    @questionnaire = @my.find(params[:questionnaire_id])
    
    respond_to do |format|
      if @questionnaire.update_attribute(:published, false)
        # Send an email to recipients if questionnaire is unpublished
         QuestionnaireMailer.deliver_notification_to_recipients(@questionnaire, 1) if !@questionnaire.published

         format.js { render(:update) {|page| page.redirect_to project_questionnaires_path(@project)} }
      else
         format.js { render(:update) {|page| page.alert(l(:notice_can_not_unpublished_questionnaire))}}
      end
    end
  end

  def reply
    @questionnaire = @currents.find(params[:questionnaire_id])
    rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def create_replies
    @questionnaire = @currents.find(params[:questionnaire_id])
    if request.post?
      # Chercher si toutes les questions obligatoires ont une réponse
       erreur = false
       for q in @questionnaire.questions
         if q.answer_required? and !params['question_' + q.id.to_s]
          erreur = true
          @questionnaire.errors.add(:values, :notice_required_question_values_cant_be_blank)
          break;
         end
       end
      respond_to do |format|
         if erreur
           format.html {render :action => "reply"}
           format.js {render(:update) {|page|
                                       page.alert(l(:notice_required_question_values_cant_be_blank))
                      }}
         else
           for question in @questionnaire.questions
             areply = QuestionnairesReply.find_or_create_by_questionnaire_id_and_question_id_and_user_id(:questionnaire_id => @questionnaire.id, :question_id => question.id, :user_id => User.current.id)
             if question.nature == "MULTI_CHOICE_LIST"
               areply.values = params['question_' + question.id.to_s].nil? ? nil : params['question_' + question.id.to_s].join("||")
             else
               areply.values = params['question_' + question.id.to_s] if params['question_' + question.id.to_s]
             end
             areply.save
           end
           
           # Envoyer un mail au créateur ou au validateur si ce dernier a choiside recevoir un mail après réponse d'un destinataire
           QuestionnaireMailer.deliver_notification_after_recipient_replies(@questionnaire) if @questionnaire.send_mail_after_recipient_response

           format.html {redirect_to(:controller => 'questionnaires', :action => 'index', :project_id => @project, :tab => 'currents')}
           format.js {render(:update) {|page|
              flash[:notice] = l(:notice_successful_create)
              page.redirect_to url_for(:controller => 'questionnaires', :action => 'index', :project_id => @project, :tab => 'currents')}}
         end
      end
    end
  end

  def show_replies
    begin
      @questionnaire = Questionnaire.find(params[:questionnaire_id])
      @questions = @questionnaire.questions.find(:all, :conditions => "nature != 'FREE_TEXT'")

      viewchoosed = "globalview"
      viewchoosed = params[:viewchoosed] if params[:viewchoosed]
      respond_to do |format|
        format.html {}
        format.js {
          render(:update) {|page|
            conditions = ''
            case viewchoosed
            when "globalview"
              conditions += "FREE_TEXT|" if params[:FREE_TEXT]
              conditions += "YES_NO|" if params[:YES_NO]
              conditions += "UNIQUE_CHOICE_LIST|" if params[:UNIQUE_CHOICE_LIST]
              conditions += "MULTI_CHOICE_LIST|" if params[:MULTI_CHOICE_LIST]
              conditions = conditions.split("|")
              @questions = conditions.any? ? @questionnaire.questions.find_all_by_nature(conditions) : @questionnaire.questions
              page.replace_html "replies_view", :partial => viewchoosed, :object => @questions
            when "respondentsview"
              conditions = params[:recipients] if params[:recipients]
              @recipients = conditions.any? ? @questionnaire.recipients.find_all_by_user_id(conditions) : @questionnaire.recipients
              page.replace_html "replies_view", :partial => viewchoosed, :object => @recipients
            when "questionsview"
              conditions = params[:questions] if params[:questions]
              @questions = conditions.any? ? @questionnaire.questions.find_all_by_id(conditions) : @questionnaire.questions
              page.replace_html "replies_view", :partial => viewchoosed, :object => @questions
            end
            page << 'hideOnLoad()'
            }
          }
        format.csv { send_data(questionnaire_to_csv(@questionnaire), :type => 'text/csv; charset=utf-8; header=present', :filename => "#{@project}-questionnaire-#{@questionnaire.id}.csv")}
      end
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end


  def show_recipient_replies
    begin
      @questionnaire = Questionnaire.find(params[:questionnaire_id])
      @user = User.find(params[:user_id])
      render :layout => false
    rescue ActiveRecord::RecordNotFound
      render_404 :layout => false
    end
  end

  def preview
    render :partial => "preview", :locals => {:questionnaire => params[:questionnaire]}
  end

private
# Find project of id params[:id]
   def find_project
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

   def questionnaire_create_authorize(ctrl = params[:controller], action = params[:action], global = false)
      User.current.allowed_to?({:controller => ctrl, :action => action}, @project, :global => global) ? true : deny_access unless is_allowed_to_create_questionnaire?(User.current, @project)
   end

   def questionnaire_valid_authorize(ctrl = params[:controller], action = params[:action], global = false)
      User.current.allowed_to?({:controller => ctrl, :action => action}, @project, :global => global) or is_allowed_to_create_questionnaire?(User.current, @project) ? true : deny_access unless is_allowed_to_valid_questionnaire?(User.current, @project)
   end

   def find_questionnaires
      @my = Questionnaire.my(@project)
      @currents = Questionnaire.currents(@project)
      @finished = Questionnaire.finished(@project)
   end

   def must_have_validator?(project)
      QuestionnairesOption.find_by_project_id(project.id).nil? ? nil : QuestionnairesOption.find_by_project_id(project.id).must_have_validators
   end

 # ANY
 # Tranformer toutes les sélections (groupes ou users) en users dans un tableau
 #   @principals : groupes et users
   def principals_to_users(principals)
     users = []
     principals.each do |principal|
        users.push(Principal.find(principal.to_i).type == "Group" ? Group.find(principal.to_i).users.active.collect(&:id) : principal.to_i)
     end
     users.flatten.uniq.sort
   end

end