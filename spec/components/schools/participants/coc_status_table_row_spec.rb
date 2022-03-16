# frozen_string_literal: true

RSpec.describe Schools::Participants::CocStatusTableRow, type: :view_component do
  let!(:school_cohort) { create :school_cohort, :fip }
  let!(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }
  let(:participant_profile) { create :ect_participant_profile, school_cohort: school_cohort }
  let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile: participant_profile) }
  let(:induction_record) { Induction::Enrol.call(participant_profile: participant_profile, induction_programme: programme) }

  component { described_class.new induction_record: induction_record }

  context "participant is on full induction programme" do
    let(:programme) { create(:induction_programme, :fip) }

    context "participant is eligible" do
      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link induction_record.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).to have_content induction_record.induction_programme.lead_provider.name
          expect(rendered).to have_content induction_record.induction_programme.delivery_partner.name
          expect(rendered).to have_content induction_record.participant_profile.start_term.humanize
        end
      end
    end

    context "participant is ineligible" do
      it "renders the row" do
        participant_profile.ecf_participant_eligibility.ineligible_status!

        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link induction_record.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).not_to have_content induction_record.induction_programme.lead_provider.name
          expect(rendered).not_to have_content induction_record.induction_programme.delivery_partner.name
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
    end

    context "participant is eligible" do
      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link induction_record.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).to have_content induction_record.induction_programme.core_induction_programme.name
          expect(rendered).to have_content induction_record.participant_profile.start_term.humanize
        end
      end
    end

    context "participant is ineligible" do
      it "renders the row" do
        participant_profile.ecf_participant_eligibility.ineligible_status!

        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered).to have_link induction_record.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered).not_to have_content induction_record.induction_programme.core_induction_programme.name
          expect(rendered).to have_text "Remove"
        end
      end
    end
  end
end
