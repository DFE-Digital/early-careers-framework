# frozen_string_literal: true

require "rails_helper"

RSpec.describe SplitLessonPartForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title).with_message("Enter a title") }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_presence_of(:content).with_message("Enter content") }
    it { is_expected.to validate_length_of(:content).is_at_most(100_000) }

    it { is_expected.to validate_presence_of(:new_title).with_message("Enter a title") }
    it { is_expected.to validate_length_of(:new_title).is_at_most(255) }
    it { is_expected.to validate_presence_of(:new_content).with_message("Enter content") }
    it { is_expected.to validate_length_of(:new_content).is_at_most(100_000) }
  end
end
