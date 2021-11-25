# frozen_string_literal: true

RSpec.describe Admin::Participants::Details, :with_default_schedules, type: :view_component do
  component { described_class.new profile: profile }

  context "for ECT profile" do
    let(:mentor_profile) { create :mentor_participant_profile }
    let(:profile) { create :ect_participant_profile, mentor_profile: mentor_profile }

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
    let(:profile) { create :mentor_participant_profile }

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
    let(:npq_application) { create(:npq_application, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:profile) { npq_application.profile }

    before do
      NPQ::Accept.new(npq_application: npq_application).call
    end

    it "renders all the required information" do
      expect(rendered).to have_contents(
        profile.user.full_name,
        profile.user.email,
        profile.npq_application.teacher_reference_number,
        profile.npq_application.school_urn,
        t(:npq, scope: "schools.participants.type"),
        profile.npq_application.npq_lead_provider.name,
        profile.npq_application.npq_course.name,
      )
    end
  end

  context "for validated npq profile" do
    let(:npq_application) { create(:npq_application, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:profile) { npq_application.profile }

    before do
      NPQ::Accept.new(npq_application: npq_application).call
    end

    before do
      allow(profile).to receive(%i[approved? rejected?].sample).and_return true
      allow(profile).to receive(:pending?).and_return false
    end

    it "renders all the required information" do
      expect(rendered).to have_contents(
        profile.user.full_name,
        profile.user.email,
        profile.npq_application.teacher_reference_number,
        profile.npq_application.school_urn,
        t(:npq, scope: "schools.participants.type"),
        profile.npq_application.npq_lead_provider.name,
        profile.npq_application.npq_course.name,
      )

      expect(rendered).not_to have_content(profile.npq_application.date_of_birth.to_s(:govuk))
    end
  end
end
