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

  attr_accessor :body_appointed, :body_id, :cohort_start_year

  validates :body_appointed,
            inclusion: { in: %w[yes no],
                         message: "Select whether you’ve appointed an appropriate body or not" },
            on: :body_appointed
  validates :body_id, presence: { message: "Select an appropriate body" }, on: :body

  def attributes
    {
      body_appointed:,
      body_id:,
      cohort_start_year:,
    }
  end

  def body_appointed_choices
    [
      OpenStruct.new(id: "yes", name: "Yes"),
      OpenStruct.new(id: "no", name: "No, I will appoint an appropriate body later"),
    ]
  end

  def body_type_choices
    self.class.body_type_choices_for_year(cohort_start_year)
  end

  def self.body_type_choices_for_year(cohort_start_year)
    if cohort_start_year.present?
      TYPES.select { |ab_type| ab_type.disable_from_year.nil? || cohort_start_year < ab_type.disable_from_year }
    else
      TYPES
    end
  end

  def body_choices
    if cohort_start_year.present?
      AppropriateBody.where(body_type: "teaching_school_hub").active_in_year(cohort_start_year)
    else
      AppropriateBody.where(body_type: "teaching_school_hub")
    end
  end

  def body_appointed?
    body_appointed == "yes"
  end
end
