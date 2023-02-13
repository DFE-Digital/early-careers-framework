# frozen_string_literal: true

class Admin::NPQApplications::ApplicationsSearch
  attr_reader :scope, :query_string

  def initialize(scope = NPQApplication, query_string: nil)
    @scope = scope
    @query_string = query_string.to_s
  end

  def call
    scope.eager_load(*left_outer_joins).merge(search_conditions)
      .order(order)
  end

private

  def search_conditions
    if query_string.present?
      NPQApplication
        .where(id: query_string)
        .or(User.full_name_matches(query_string))
        .or(User.email_matches(query_string))
        .or(ParticipantIdentity.email_matches(query_string))
        .or(ParticipantIdentity.where(id: query_string))
        .or(ParticipantProfile.where(id: query_string))
        .or(User.where(id: query_string))
        .or(NPQApplication.where(teacher_reference_number: query_string))
        .or(NPQApplication.where(id: query_string))
        .or(NPQApplication.where(private_childcare_provider_urn: query_string))
        .or(School.where("schools.name ilike ?", "%#{query_string}%"))
        .or(School.where(urn: query_string))
    else
      NPQApplication.all
    end
  end

  def left_outer_joins
    [
      :participant_identity,
      :school,
      { participant_identity: :user },
      { participant_identity: :participant_profiles },
    ]
  end

  def order
    "npq_applications.updated_at ASC"
  end
end
