# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_many :profile_declarations
  has_one :current_profile_declaration, -> { order(created_at: :desc) }, class_name: "ProfileDeclaration"
  has_one :participant_profile, through: :current_profile_declaration
  belongs_to :cpd_lead_provider
  belongs_to :user

  delegate :payable, to: :current_profile_declaration, allow_nil: true

  validates :course_identifier, :user, :cpd_lead_provider, :declaration_date, :declaration_type, presence: true

  # Helper scopes
  scope :for_lead_provider, ->(cpd_lead_provider) { where(cpd_lead_provider: cpd_lead_provider) }
  scope :for_declaration, ->(declaration_type) { where(declaration_type: declaration_type) }
  scope :started, -> { for_declaration("started").order(declaration_date: "desc").unique_id }
  scope :uplift, -> { joins(:current_profile_declaration).merge(ProfileDeclaration.uplift) }
  scope :ect, -> { joins(:current_profile_declaration).merge(ProfileDeclaration.ect_profiles) }
  scope :mentor, -> { joins(:current_profile_declaration).merge(ProfileDeclaration.mentor_profiles) }
  scope :npq, -> { joins(:current_profile_declaration).merge(ProfileDeclaration.npq_profiles) }
  scope :payable, -> { joins(:current_profile_declaration).merge(ProfileDeclaration.where(payable: true)) }
  scope :unique_id, -> { select(:user_id).distinct }
  scope :voided, -> { where.not(voided_at: nil) }
  scope :not_voided, -> { where(voided_at: nil) }

  # Time dependent Range scopes
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Declaration aggregation scopes
  scope :active_for_lead_provider, ->(lead_provider) { not_voided.started.for_lead_provider(lead_provider).unique_id }
  scope :active_ects_for_lead_provider, ->(lead_provider) { not_voided.active_for_lead_provider(lead_provider).ect }
  scope :active_mentors_for_lead_provider, ->(lead_provider) { not_voided.active_for_lead_provider(lead_provider).mentor }
  scope :active_npqs_for_lead_provider, ->(lead_provider) { not_voided.active_for_lead_provider(lead_provider).npq }
  scope :active_uplift_for_lead_provider, ->(lead_provider) { not_voided.active_for_lead_provider(lead_provider).uplift }

  scope :payable_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).payable }
  scope :payable_ects_for_lead_provider, ->(lead_provider) { active_ects_for_lead_provider(lead_provider).payable }
  scope :payable_mentors_for_lead_provider, ->(lead_provider) { active_mentors_for_lead_provider(lead_provider).payable }
  scope :payable_npqs_for_lead_provider, ->(lead_provider) { active_npqs_for_lead_provider(lead_provider).payable }
  scope :payable_uplift_for_lead_provider, ->(lead_provider) { active_uplift_for_lead_provider(lead_provider).payable }

  def currently_payable
    participant_profile.fundable?
  end

  def refresh_payability!
    # TODO: Do not update it if the declaration was processed already
    if current_profile_declaration&.payable != currently_payable
      ProfileDeclaration.create!(
        participant_profile: participant_profile,
        participant_declaration: self,
        payable: currently_payable,
      )
      reload
    end
  end

  def voided
    voided_at.present?
  end

  def void!
    # TODO: Prevent voiding a processed declaration - that requires clawbacks
    update!(voided_at: Time.zone.now)
  end
end
