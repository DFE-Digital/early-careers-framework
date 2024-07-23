# frozen_string_literal: true

class CreateChangeLeadProviderSupportQuery < BaseService
  attr_reader :current_user, :participant, :school, :academic_year, :current_lead_provider, :new_lead_provider

  def initialize(current_user:, participant:, school:, academic_year:, current_lead_provider:, new_lead_provider:)
    @current_user = current_user
    @participant = participant
    @school = school
    @academic_year = academic_year
    @current_lead_provider = current_lead_provider
    @new_lead_provider = new_lead_provider
  end

  def call
    SupportQuery.create!(
      message:,
      user: current_user,
      subject:,
      additional_information:,
    ).tap(&:enqueue_support_query_sync_job)
  end

private

  def subject
    participant_change_request? ? "change-participant-lead-provider" : "change-cohort-lead-provider"
  end

  def additional_information
    I18n.t(
      "schools.change_lead_provider.support_query.additional_information",
      academic_year:,
      school: school.name,
      urn: school.urn,
    )
  end

  def message
    i18n_key = participant_change_request? ? "participant" : "cohort"
    key = "schools.change_lead_provider.support_query.message.#{i18n_key}"

    kwargs = {
      academic_year:,
      current_user: current_user.full_name,
      email:,
      school: school.name,
      current_lead_provider: current_lead_provider.name,
      new_lead_provider: new_lead_provider.name,
      induction_coordinator: induction_coordinator.full_name,
    }

    kwargs[:participant] = participant.full_name if participant_change_request?

    I18n.t(key, **kwargs)
  end

  def email
    participant_change_request? ? participant.user.email : induction_coordinator.email
  end

  def induction_coordinator
    school.induction_coordinators.first
  end

  def participant_change_request?
    participant.present?
  end
end
