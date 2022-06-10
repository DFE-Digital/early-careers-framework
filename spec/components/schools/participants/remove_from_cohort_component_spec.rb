# frozen_string_literal: true

RSpec.describe Schools::Participants::RemoveFromCohortComponent, :with_default_schedules, type: :view_component do
  let(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
  let(:delivery_partner) { create :delivery_partner }
  let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider:, delivery_partner:) }
  let(:profile) { create :ect, school_cohort:, lead_provider: }
  let(:induction_record) { profile.current_induction_record }
  let(:induction_coordinator) { create(:user, :induction_coordinator, schools: [school_cohort.school]) }

  component { described_class.new(current_user: induction_coordinator, induction_record:) }

  context "when the validation hasn’t started yet" do
    it "displays the link to remove the participant" do
      expect(rendered).to have_link(href: schools_participant_remove_path(induction_record.school, school_cohort.cohort, profile))
    end
  end

  context "when validation already started" do
    let!(:validation_data) { create :ecf_participant_validation_data, participant_profile: profile }

    it "does not display the removal link" do
      expect(rendered).not_to have_link(href: schools_participant_remove_path(induction_record.school, school_cohort.cohort, profile))
    end

    context "when the cohort undertakes the full induction programme" do
      let(:profile) { create :ect, school_cohort:, lead_provider: }

      context "when the induction programme does not have a lead provider assigned" do
        let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: nil, delivery_partner:) }

        it { is_expected.to have_content "contact your training provider to remove them" }
      end

      it "displays the lead_provider name" do
        expect(rendered).to have_content(lead_provider.name)
      end
    end

    context "when the cohort undertakes the core induction programme" do
      stub_component MailToSupportComponent

      let(:school_cohort) { create :school_cohort, :cip, :with_induction_programme }

      it { is_expected.to have_rendered_component(MailToSupportComponent).with("contact us") }
    end
  end
end
