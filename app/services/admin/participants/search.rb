# frozen_string_literal: true

class Admin::Participants::Search < BaseService
  attr_reader :scope, :search_term, :type

  def initialize(scope = ParticipantProfile, search_term: nil, type: nil)
    # make the scope overrideable so we can pass in one that's been
    # checked by Pundit from the controller
    @scope       = scope
    @search_term = search_term
    @type        = type
  end

  def call
    scope
      .eager_load(*left_outer_joins)
      .merge(search_conditions)
      .merge(type_conditions)
      .order(order)
  end

private

  def search_conditions
    if search_term.present?
      User
        .full_name_matches(search_term)
        .or(User.email_matches(search_term))
        .or(ParticipantIdentity.email_matches(search_term))
        .or(TeacherProfile.trn_matches(search_term))
        .or(ParticipantProfile.where(id: search_term))
        .or(TeacherProfile.where(id: search_term))
        .or(User.where(id: search_term))
        .or(ParticipantIdentity.where(external_identifier: search_term))
    else
      User.all
    end
  end

  def type_conditions
    if type.present?
      ParticipantProfile.where(type:)
    else
      ParticipantProfile.all
    end
  end

  def left_outer_joins
    [
      :teacher_profile,
      :ecf_participant_eligibility,
      :ecf_participant_validation_data,
      :validation_decisions,
      { current_induction_records: :school },
      { participant_identity: :user },
    ]
  end

  def order
    "DATE(users.created_at) ASC, users.full_name"
  end
end
