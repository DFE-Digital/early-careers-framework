# frozen_string_literal: true

RSpec.describe Schools::Participants::StatusTableRow, :with_default_schedules, type: :view_component do
  let(:participant_profile) { create :ect, :eligible_for_funding }
  let(:school_cohort)       { participant_profile.school_cohort }

  component { described_class.new profile: participant_profile }

  context "participant is on full induction programme" do
    let(:programme) { create(:induction_programme, :fip) }

    before do
      Induction::Enrol.call(participant_profile:, induction_programme: programme)
    end

    context "participant is eligible" do
      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).to have_content participant_profile.school_cohort.lead_provider.name
          expect(rendered).to have_content participant_profile.school_cohort.delivery_partner.name
        end
      end
    end

    context "participant is ineligible" do
      it "renders the row" do
        participant_profile.ecf_participant_eligibility.ineligible_status!

        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).not_to have_content participant_profile.school_cohort.lead_provider.name
          expect(rendered).not_to have_content participant_profile.school_cohort.delivery_partner.name
          expect(rendered).to have_text "Remove"
        end
      end
    end
  end

  context "participant is on core induction programme" do
    let(:programme) { create(:induction_programme, :cip) }

    before do
      school_cohort.core_induction_programme!
      school_cohort.update!(core_induction_programme: create(:core_induction_programme))
      Induction::Enrol.call(participant_profile:, induction_programme: programme)
    end

    context "participant is eligible" do
      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).to have_content school_cohort.core_induction_programme.name
        end
      end
    end

    context "participant is ineligible" do
      it "renders the row" do
        participant_profile.ecf_participant_eligibility.ineligible_status!

        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).not_to have_content school_cohort.core_induction_programme.name
          expect(rendered).to have_text "Remove"
        end
      end
    end
  end
end
