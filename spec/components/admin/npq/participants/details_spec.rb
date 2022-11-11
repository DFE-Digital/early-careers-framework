# frozen_string_literal: true

RSpec.describe Admin::NPQ::Participants::Details, :with_default_schedules, type: :component do
  let(:component) { described_class.new(profile:, school:, user:, npq_application:) }

  let(:npq_application) { build(:npq_application) }
  let(:school) { build(:school) }
  let(:user) { build(:user, updated_at: 1.week.ago) }
  let(:profile) { build(:npq_participant_profile, updated_at: 1.week.ago) }

  describe "delegations" do
    subject { component }

    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:user).with_prefix(true) }

    it { is_expected.to delegate_method(:urn).to(:school).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:name).to(:school).with_prefix(true).allow_nil }

    it { is_expected.to delegate_method(:teacher_reference_number).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:nino).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:date_of_birth).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:course_name).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:pending?).to(:npq_application).with_prefix(true).allow_nil }
  end

  describe "heading" do
    subject! { render_inline(component) }

    it "renders a level 2 'Details' heading" do
      expect(rendered_content).to have_css("h2", text: "Details")
    end
  end

  describe "#last_updated" do
    context "when the profile was updated more recently than the user record" do
      let(:user) { build(:user, updated_at: 3.weeks.ago) }

      it "uses the profile's updated_at value" do
        expect(component.last_updated).to eql(profile.updated_at.to_formatted_s(:govuk))
      end
    end

    context "when the user record was updated more recently than the profile" do
      let(:profile) { build(:npq_participant_profile, updated_at: 3.weeks.ago) }

      it "uses the user record's updated_at value" do
        expect(component.last_updated).to eql(user.updated_at.to_formatted_s(:govuk))
      end
    end
  end

  context "for unvalidated npq profile" do
    subject! { render_inline(component) }

    it "renders all the required information" do
      aggregate_failures do
        expect(rendered_content).to include(user.full_name)
        expect(rendered_content).to include(user.email)
        expect(rendered_content).to include(npq_application.nino)
        expect(rendered_content).to include(npq_application.date_of_birth.to_formatted_s(:govuk))
        expect(rendered_content).to include(npq_application.teacher_reference_number)
        expect(rendered_content).to include(school.urn)
        expect(rendered_content).to include(I18n.t(:npq, scope: "schools.participants.type"))
        expect(rendered_content).to include(npq_application.npq_lead_provider.name)
        expect(rendered_content).to include(npq_application.npq_course.name)
      end
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
      aggregate_failures do
        expect(rendered_content).to include(user.full_name)
        expect(rendered_content).to include(user.email)
        expect(rendered_content).to include(npq_application.teacher_reference_number)
        expect(rendered_content).to include(school.urn)
        expect(rendered_content).to include(I18n.t(:npq, scope: "schools.participants.type"))
        expect(rendered_content).to include(npq_application.npq_lead_provider.name)
        expect(rendered_content).to include(npq_application.npq_course.name)

        expect(rendered_content).not_to have_content(npq_application.date_of_birth.to_s(:govuk))
      end
    end
  end
end
