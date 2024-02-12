# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::PrimaryUser do
  describe ".find_by" do
    let(:teacher_profile) { create(:teacher_profile) }
    let(:trn) { teacher_profile.trn }

    subject { described_class.find_by(trn:) }

    context "when there are no matching users" do
      let(:trn) { "no-match" }

      it { is_expected.to be_nil }
    end

    context "when there are matching users" do
      it "returns the user from the oldest TeacherProfile with the given TRN" do
        create(:teacher_profile, trn: "76564321")
        create(:teacher_profile, trn:)
        oldest_matching_teacher_profile = travel_to(4.weeks.ago) { create(:teacher_profile, trn:) }
        create(:teacher_profile, trn:)

        is_expected.to eq(oldest_matching_teacher_profile.user)
      end
    end

    context "when there are matching users that are archived" do
      it "excludes archived users" do
        create(:teacher_profile, trn:)
        travel_to(4.weeks.ago) { create(:teacher_profile, trn:, user: create(:user, :archived)) }

        is_expected.to eq(teacher_profile.user)
      end
    end
  end
end
