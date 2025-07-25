# frozen_string_literal: true

require "pagy"

module ApplicationHelper
  include Pagy::Frontend

  def boolean_red_green_tag(bool, text = nil)
    text ||= bool ? "YES" : "NO"
    colour = bool ? "green" : "red"

    content_tag(:strong, text, class: "govuk-tag govuk-tag--#{colour}")
  end

  def data_layer
    @data_layer ||= build_data_layer
  end

  def boolean_to_yes_no_nil(value)
    return "" if value.nil?

    boolean_to_yes_no(value)
  end

  def boolean_to_yes_no(value)
    value ? "Yes" : "No"
  end

  def build_data_layer
    analytics_data = AnalyticsDataLayer.new
    analytics_data.add_user_info(current_user) if current_user
    analytics_data.add_school_info(assigns["school"]) if assigns["school"]
    analytics_data
  end

  def induction_coordinator_dashboard_path(user)
    return schools_dashboard_index_path if user.schools.count != 1

    school = user.induction_coordinator_profile.schools.first
    return schools_choose_programme_path(school_id: school.slug, cohort_id: Cohort.active_registration_cohort) if school.school_cohorts.empty?

    school_dashboard_with_tab_path(school)
  end

  def induction_coordinator_mentor_path(user)
    profile = user.participant_profiles.active_record.mentors.first
    return participants_validation_path unless profile&.completed_validation_wizard?

    induction_coordinator_dashboard_path(user)
  end

  def service_name
    "Manage training for early career teachers"
  end

  def text_otherwise_link_to(text, url, condition_for_text)
    if condition_for_text
      text
    else
      govuk_link_to text, url
    end
  end

  def wide_container_view?
    params[:controller].split("/").first.in?(%w[finance admin])
  end

  def bool_to_tag(bool)
    if bool
      '<strong class="govuk-tag govuk-tag--green">YES</strong>'
    else
      '<strong class="govuk-tag govuk-tag--red">NO</strong>'
    end.html_safe
  end

  def possessive_name(name)
    return name if name.blank?

    "#{name}#{name[-1] == 's' ? '’' : '’s'}"
  end

  def keep_providers_options
    [
      OpenStruct.new(id: "yes", name: "Yes"),
      OpenStruct.new(id: "no", name: "No, they’ll move to different training providers or a different training programme"),
    ]
  end

  def simple_yes_no_options
    [
      OpenStruct.new(id: "yes", name: "Yes"),
      OpenStruct.new(id: "no", name: "No"),
    ]
  end

  def print_link(title, filename:)
    govuk_link_to title, "javascript:void(0)", onclick: "window.formattedPrint(this)", data: { filename: }
  end

private

  def post_2020_ecf_participant?(user)
    user.teacher_profile.ecf_profiles.where.not(cohort: Cohort.find_by(start_year: 2020)).any?
  end

  def school_dashboard_with_tab_path(school)
    schools_dashboard_path(school_id: school.slug,
                           anchor: TabLabelDecorator.new(Cohort.active_registration_cohort.description).parameterize)
  end
end
