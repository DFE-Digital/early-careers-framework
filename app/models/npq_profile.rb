# frozen_string_literal: true

class NpqProfile < ApplicationRecord
  belongs_to :user
  belongs_to :npq_lead_provider
  belongs_to :npq_course

  enum headteacher_status: {
    no: "no",
    yes_when_course_starts: "yes_when_course_starts",
    yes_in_first_two_years: "yes_in_first_two_years",
    yes_over_two_years: "yes_over_two_years",
  }

  enum funding_choice: {
    school: "school",
    trust: "trust",
    self: "self",
    another: "another",
  }
end
