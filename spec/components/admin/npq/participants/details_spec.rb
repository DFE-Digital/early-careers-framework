# frozen_string_literal: true

RSpec.describe Admin::NPQ::Participants::Details, type: :component do
  let(:component) { described_class.new(profile:, school:, user:, npq_application:) }

  let(:school) { build(:school) }
  let(:npq_application) { build(:npq_application, updated_at: 3.weeks.ago) }
  let(:user) { build(:user, updated_at: 3.weeks.ago) }
  let(:profile) { build(:npq_participant_profile, updated_at: 3.weeks.ago) }

  describe "delegations" do
    subject { component }

    it { is_expected.to delegate_method(:pending?).to(:profile).with_prefix(true) }

    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:user).with_prefix(true) }

    it { is_expected.to delegate_method(:urn).to(:school).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:name).to(:school).with_prefix(true).allow_nil }

    it { is_expected.to delegate_method(:teacher_reference_number).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:nino).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:date_of_birth).to(:npq_application).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:course_name).to(:npq_application).with_prefix(true).allow_nil }
  end

  describe "heading" do
    subject! { render_inline(component) }

    it "renders a level 2 'Details' heading" do
      expect(rendered_content).to have_css("h2", text: "Details")
    end
  end

  describe "#funded_place" do
    it "returns `empty string` if `nil`" do
      expect(component.funded_place).to eq("")
    end

    it "returns `Yes` if `true`" do
      npq_application.update!(funded_place: true)

      expect(component.funded_place).to eq("Yes")
    end

    it "returns `No` if `false`" do
      npq_application.update!(funded_place: false)

      expect(component.funded_place).to eq("No")
    end
  end

  describe "#last_updated" do
    context "when the profile was updated most recently" do
      let(:profile) { build(:npq_participant_profile, updated_at: 3.days.ago) }

      it "uses the profile's updated_at value" do
        expect(component.last_updated).to eql(profile.updated_at.to_formatted_s(:govuk))
      end
    end

    context "when the user record was updated most recently" do
      let(:user) { build(:user, updated_at: 3.days.ago) }

      it "uses the user record's updated_at value" do
        expect(component.last_updated).to eql(user.updated_at.to_formatted_s(:govuk))
      end
    end

    context "when the NPQ application was updated most recently" do
      let(:npq_application) { build(:npq_application, updated_at: 3.days.ago) }

      it "uses the user record's updated_at value" do
        expect(component.last_updated).to eql(npq_application.updated_at.to_formatted_s(:govuk))
      end
    end
  end

  describe "displaying information" do
    shared_examples "basic NPQ details" do
      it "renders all the required information" do
        aggregate_failures do
          expect(rendered_content).to include(user.full_name)
          expect(rendered_content).to include(user.email)
          expect(rendered_content).to include(npq_application.teacher_reference_number)
          expect(rendered_content).to include(school.urn)
          expect(rendered_content).to include(I18n.t(:npq, scope: "schools.participants.type"))
          expect(rendered_content).to include(npq_application.npq_lead_provider.name)
          expect(rendered_content).to include(npq_application.npq_course.name)
        end
      end
    end

    describe "Funded place" do
      let!(:profile) { npq_application.profile }
      let!(:npq_application) do
        create(:npq_application,
               :accepted,
               eligible_for_funding: true,
               npq_course:,
               npq_lead_provider:)
      end
      let(:npq_lead_provider) { create(:npq_lead_provider) }
      let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
      let(:funding_cap) { 10 }
      let!(:statement) do
        create(
          :npq_statement,
          :next_output_fee,
          cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
          cohort: npq_application.cohort,
        )
      end
      let!(:npq_contract) do
        create(
          :npq_contract,
          npq_lead_provider:,
          cohort: statement.cohort,
          course_identifier: npq_course.identifier,
          version: statement.contract_version,
          funding_cap:,
        )
      end

      context "when FeatureFlag `npq_capping` is disabled" do
        subject! { render_inline(component) }

        include_examples "basic NPQ details"

        it "does not render the funded places section" do
          expect(rendered_content).not_to include("Funded place")
        end
      end

      context "when FeatureFlag `npq_capping` is enabled" do
        before do
          FeatureFlag.activate(:npq_capping)
          npq_application.update!(funded_place: true)
          render_inline(component)
        end

        context "when the npq_application has a funded place" do
          include_examples "basic NPQ details"

          it "renders the funded place section" do
            expect(rendered_content).to include("Funded place")
            expect(rendered_content).to include("Yes")
          end
        end
      end
    end

    context "when the profile is pending" do
      subject! { render_inline(component) }

      include_examples "basic NPQ details"

      it "renders the extra NPQ details" do
        aggregate_failures do
          expect(rendered_content).to include(npq_application.nino)
          expect(rendered_content).to include(npq_application.date_of_birth.to_formatted_s(:govuk))
        end
      end
    end

    context "when the profile isn't pending" do
      let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
      let(:profile) { npq_application.profile }

      before do
        allow(profile).to receive(%i[approved? rejected?].sample).and_return true
        allow(profile).to receive(:pending?).and_return false
      end

      subject! { render_inline(component) }

      include_examples "basic NPQ details"

      it "doesn't render the extra NPQ details" do
        aggregate_failures do
          expect(rendered_content).not_to include("National Insurance number")
          expect(rendered_content).not_to include("Date of birth")
        end
      end
    end
  end
end
