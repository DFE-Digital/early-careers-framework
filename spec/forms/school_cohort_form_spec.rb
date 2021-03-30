# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohortForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:estimated_mentor_count).with_message("Enter your expected number of mentors") }
    it { is_expected.to validate_presence_of(:estimated_teacher_count).with_message("Enter your expected number of ECTs") }
    it { is_expected.to validate_numericality_of(:estimated_mentor_count).is_greater_than_or_equal_to(0).is_less_than(1000) }
    it { is_expected.to validate_numericality_of(:estimated_teacher_count).is_greater_than_or_equal_to(0).is_less_than(1000) }
  end
end
