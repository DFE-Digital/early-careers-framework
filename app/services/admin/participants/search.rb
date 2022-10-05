# frozen_string_literal: true

class Admin::Participants::Search < BaseService
  class NoScopeError < StandardError; end
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
      .active_record
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
      :participant_identity,
      :ecf_participant_eligibility,
      :ecf_participant_validation_data,
      :validation_decisions,
      { current_induction_records: :school },
      { participant_identity: { user: :teacher_profile } },
    ]
  end

  def order
    "DATE(users.created_at) ASC, users.full_name"
  end
end
