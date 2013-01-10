#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

module QuestionnairesHelper
  include ApplicationHelper
 # create the tabs of the questionnaire index page.
 def questionnaires_tabs
   tabs = [{:name => 'my', :controller => 'questionnaires_settings', :action => :manage_settings, :partial => 'questionnaires/my', :label => :label_my},
           {:name => 'currents', :controller => 'questionnaires_settings', :action => :manage_settings, :partial => 'questionnaires/currents', :label => :label_currents},
           {:name => 'finished', :controller => 'questionnaires_settings', :action => :manage_settings, :partial => 'questionnaires/finished', :label => :label_finished}
          ]
 end

 # Create a link if Current user is allowed to do the following action
 # use to create the new questionnaire link
 def link_to_if_authorized_create_questionnaire(project, name, options = {}, html_options = nil, *parameters_for_method_reference)
     is_allowed_to_create_questionnaire?(User.current, project) ? link_to(name, options, html_options, *parameters_for_method_reference) : link_to_if_authorized(name, options, html_options, *parameters_for_method_reference)
 end
# Check if Current user is allowed to create a questionnaire
# Take a user and a project
# return true or false
 def is_allowed_to_create_questionnaire?(user, project)
   q = QuestionnairesUsersPermission.find_by_user_id_and_project_id(user.id, project.id)
   p = q.nil? ? [] : q.permissions
   return p.include?("add_questionnaire") ? true : false
 end

# Check if Current user is allowed to valid a questionnaire
# Take a user and a project
# return true or false
 def is_allowed_to_valid_questionnaire?(user, project)
   q = QuestionnairesUsersPermission.find_by_user_id_and_project_id(user.id, project.id)
   p = q.nil? ? [] : q.permissions
   return p.include?("valid_questionnaire") ? true : false
 end


def chosen_select_tag(name, defaulttext, project, questionnaires_users, myid = '')
    s = "<select data-placeholder='#{defaulttext}' style='width:450px;' class='chzn-select' id='#{myid}' multiple name='#{name}'>"

    project.principals.active.sort.each do |user|
      s << "<option value='#{user.id}' #{questionnaires_users.include?(user.id) ? 'selected=selected' : ''}>#{h user}</option>"
    end
    s << "</select>"
 end

 def options_for_nature()
   o = "<option value=''></option>"
   QuestionnairesQuestion::NATURES.each do |n|
     o << "<option value='#{n}'> #{l 'label_' + n.downcase}</option>"
   end
   o
 end
#
#
 def add_question_link(name, myclass)
  link_to_function(name, :class => myclass) do |page|
    page.insert_html :top, :questions, :partial => 'question', :locals => {:f => builder, :question => QuestionnairesQuestion.new}
  end
 end

#
#
  def link_to_remove_question_fields(name, f, myclass, message)
    f.hidden_field(:_destroy) + link_to_function(name, "if (confirm('#{message}')) remove_question_fields(this);", :class => myclass)
  end

#
#
  def link_to_add_question_fields(name, f, myclass)
    new_object = QuestionnairesQuestion.new
    fields = f.fields_for(:questions, new_object, :child_index => "new_question") do |builder|
      render("question", :f => builder)
    end
    link_to_function(name, h("add_question_fields('#{escape_javascript(fields)}')"), :class => myclass)
  end

# Generates responses according to the nature of the question
# in : object => question
# out : string => o
  def generate_reply_options_for(question)
    val = question.id.nil? ? nil : question.answer_of(User.current)
    o = ''
    case question.nature
    when "FREE_TEXT"
      o << text_area_tag('question_' + question.id.to_s, val, :rows => 5, :cols => 100)
    when "YES_NO"
      2.times {|v| o << "<label class='block'>" + radio_button_tag('question_' + question.id.to_s, 1-v, val.to_s == (1-v).to_s); o << label_tag(1-v==1 ? l(:general_text_Yes) : l(:general_text_No)) + "</label>"}
    when "UNIQUE_CHOICE_LIST"
      question.nature_values.split("\n").collect{ |v| o << "<label class='block'>" + radio_button_tag('question_' + question.id.to_s, v, val == v); o << label_tag('question_' + question.id.to_s, v) + "</label>"}
    when "MULTI_CHOICE_LIST"
      vals = val.nil? ? [] : val.split("||")
      question.nature_values.split("\n").collect{ |v| o << "<label class='block'>" + check_box_tag('question_' + question.id.to_s + '[]', v, vals.include?(v)); o << label_tag('question_' + question.id.to_s, v) + "</label>"}
    else
    end
    o
  end

 # Transforms the text of the answer before displaying
 # in : object => question, string => values
 # out : string => v
  def pretty_values(question, values)
    v = ""
    unless values.nil?
      if question.nature == "YES_NO"
         v = values == "0" ? l(:general_text_No) : l(:general_text_Yes)
      elsif question.nature == "MULTI_CHOICE_LIST"
         v = values.gsub("||", ", ")
      else
         v = values
      end
    end
    v
  end

  def maxreplies_of(questions)
    max = 1
    for question in questions
      max = question.replies.delete_if {|r| r.values.nil?}.size if question.replies.delete_if {|r| r.values.nil?}.size > max
    end
    max
  end

  # Regroupe les réponses d'une question
  # in : object => question
  # out: array => myreplies
  def grouped_replies(question)
    myreplies = []
    question.replies.group_by(&:values).collect {|k,v| myreplies << k unless k.nil?}
    myreplies.sort
  end

  def recipients_equal_all_members?(questionnaire)
    questionnaire.recipients.collect(&:user_id).sort == questionnaire.project.principals.collect(&:id).sort
  end

  def responses_viewers_equal_all_members?(questionnaire)
    questionnaire.responses_viewers.collect(&:user_id).sort == questionnaire.project.principals.collect(&:id).sort
  end

  def responses_viewers_equal_recipients?(questionnaire)
    questionnaire.responses_viewers.collect(&:user_id).sort == questionnaire.recipients.collect(&:user_id).sort
  end

  def questionnaire_to_pdf(questionnaire)

    pdf = IFPDF.new(current_language)
    pdf.SetTitle("#{l(:label_questionnaire)}-#{questionnaire.title}")
    pdf.SetAuthor('Questionnaire for Chiliproject')
    pdf.AliasNbPages
    pdf.footer_date = format_date(Date.today)
    pdf.AddPage

    pdf.SetFontStyle('B',11)
    pdf.Cell(200,5, "#{questionnaire.title}")
    pdf.Ln
    pdf.Line(pdf.GetX, pdf.GetY, 180, pdf.GetY)
    pdf.Ln
    pdf.SetFontStyle('',11)
    for question in questionnaire.questions
      pdf.SetFontStyle('B',10)
      pdf.MultiCell(200,5, question.entitled)
      pdf.Ln
      pdf.SetFontStyle('',10)

      case question.nature
      when "FREE_TEXT"
        3.times { pdf.Ln }
      when "YES_NO"
        pdf.MultiCell(200,5, l(:label_no) )
        pdf.MultiCell(200,5, l(:label_yes) )
      when "UNIQUE_CHOICE_LIST"
        question.nature_values.split("\n").collect{ |v| pdf.MultiCell(200,5, v )}
      when "MULTI_CHOICE_LIST"
        question.nature_values.split("\n").collect{ |v| pdf.MultiCell(200,5, v )}
      else
      end
       pdf.Ln
   end
   pdf.Ln

   pdf.Output
  end

  def questionnaire_to_csv(questionnaire)
        ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
      headers = [ l(:field_nature),
                  l(:field_question),
                  l(:field_replies_count),
                  l(:field_recipient)
                  ]
      csv << headers.collect {|c| begin; ic.iconv(c.to_s + ";"); rescue; c.to_s; end }
            # csv lines
      questionnaire.recipients.collect(&:user).each do |recipient|
        questionnaire.questions.each do |question|
          fields = [l('label_' + question.nature.downcase),
                    question.entitled,
                    question.answer_of(recipient),
                    recipient.name
                    ]
          csv << fields.collect {|c| begin; ic.iconv(c.to_s + ";"); rescue; c.to_s; end }
        end
      end
    end
    export
  end

  def render_questionnaire_tooltip(questionnaire)
    textilizable(questionnaire.description)
  end

  # Preview questionnaire
  # Display questionnaire title, description and all questions
  def preview_questionnaire(questionnaire)
    q = ""
    unless questionnaire[:title].blank?
      q += "<label class='bold'>" + l(:field_entitled) + "</label>"
      q += textilizable(questionnaire[:title]) 
    end

    unless questionnaire[:description].blank?
      q += "<label class='bold'>" + l(:field_description) + "</label><br>"
      q += textilizable(questionnaire[:description])
    end

    # display questions
    if questionnaire[:questions_attributes] && questionnaire[:questions_attributes].any?
      q += "<label class='bold'>" + l(:label_question_plural) + "</label>"
      q += "<ol>"
      questionnaire[:questions_attributes].collect do |key, value|
        question = QuestionnairesQuestion.new(:entitled => value[:entitled], :nature => value[:nature], :nature_values => value[:nature_values], :answer_required => value[:answer_required])
        unless value[:entitled].blank?
          q += "<li><label class='bold'>" + value[:entitled] + "</label></li>"
          q += generate_reply_options_for(question)
          q += "<br/><br/>"
        end
      end
      q += "</ol>"
      q += "</div>"
    end
    q
  end
end