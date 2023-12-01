class NPQRegistration::Application < NPQRegistration::BaseRecord
  # These columns are no longer populated with data for future applications
  # but are still in place because they contain historical data.
  # This constant is set so that despite still existing they won't be hooked up
  # within the rails model
  self.ignored_columns = %w[DEPRECATED_cohort]

  has_paper_trail only: %i[lead_provider_approval_status participant_outcome_state]

  belongs_to :user
  belongs_to :course
  belongs_to :lead_provider
  belongs_to :school, foreign_key: "school_urn", primary_key: "urn", optional: true
  belongs_to :private_childcare_provider, foreign_key: "private_childcare_provider_urn", primary_key: "provider_urn", optional: true

  has_many :ecf_sync_request_logs, as: :syncable, dependent: :destroy

  scope :unsynced, -> { where(ecf_id: nil) }

  enum kind_of_nursery: {
    local_authority_maintained_nursery: "local_authority_maintained_nursery",
    preschool_class_as_part_of_school: "preschool_class_as_part_of_school",
    private_nursery: "private_nursery",
    another_early_years_setting: "another_early_years_setting",
  }

  def synced_to_ecf?
    ecf_id.present?
  end

  def inside_catchment?
    %w[england].include?(teacher_catchment)
  end

  def new_headteacher?
    %w[yes_when_course_starts yes_in_first_five_years yes_in_first_two_years].include?(headteacher_status)
  end

  def school
    School.find_by(urn: school_urn)
  end

  def employer_name_to_display
    employer_name || private_childcare_provider&.provider_name || school&.name || ""
  end

  def employer_urn
    private_childcare_provider_urn || school_urn || ""
  end
end
