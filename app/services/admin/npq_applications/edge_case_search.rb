# frozen_string_literal: true

class Admin::NPQApplications::EdgeCaseSearch
  attr_reader :scope, :query_string

  def initialize(scope = NPQApplication, query_string: nil)
    @scope = scope
    @query_string = query_string.to_s
  end

  def call
    scope.eager_load(*left_outer_joins).merge(search_conditions).order(created_at: :desc)
  end

private

  def search_conditions
    if query_string.present?
      NPQApplication
        .does_not_work_in_school
        .does_not_work_in_childcare
        .edge_case_statuses
        .where(id: query_string)
        .or(User.full_name_matches(query_string))
        .or(User.email_matches(query_string))
        .or(ParticipantIdentity.email_matches(query_string))
        .or(ParticipantIdentity.where(id: query_string))
        .or(ParticipantProfile.where(id: query_string))
        .or(User.where(id: query_string))
        .or(NPQApplication.where(teacher_reference_number: query_string))
        .or(NPQApplication.where(id: query_string))
    else
      NPQApplication
        .does_not_work_in_school
        .does_not_work_in_childcare
        .edge_case_statuses
        .all
    end
  end

  def left_outer_joins
    [
      :npq_course,
      :participant_identity,
      { participant_identity: :user },
      { participant_identity: :participant_profiles },
    ]
  end
end
