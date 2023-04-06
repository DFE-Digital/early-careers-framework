# frozen_string_literal: true

RSpec.describe Schools::Participants::CocStatusTableRow, type: :component do
  let!(:school_cohort) { create :school_cohort, :fip }
  let!(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }
  let(:participant_profile) { create :ect_participant_profile, school_cohort: }
  let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile:) }
  let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme: programme) }

  let(:component) { described_class.new induction_record: }

  context "participant is on full induction programme" do
    let(:programme) { create(:induction_programme, :fip) }

    context "participant is eligible" do
      it "renders the row" do
        render_inline(component)

        expect(rendered_content).to have_link induction_record.user.full_name, href: "/schools/#{induction_record.school.slug}/participants/#{participant_profile.id}"
        expect(rendered_content).to have_content induction_record.induction_programme.lead_provider.name
        expect(rendered_content).to have_content induction_record.induction_programme.delivery_partner.name
      end
    end

    context "participant is ineligible" do
      it "renders the row" do
        participant_profile.ecf_participant_eligibility.ineligible_status!

        render_inline(component)

        expect(rendered_content).to have_link induction_record.user.full_name, href: "/schools/#{induction_record.school.slug}/participants/#{participant_profile.id}"
        expect(rendered_content).not_to have_content induction_record.induction_programme.lead_provider.name
        expect(rendered_content).not_to have_content induction_record.induction_programme.delivery_partner.name
        expect(rendered_content).to have_text "Remove"
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
        render_inline(component)

        expect(rendered_content).to have_link induction_record.user.full_name, href: "/schools/#{induction_record.school.slug}/participants/#{participant_profile.id}"
        expect(rendered_content).to have_content induction_record.induction_programme.core_induction_programme.name
      end
    end

    context "participant is ineligible" do
      it "renders the row" do
        participant_profile.ecf_participant_eligibility.ineligible_status!

        render_inline(component)

        expect(rendered_content).to have_link induction_record.user.full_name, href: "/schools/#{induction_record.school.slug}/participants/#{participant_profile.id}"
        expect(rendered_content).not_to have_content induction_record.induction_programme.core_induction_programme.name
        expect(rendered_content).to have_text "Remove"
      end
    end
  end
end
