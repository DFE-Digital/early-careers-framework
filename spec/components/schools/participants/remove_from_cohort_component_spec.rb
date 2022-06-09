# frozen_string_literal: true

RSpec.describe Schools::Participants::RemoveFromCohortComponent, type: :view_component do
  let(:school_cohort) { create(:school_cohort, :fip) }
  let(:induction_programme) { create(:induction_programme, :fip, school_cohort:, partnership: nil) }
  let(:profile) { create :ecf_participant_profile, school_cohort: }
  # component { described_class.new(profile:) }
  let(:induction_coordinator) { create(:user, :induction_coordinator, schools: [school_cohort.school]) }
  let(:induction_record) { Induction::Enrol.call(participant_profile: profile, induction_programme:) }
  component { described_class.new(current_user: induction_coordinator, induction_record:) }

  before do
    school_cohort.update!(default_induction_programme: induction_programme)
  end

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
      let(:school_cohort) { create :school_cohort, :fip }
      let(:lead_provider) { create :lead_provider }
      let(:delivery_partner) { create :delivery_partner }

      it { is_expected.to have_content "contact your training provider to remove them" }

      it "displays the lead_provider name" do
        partnership = Partnership.create!(cohort: school_cohort.cohort,
                                          lead_provider:,
                                          school: school_cohort.school,
                                          delivery_partner:)

        induction_programme.update!(partnership:)
        expect(rendered).to have_content(lead_provider.name)
      end
    end

    context "when the cohort undertakes the core induction programme" do
      stub_component MailToSupportComponent

      let(:school_cohort) { create :school_cohort, :cip }
      let(:induction_programme) { create :induction_programme, :cip, school_cohort: }

      it { is_expected.to have_rendered_component(MailToSupportComponent).with("contact us") }
    end
  end
end
