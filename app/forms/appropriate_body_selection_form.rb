# frozen_string_literal: true

class AppropriateBodySelectionForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization

  TYPES = [
    OpenStruct.new(id: "local_authority", name: "Local authority", disable_from_year: 2023),
    OpenStruct.new(id: "national", name: "National organisation", disable_from_year: nil),
    OpenStruct.new(id: "teaching_school_hub", name: "Teaching school hub", disable_from_year: nil),
  ].freeze

  attr_accessor :body_appointed, :body_type, :body_id, :cohort_start_year

  validates :body_appointed,
            inclusion: { in: %w[yes no],
                         message: "Please select whether you have appointed an appropriate body or not" },
            on: :body_appointed
  validates :body_type,
            presence: { message: "Please select an appropriate body type" },
            on: :body_type,
            inclusion: { in: %w[local_authority national teaching_school_hub unknown],
                         message: "Please select an appropriate body type" }
  validates :body_id, presence: { message: "Please select an appropriate body" }, on: :body

  def attributes
    {
      body_appointed:,
      body_type:,
      body_id:,
      cohort_start_year:,
    }
  end

  def body_appointed_choices
    [
      OpenStruct.new(id: "yes", name: "Yes"),
      OpenStruct.new(id: "no", name: "No"),
    ]
  end

  def body_type_choices
    self.class.body_type_choices_for_year(cohort_start_year)
  end

  def self.body_type_choices_for_year(cohort_start_year)
    if cohort_start_year.present?
      TYPES.select { |ab_type| ab_type.disable_from_year.nil? || ab_type.disable_from_year > cohort_start_year }
    else
      TYPES
    end
  end

  def body_choices
    if cohort_start_year.present?
      AppropriateBody.where(body_type:).active_in_year(cohort_start_year)
    else
      AppropriateBody.where(body_type:)
    end
  end

  def body_appointed?
    body_appointed == "yes"
  end
end
