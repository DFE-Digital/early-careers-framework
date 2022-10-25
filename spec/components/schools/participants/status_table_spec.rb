# frozen_string_literal: true

RSpec.describe Schools::Participants::StatusTable, :with_default_schedules, type: :component do
  let!(:participant_profile) { create(:ect, :eligible_for_funding) }
  let(:cip)                  { create(:core_induction_programme) }

  let(:component) { described_class.new participant_profiles: [participant_profile], school_cohort: participant_profile.school_cohort }

  context "participant is on fip" do
    context "eligible" do
      subject! { render_inline(component) }

      it "renders table row" do
        expect(rendered_content).to have_css("th", text: "Name")
        expect(rendered_content).to have_css("th", text: "Lead provider")
        expect(rendered_content).to have_css("th", text: "Delivery partner")
      end
    end

    context "ineligible" do
      it "renders table row" do
        participant_profile.ecf_participant_eligibility.update!(status: "ineligible", previous_induction: true)

        render_inline(component)

        expect(rendered_content).to have_css("th", text: "Name")
        expect(rendered_content).to have_css("th", text: "Action required")
      end
    end
  end

  context "participant is on cip" do
    let(:programme) { create(:induction_programme, :cip) }

    before do
      participant_profile.school_cohort.update!(induction_programme_choice: "core_induction_programme",
                                                core_induction_programme: cip)
      Induction::Enrol.call(participant_profile:, induction_programme: programme)

      render_inline(component)
    end

    context "eligible" do
      it "renders table row" do
        expect(rendered_content).to have_css("th", text: "Name")
        expect(rendered_content).to have_css("th", text: "Materials supplier")
      end
    end
  end
end
