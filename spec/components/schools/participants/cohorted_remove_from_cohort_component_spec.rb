# frozen_string_literal: true

RSpec.describe Schools::Participants::RemoveFromCohortComponent, :with_default_schedules, type: :component do
  let(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
  let(:delivery_partner) { create :delivery_partner }
  let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider:, delivery_partner:) }
  let(:profile) { create :ect, school_cohort:, lead_provider: }
  let(:induction_record) { profile.current_induction_record }
  let(:induction_coordinator) { create(:user, :induction_coordinator, schools: [school_cohort.school]) }

  let(:component) { described_class.new(current_user: induction_coordinator, induction_record:) }

  context "when the validation hasn’t started yet" do
    subject! { render_inline(component) }

    it "displays the link to remove the participant" do
      expect(rendered_content).to have_link(href: schools_cohort_participant_remove_path(induction_record.school,
                                                                                         school_cohort.cohort,
                                                                                         profile))
    end
  end

  context "when validation already started" do
    let!(:validation_data) { create :ecf_participant_validation_data, participant_profile: profile }

    subject! { render_inline(component) }

    it "does not display the removal link" do
      expect(rendered_content).not_to have_link(href: schools_cohort_participant_remove_path(induction_record.school,
                                                                                             school_cohort.cohort,
                                                                                             profile))
    end

    context "when the cohort undertakes the full induction programme" do
      let(:profile) { create :ect, school_cohort:, lead_provider: }

      subject! { render_inline(component) }

      context "when the induction programme does not have a lead provider assigned" do
        let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: nil, delivery_partner:) }

        it { is_expected.to have_content "contact your training provider to remove them" }
      end

      it "displays the lead_provider name" do
        expect(rendered_content).to have_content(lead_provider.name)
      end
    end

    context "when the cohort undertakes the core induction programme" do
      let(:school_cohort) { create :school_cohort, :cip, :with_induction_programme }

      subject! { render_inline(component) }

      it { is_expected.to have_content("contact us") }
    end
  end
end
