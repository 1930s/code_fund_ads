# frozen_string_literal: true

# == Schema Information
#
# Table name: campaigns
#
#  id                             :uuid             not null, primary key
#  name                           :string(255)      not null
#  redirect_url                   :text             not null
#  status                         :integer          default(0), not null
#  ecpm                           :decimal(10, 2)   not null
#  budget_daily_amount            :decimal(10, 2)   not null
#  total_spend                    :decimal(10, 2)   not null
#  user_id                        :uuid
#  inserted_at                    :datetime         not null
#  updated_at                     :datetime         not null
#  audience_id                    :uuid
#  creative_id                    :uuid
#  included_countries             :string(255)      default([]), is an Array
#  impression_count               :integer          default(0), not null
#  start_date                     :datetime
#  end_date                       :datetime
#  us_hours_only                  :boolean          default(FALSE)
#  weekdays_only                  :boolean          default(FALSE)
#  included_programming_languages :string(255)      default([]), is an Array
#  included_topic_categories      :string(255)      default([]), is an Array
#  excluded_programming_languages :string(255)      default([]), is an Array
#  excluded_topic_categories      :string(255)      default([]), is an Array
#  fallback_campaign              :boolean          default(FALSE), not null
#

class Campaign < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  include TagColumns

  # relationships .............................................................
  belongs_to :creative
  belongs_to :user
  has_many :impressions

  # validations ...............................................................
  validates :budget_daily_amount, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :ecpm, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :fallback_campaign, presence: true
  validates :impression_count, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :name, length: { maximum: 255, allow_blank: false }
  validates :redirect_url, presence: true
  validates :status, inclusion: { in: ENUMS::CAMPAIGN_STATUSES.keys }
  validates :total_spend, numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  # callbacks .................................................................

  # scopes ....................................................................
  scope :search_excluded_programming_languages, -> (*values) { values.blank? ? all : with_any_excluded_programming_languages(*values) }
  scope :search_excluded_topic_categories, -> (*values) { values.blank? ? all : with_any_excluded_topic_categories(*values) }
  scope :search_included_countries, -> (*values) { values.blank? ? all : with_any_included_countries(*values) }
  scope :search_included_programming_languages, -> (*values) { values.blank? ? all : with_any_included_programming_languages(*values) }
  scope :search_included_topic_categories, -> (*values) { values.blank? ? all : with_any_included_topic_categories(*values) }
  scope :search_name, -> (value) { value.blank? ? all : search_column(:name, value) }
  scope :search_status, -> (*values) { values.blank? ? all : where(status: values) }
  scope :search_us_hours_only, -> (value) { value.nil? ? all : where(us_hours_only: value) }
  scope :search_user, -> (value) { value.blank? ? all : where(user_id: User.sponsor.search_name(value).or(User.sponsor.search_company(value))) }
  scope :search_weekdays_only, -> (value) { value.nil? ? all : where(weekdays_only: value) }

  # Scopes and helpers provied by tag_columns
  # SEE: https://github.com/hopsoft/tag_columns
  #
  # - with_included_countries
  # - without_included_countries
  # - with_any_included_countries
  # - without_any_included_countries
  # - with_all_included_countries
  # - without_all_included_countries
  #
  # - with_included_topic_categories
  # - without_included_topic_categories
  # - with_any_included_topic_categories
  # - without_any_included_topic_categories
  # - with_all_included_topic_categories
  # - without_all_included_topic_categories
  #
  # - with_included_programming_languages
  # - without_included_programming_languages
  # - with_any_included_programming_languages
  # - without_any_included_programming_languages
  # - with_all_included_programming_languages
  # - without_all_included_programming_languages
  #
  # - with_excluded_topic_categories
  # - without_excluded_topic_categories
  # - with_any_excluded_topic_categories
  # - without_any_excluded_topic_categories
  # - with_all_excluded_topic_categories
  # - without_all_excluded_topic_categories
  #
  # - with_excluded_programming_languages
  # - without_excluded_programming_languages
  # - with_any_excluded_programming_languages
  # - without_any_excluded_programming_languages
  # - with_all_excluded_programming_languages
  # - without_all_excluded_programming_languages
  #
  # Examples
  #
  #   irb>Campaign.with_included_countries(:US, :GB)
  #   irb>Campaign.without_included_topic_categories("Frontend Frameworks & Tools")
  #   irb>Campaign.with_included_programming_languages(:ruby, :javascript)
  #   irb>Campaign.without_excluded_topic_categories("Database", "Docker", "React")
  #   irb>Campaign.with_any_excluded_programming_languages(:perl, :prolog)

  scope :pending, -> { where status: ENUMS::CAMPAIGN_STATUSES::PENDING }
  scope :active, -> { where status: ENUMS::CAMPAIGN_STATUSES::ACTIVE }
  scope :archived, -> { where status: ENUMS::CAMPAIGN_STATUSES::ARCHIVED }

  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  tag_columns :included_countries
  tag_columns :included_topic_categories
  tag_columns :included_programming_languages
  tag_columns :excluded_topic_categories
  tag_columns :excluded_programming_languages

  # class methods .............................................................
  class << self
  end

  # public instance methods ...................................................
  def pending?
    ENUMS::CAMPAIGN_STATUSES.pending? status
  end

  def active?
    ENUMS::CAMPAIGN_STATUSES.active? status
  end

  def archived?
    ENUMS::CAMPAIGN_STATUSES.archived? status
  end

  def date_range
    return nil unless start_date && end_date
    "#{start_date.to_s "mm/dd/yyyy"} #{end_date.to_s "mm/dd/yyyy"}"
  end

  def scoped_name
    [user.scoped_name, name, creative&.name].compact.join "・"
  end

  # protected instance methods ................................................
  protected

  # private instance methods ..................................................
  private
end
