# frozen_string_literal: true

RSpec.describe Schools::Participants::RemoveFromCohortComponent, type: :view_component do
  let(:school_cohort) { create :school_cohort }
  let(:profile) { create :participant_profile, :ecf, school_cohort: school_cohort }
  component { described_class.new(profile: profile) }

  context "when the validation hasn't started yet" do
    it "displays the link to remove the participant" do
      expect(rendered).to have_link(href: schools_participant_remove_path(profile.school, profile.cohort, profile))
    end
  end

  context "when validation already started" do
    let!(:validation_data) { create :ecf_participant_validation_data, participant_profile: profile }

    it "does not display the removal link" do
      expect(rendered).not_to have_link(href: schools_participant_remove_path(profile.school, profile.cohort, profile))
    end

    context "when the cohort undertakes the full induction programme" do
      let(:school_cohort) { create :school_cohort, :fip }

      it { is_expected.to have_content "contact your training provider to remove them" }
    end

    context "when the cohort undertakes the core induction programme" do
      stub_component MailToSupportComponent

      let(:school_cohort) { create :school_cohort, :cip }

      it { is_expected.to have_rendered_component(MailToSupportComponent).with("contact us") }
    end
  end
end
