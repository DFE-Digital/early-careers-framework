# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohortForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:estimated_mentor_count).with_message("Enter your expected number of mentors") }
    it { is_expected.to validate_presence_of(:estimated_teacher_count).with_message("Enter your expected number of ECTs") }
  end
end
