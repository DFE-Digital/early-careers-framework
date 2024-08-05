# frozen_string_literal: true

class CreateChangeRequestSupportQuery < BaseService
  attr_reader :current_user, :participant, :school, :academic_year, :current_relation, :new_relation

  def initialize(current_user:, participant:, school:, academic_year:, current_relation:, new_relation:)
    @current_user = current_user
    @participant = participant
    @school = school
    @academic_year = academic_year
    @current_relation = current_relation
    @new_relation = new_relation
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
    if lead_provider_change_request?
      participant_change_request? ? "change-participant-lead-provider" : "change-cohort-lead-provider"
    else
      "change-cohort-delivery-partner"
    end
  end

  def additional_information
    {
      school_id: school&.id,
      participant_profile_id: participant&.id,
      cohort_year: academic_year&.split&.first,
    }.reject { |_k, v| v.blank? }
  end

  def message
    i18n_key = participant_change_request? ? "participant" : "cohort"
    key = "schools.change_request_support_query.#{relation_i18n_key}.message.#{i18n_key}"

    kwargs = {
      academic_year:,
      current_user: current_user.full_name,
      email:,
      school: school.name,
      current_relation: current_relation.name,
      new_relation: new_relation.name,
      induction_coordinator: induction_coordinator.full_name,
    }

    if participant_change_request?
      kwargs[:participant] = participant.full_name
      kwargs[:participant_id] = participant.id
    end

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

  def lead_provider_change_request?
    current_relation.is_a?(LeadProvider)
  end

  def relation_i18n_key
    current_relation.class.name.underscore
  end
end
