# frozen_string_literal: true

RSpec.describe Admin::Participants::Details, :with_default_schedules, type: :view_component do
  component { described_class.new profile: }

  context "for unvalidated npq profile" do
    let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:profile) { npq_application.profile }

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
    let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:profile) { npq_application.profile }

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
