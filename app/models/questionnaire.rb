#-- encoding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class Questionnaire < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :questionnaires_users, :dependent => :destroy
  has_many :recipients, :class_name => 'QuestionnairesUser', :conditions => "#{QuestionnairesUser.table_name}.role = 'RECIPIENT'"
  has_many :responses_viewers, :class_name => 'QuestionnairesUser', :conditions => "#{QuestionnairesUser.table_name}.role = 'RESPONSES_VIEWER'"
  has_many :questions, :class_name => 'QuestionnairesQuestion', :dependent => :destroy
  has_many :replies, :class_name => 'QuestionnairesReply', :dependent => :destroy

  accepts_nested_attributes_for :questions, :allow_destroy => true

  acts_as_searchable :columns => [ "questionnaires.title", "questionnaires.description", "questionnaires_questions.entitled"],
                     :include => [ :questions, :project ],
                     :order_column => "questionnaires.id",
                     :permission => :view_questionnaires

  acts_as_event :title => Proc.new { |o| "#{l(:label_title_questionnaire)} ##{o.id}: #{o.title}" },
                :description => Proc.new { |o| "#{o.description}" },
                :datetime => :created_on,
                :type => 'questionnaires',
                :url => Proc.new { |o| {:controller => 'questionnaires', :action => 'show', :id => o.project, :q_id => o.id} }

  validates_presence_of :title
  validates_presence_of :starts_on
  validates_presence_of :ends_on
  validates_format_of :revival, :with => /\d+/, :allow_blank => true
  validate :start_must_be_before_end_time

  named_scope :my, lambda { |project| {:conditions => ["project_id = ? AND (created_by = ?  OR  validate_by = ?)", project.id, User.current.id, User.current.id], :order => "starts_on DESC"}}
  named_scope :currents, lambda { |project| {:joins => :questionnaires_users, :conditions => [" project_id = ? AND user_id = ? AND published = ? AND ends_on >= ?", project.id, User.current.id, true, Date.today.to_s], :order => "starts_on DESC"}}
  named_scope :currents_all_projects, :joins => :questionnaires_users, :conditions => [" user_id = ? AND published = ? AND ends_on >= ?", User.current.id, true, Date.today.to_s], :order => "starts_on DESC"
  named_scope :finished, lambda { |project| {:joins => :questionnaires_users, :conditions => [" project_id = ? AND user_id = ? AND ends_on < ?", project.id, User.current.id, Date.today.to_s], :order => "starts_on DESC"}}

  before_save Proc.new {|q| q.starts_on = Date.today if q.starts_on > Date.today and q.published }


# Get the author of the questionnaire
  def author
    created_by.is_a?(Integer) ? User.find_by_id(created_by) : nil
  end
# Get the validator of the questionnaire
  def validator
    validate_by.is_a?(Integer) ? User.find_by_id(validate_by) : nil
  end

  # permet de tester si l'utilisateur courant a le droit de plublier un questionnaire
  def canbepublished?(user)
    validate_by == user.id or validate_by.nil?
  end

  # Validation de la date de début  et de fin du questionnaire
  def start_must_be_before_end_time
    if starts_on and ends_on and starts_on.is_a?(Date) and ends_on.is_a?(Date)
      errors.add(:starts_on, :notice_must_be_after_or_equal_today) unless starts_on.to_s >= Date.today.to_s
      errors.add(:starts_on, :notice_must_be_before_end_time) unless starts_on <= ends_on
    end
  end
 # permet de tester si l'utilisateur courant a le droit de consulter les réponses d'un questionnaire
  def reponsescanviewby?(user)
    responses_viewers.collect(&:user_id).include?(user.id)
  end
# permet de tester si l'utilisateur courant a le droit de répondre à un questionnaire
  def canbereplyby?(user)
    recipients.collect(&:user_id).include?(user.id)
  end
end
