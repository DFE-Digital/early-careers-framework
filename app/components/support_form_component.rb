# frozen_string_literal: true

class SupportFormComponent < BaseComponent
  def initialize(form:)
    @form = form
  end

  delegate :subject,
           :school,
           :participant_profile,
           :current_user,
           :cohort_year,
           to: :form
  delegate :full_name,
           to: :participant_profile,
           prefix: true,
           allow_nil: true

  def i18n_params
    @i18n_params ||= {
      participant_name: participant_profile_full_name,
      cohort_year_range:,
      support_email: Rails.application.config.support_email,
    }
  end

private

  attr_reader :form

  def cohort_year_range
    Cohort.new(start_year: cohort_year)&.description if cohort_year.present?
  end
end
