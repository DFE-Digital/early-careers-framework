# frozen_string_literal: true

class Admin::NPQApplications::EdgeCaseSearch
  attr_reader :scope, :query_string, :funding_eligiblity_status_code, :employment_type, :start_date, :end_date

  def initialize(scope = NPQApplication, query_string: nil, funding_eligiblity_status_code: nil, employment_type: nil, start_date: nil, end_date: nil)
    @scope = scope
    @query_string = query_string.to_s
    @funding_eligiblity_status_code = funding_eligiblity_status_code
    @employment_type = employment_type
    @start_date = start_date
    @end_date = end_date
  end

  def call
    scope.eager_load(*left_outer_joins).merge(search_conditions)
         .merge(funding_eligiblity_status_code_conditions)
         .merge(employment_type_conditions)
         .merge(created_at_conditions)
         .order(created_at: :desc)
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
        .or(TeacherProfile.trn_matches(query_string))
        .or(User.where(id: query_string))
        .or(NPQApplication.where(teacher_reference_number: query_string))
        .or(NPQApplication.where(id: query_string))
        .or(NPQApplication.where(employer_name: query_string))
    else
      NPQApplication
        .does_not_work_in_school
        .does_not_work_in_childcare
        .edge_case_statuses
        .all
    end
  end

  def funding_eligiblity_status_code_conditions
    if funding_eligiblity_status_code.present?
      NPQApplication.where(funding_eligiblity_status_code:)
    else
      NPQApplication.all
    end
  end

  def employment_type_conditions
    if employment_type.present?
      NPQApplication.where(employment_type:)
    else
      NPQApplication.all
    end
  end

  def created_at_conditions
    if start_date.present? && end_date.present?
      NPQApplication.created_at_range(start_date, end_date)
    else
      NPQApplication.all
    end
  end

  def left_outer_joins
    [
      :npq_course,
      :participant_identity,
      { participant_identity: { user: :teacher_profile } },
    ]
  end
end
