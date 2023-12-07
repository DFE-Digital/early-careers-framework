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

private

  attr_reader :form
end
