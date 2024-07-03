# frozen_string_literal: true

class CreateChangeLeadProviderSupportQuery < BaseService
  attr_reader :current_user, :participant, :email, :school, :start_year, :current_lead_provider, :new_lead_provider

  def initialize(current_user:, participant:, email:, school:, start_year:, current_lead_provider:, new_lead_provider:)
    @current_user = current_user
    @participant = participant
    @email = email
    @school = school
    @start_year = start_year
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
    "change-participant-lead-provider"
  end

  def message
    I18n.t(
      "schools.early_career_teachers.change_lead_provider.support_query.message",
      current_user: current_user.full_name,
      participant: participant.full_name,
      email:,
      school: school.name,
      current_lead_provider: current_lead_provider.name,
      new_lead_provider: new_lead_provider.name,
    )
  end

  def additional_information
    I18n.t(
      "schools.early_career_teachers.change_lead_provider.support_query.additional_information",
      academic_year: start_year,
      participant_id: participant.id,
      school: school.name,
      urn: school.urn,
    )
  end
end
