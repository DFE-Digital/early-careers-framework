# frozen_string_literal: true

class AppropriateBodySelectionForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization
  include ActiveRecord::Callbacks

  attr_accessor :body_appointed, :body_id, :cohort_start_year, :body_type, :default_appropriate_body

  before_validation :ensure_default_appropriate_body_id

  validates :body_appointed,
            inclusion: { in: %w[yes no],
                         message: "Select whether you’ve appointed an appropriate body or not" },
            on: :body_appointed
  validates :body_id, presence: { message: "Select an appropriate body" }, on: :body, if: :body_type_tsh?
  validates :body_type, presence: { message: "Select an appropriate body" }, inclusion: %w[tsh default], on: :body_type

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

  def body_choices
    if cohort_start_year.present?
      AppropriateBody.where(body_type: "teaching_school_hub").active_in_year(cohort_start_year).selectable_by_schools
    else
      AppropriateBody.where(body_type: "teaching_school_hub").selectable_by_schools
    end
  end

  def body_appointed?
    body_appointed == "yes"
  end

  def body_type_tsh?
    body_type == "tsh"
  end

  def ensure_default_appropriate_body_id
    if body_type == "default"
      @body_id = default_appropriate_body.id
    end
  end
end
