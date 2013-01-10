#-- encoding: UTF-8
# Questionnaire plugin for Chiliproject
# Copyright (C) 2011-2012  Arnauld NYAKU

class QuestionnairesSettingsController < ApplicationController
  unloadable
  
  layout 'base'
  include QuestionnairesSettingsHelper

  before_filter :find_project
  before_filter :authorize

  def new_permission
    questionnaires_users = []
    if params[:questionnaire_user_permission] && request.post?
      attrs = params[:questionnaire_user_permission].dup
      if (user_ids = attrs.delete(:user_ids))
         user_ids.each do |user_id|        
         Group.find(user_id).users.each {|user| questionnaires_users << QuestionnairesUsersPermission.new(attrs.merge(:user_id => user.id, :inherited_from => user_id)) if @project.principals.collect(&:id).include?(user.id) and !@project.q_users.collect(&:id).include?(user.id)} if isGroup? user_id
         questionnaires_users << QuestionnairesUsersPermission.new(attrs.merge(:user_id => user_id))
         end
      else
        questionnaires_users << QuestionnairesUsersPermission.new(attrs)
      end
      @project.questionnaires_permissions << questionnaires_users
    end
    respond_to do |format|
       if questionnaires_users.present? && questionnaires_users.all? {|q| q.valid? }

        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'questionnaires_settings', :id => @project }

        format.js {
          render(:update) {|page|
            page.replace_html "tab-content-questionnaires_settings", :partial => 'questionnaires_settings/manage_settings'
            page << 'hideOnLoad()'
            questionnaires_users.each {|questionnaire_user| page.visual_effect(:highlight, "questionnaire_user_permission-#{questionnaire_user.id}") }
          }
        }
      else
        format.js {
          render(:update) {|page|
            errors = questionnaires_users.collect {|q|
              q.errors.full_messages
            }.flatten.uniq

            page.alert(l(:notice_failed_to_save_permissions, :errors => errors.join(', ')))
          }
        }

      end
    end
  end

  def edit_permission
    @questionnaire_user_permission =  QuestionnairesUsersPermission.find(params[:id_perm])
    if request.post? and @questionnaire_user_permission.update_attributes(params[:questionnaire_user_permission])
       # Mettre a jour les users si l'user en cours est un groupe
       QuestionnairesUsersPermission.find_all_by_inherited_from(@questionnaire_user_permission.user_id).each {|qup| qup.update_attributes(params[:questionnaire_user_permission]) } if @questionnaire_user_permission.inherited_from == 0
       
       respond_to do |format|
          format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'questionnaires_settings', :id => @project }
          format.js {
            render(:update) {|page|
              page.replace_html "tab-content-questionnaires_settings", :partial => 'questionnaires_settings/manage_settings'
              page << 'hideOnLoad()'
              page.visual_effect(:highlight, "questionnaire_user_permission-#{@questionnaire_user_permission.id}")
            }
          }
        end
    end
  end

  def destroy_permission
    @questionnaire_user_permission =  QuestionnairesUsersPermission.find(params[:id_perm])
    if request.post?
      # Supprimer les users si on est en train de supprimer un groupe
      QuestionnairesUsersPermission.delete_all(:inherited_from => @questionnaire_user_permission.user_id) if @questionnaire_user_permission.inherited_from == 0
      @questionnaire_user_permission.destroy
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'questionnaires_settings', :id => @project }
      format.js { render(:update) {|page|
          page.replace_html "tab-content-questionnaires_settings", :partial => 'questionnaires_settings/manage_settings'
          page << 'hideOnLoad()'
        }
      }
    end
  end

  def validate_options
    @questionnaires_option = QuestionnairesOption.find_or_create_by_project_id(:project_id => @project.id)
    @questionnaires_option.user_id = User.current.id
    @questionnaires_option.must_have_validators = params[:must_have_validators]
    if request.post? and @questionnaires_option.save
      respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'questionnaires_settings', :id => @project }
        format.js { render(:update) {|page|
            page.replace_html "tab-content-questionnaires_settings", :partial => 'questionnaires_settings/manage_settings'
            page << 'hideOnLoad()'
          }
        }
      end
    end
  end

  def autocomplete_for_questionnaire_user
    s = "%#{params[:q].to_s.strip.downcase}%"
    @questionnaires_principals = @project.principals.find(:all, :conditions => ["LOWER(login) LIKE :s OR LOWER(firstname) LIKE :s OR LOWER(lastname) LIKE :s OR LOWER(mail) LIKE :s", {:s => s}]) + Group.find(:all, :conditions => ["LOWER(login) LIKE :s OR LOWER(firstname) LIKE :s OR LOWER(lastname) LIKE :s OR LOWER(mail) LIKE :s", {:s => s}]) - @project.q_users
    render :layout => false
  end

private
# Find project of id params[:id]
 def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
 end
end
