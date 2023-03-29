# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Participants::AddMentorToSchoolForm, type: :model do
  let(:school) { create(:school) }
  let(:school_urn) { school.urn }
  let(:mentor_profile) { create(:mentor_participant_profile) }

  subject { described_class.new(mentor_profile:, school_urn:) }

  describe "validation" do
    it { is_expected.to have_attributes(mentor_profile:, school_urn:) }
    it { is_expected.to validate_presence_of(:school_urn) }

    context "when mentor is new to the school" do
      it { is_expected.to be_valid }
    end

    context "when the school does not exists" do
      let(:school_urn) { "000000" }

      it { is_expected.not_to be_valid }
    end

    context "when the mentor is already mentoring in the school" do
      before do
        mentor_profile.school_mentors.create(school: mentor_profile.school, preferred_identity: mentor_profile.participant_identity)
      end

      let(:school_urn) { mentor_profile.school_mentors.first.school.urn }

      it { is_expected.not_to be_valid }
    end
  end

  # rubocop:disable Rails/SaveBang
  describe "#save" do
    context "when the form is valid" do
      it "returns true" do
        expect(subject.save).to be true
      end

      it "adds the mentor to the school's mentor pool" do
        subject.save
        expect(school.mentor_profiles).to include mentor_profile
      end
    end

    context "when the form is invalid" do
      let(:school_urn) { nil }

      it "returns false" do
        expect(subject.save).to be false
      end

      it "doesn't add the mentor to the school's mentor pool" do
        subject.save
        expect(school.mentor_profiles).not_to include mentor_profile
      end
    end
  end
  # rubocop:enable Rails/SaveBang
end
