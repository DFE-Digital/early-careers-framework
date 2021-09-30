# frozen_string_literal: true

RSpec.describe Admin::Participants::Details, type: :view_component do
  component { described_class.new profile: profile }

  context "for ECT profile" do
    let(:mentor_profile) { create :participant_profile, :mentor }
    let(:profile) { create :participant_profile, :ect, mentor_profile: mentor_profile }

    it "renders all the required information" do
      expect(rendered).to have_contents(
        profile.user.full_name,
        profile.user.email,
        t(:ect, scope: "schools.participants.type"),
        mentor_profile.user.full_name,
        profile.school.name,
        profile.cohort.display_name,
      )
    end
  end

  context "for mentor profile" do
    let(:profile) { create :participant_profile, :mentor }

    it "renders all the required information" do
      expect(rendered).to have_contents(
        profile.user.full_name,
        profile.user.email,
        t(:mentor, scope: "schools.participants.type"),
        profile.school.name,
        profile.cohort.display_name,
      )
    end
  end

  context "for unvalidated npq profile" do
    let(:npq_validation_data) { create(:npq_validation_data) }
    let(:profile) { npq_validation_data.profile }

    before do
      Finance::Schedule.find_or_create_by!(name: "ECF September standard 2021")
      NPQ::CreateOrUpdateProfile.new(npq_validation_data: npq_validation_data).call
    end

    it "renders all the required information" do
      expect(rendered).to have_contents(
        profile.user.full_name,
        profile.user.email,
        profile.validation_data.teacher_reference_number,
        profile.validation_data.school_urn,
        t(:npq, scope: "schools.participants.type"),
        profile.validation_data.npq_lead_provider.name,
        profile.validation_data.npq_course.name,
      )
    end
  end

  context "for validated npq profile" do
    let(:npq_validation_data) { create(:npq_validation_data) }
    let(:profile) { npq_validation_data.profile }

    before do
      Finance::Schedule.find_or_create_by!(name: "ECF September standard 2021")
      NPQ::CreateOrUpdateProfile.new(npq_validation_data: npq_validation_data).call
    end

    before do
      allow(profile).to receive(%i[approved? rejected?].sample).and_return true
      allow(profile).to receive(:pending?).and_return false
    end

    it "renders all the required information" do
      expect(rendered).to have_contents(
        profile.user.full_name,
        profile.user.email,
        profile.validation_data.teacher_reference_number,
        profile.validation_data.school_urn,
        t(:npq, scope: "schools.participants.type"),
        profile.validation_data.npq_lead_provider.name,
        profile.validation_data.npq_course.name,
      )

      expect(rendered).not_to have_content(profile.validation_data.date_of_birth.to_s(:govuk))
    end
  end
end
