#-- encoding: UTF-8
#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :questionnaires do |questionnaire|
      questionnaire.connect 'reply', :controller => "questionnaires", :action => 'reply', :conditions => {:method => :get}
      questionnaire.connect 'replies', :controller => "questionnaires", :action => 'show_replies'
      questionnaire.connect 'create_replies', :controller => "questionnaires", :action => 'create_replies', :conditions => {:method => :post}
      questionnaire.connect 'replies.:format', :controller => "questionnaires", :action => 'show_replies'
      questionnaire.connect 'replies/:user_id', :controller => "questionnaires", :action => 'show_recipient_replies', :conditions => {:method => :get}
      questionnaire.connect 'publish', :controller => "questionnaires", :action => 'publish', :conditions => {:method => :put}
      questionnaire.connect 'unpublish', :controller => "questionnaires", :action => 'unpublish', :conditions => {:method => :put}
      questionnaire.connect 'preview', :controller => "questionnaires", :action => "preview"
    end
    project.connect 'questionnaires/preview', :controller => "questionnaires", :action => "preview", :conditions => {:method => :post}
  end
end