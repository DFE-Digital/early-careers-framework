# frozen_string_literal: true

RSpec.describe Schools::Participants::StatusTableRow, :with_default_schedules, type: :component do
  let(:participant_profile) { create :ect, :eligible_for_funding }
  let(:school_cohort)       { participant_profile.school_cohort }

  let(:component) { described_class.new profile: participant_profile }

  context "participant is on full induction programme" do
    let(:programme) { create(:induction_programme, :fip) }

    before do
      Induction::Enrol.call(participant_profile:, induction_programme: programme)
    end

    context "participant is eligible" do
      subject! { render_inline(component) }

      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered_content).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered_content).to have_content participant_profile.school_cohort.lead_provider.name
          expect(rendered_content).to have_content participant_profile.school_cohort.delivery_partner.name
        end
      end
    end

    context "participant is ineligible" do
      before do
        participant_profile.ecf_participant_eligibility.ineligible_status!
        render_inline(component)
      end

      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          expect(rendered_content).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered_content).not_to have_content participant_profile.school_cohort.lead_provider.name
          expect(rendered_content).not_to have_content participant_profile.school_cohort.delivery_partner.name
          expect(rendered_content).to have_text "Remove"
        end
      end
    end
  end

  context "participant is on core induction programme" do
    subject! { render_inline(component) }

    let(:programme) { create(:induction_programme, :cip) }

    before do
      school_cohort.core_induction_programme!
      school_cohort.update!(core_induction_programme: create(:core_induction_programme))
      Induction::Enrol.call(participant_profile:, induction_programme: programme)
    end

    context "participant is eligible" do
      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          render_inline(component)
          expect(rendered_content).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered_content).to have_content school_cohort.core_induction_programme.name
        end
      end
    end

    context "participant is ineligible" do
      subject! { render_inline(component) }

      it "renders the row" do
        with_request_url "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants" do
          participant_profile.ecf_participant_eligibility.ineligible_status!
          render_inline(component)

          expect(rendered_content).to have_link participant_profile.user.full_name, href: "/schools/#{school_cohort.school.slug}/cohorts/#{school_cohort.cohort.start_year}/participants/#{participant_profile.id}"
          expect(rendered_content).not_to have_content school_cohort.core_induction_programme.name
          expect(rendered_content).to have_text "Remove"
        end
      end
    end
  end
end
