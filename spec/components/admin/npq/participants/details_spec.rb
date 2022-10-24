# frozen_string_literal: true

RSpec.describe Admin::NPQ::Participants::Details, :with_default_schedules, type: :component do
  let(:component) { described_class.new profile: }
  context "for unvalidated npq profile" do
    let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:profile) { npq_application.profile }

    subject! { render_inline(component) }

    it "renders all the required information" do
      expect(rendered_content).to include(
        profile.user.full_name,
        profile.user.email,
        profile.npq_application.nino,
        profile.npq_application.date_of_birth.to_formatted_s(:govuk),
        profile.npq_application.teacher_reference_number,
        profile.npq_application.school_urn,
        I18n.t(:npq, scope: "schools.participants.type"),
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

    subject! { render_inline(component) }

    it "renders all the required information" do
      expect(rendered_content).to include(
        profile.user.full_name,
        profile.user.email,
        profile.npq_application.teacher_reference_number,
        profile.npq_application.school_urn,
        I18n.t(:npq, scope: "schools.participants.type"),
        profile.npq_application.npq_lead_provider.name,
        profile.npq_application.npq_course.name,
      )

      expect(rendered_content).not_to have_content(profile.npq_application.date_of_birth.to_s(:govuk))
    end
  end
end
