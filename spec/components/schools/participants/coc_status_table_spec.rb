# frozen_string_literal: true

RSpec.describe Schools::Participants::CocStatusTable, type: :component do
  let(:participant_profile) { create(:ecf_participant_profile, :ecf_participant_eligibility, school_cohort:) }
  let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme: programme) }

  let(:component) { described_class.new induction_records: [induction_record] }

  # stub_component Schools::Participants::CocStatusTableRow

  context "participant is on fip" do
    let(:school_cohort) { create(:school_cohort, :fip) }
    let(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }
    let(:programme) { create(:induction_programme, :fip, school_cohort:, partnership:) }

    context "eligible" do
      it "renders table row" do
        render_inline(component)
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
    let(:cip) { create(:core_induction_programme) }
    let(:school_cohort) { create(:school_cohort, :cip) }
    let(:programme) { create(:induction_programme, :cip, school_cohort:, core_induction_programme: cip) }

    context "eligible" do
      it "renders table row" do
        render_inline(component)

        expect(rendered_content).to have_css("th", text: "Name")
        expect(rendered_content).to have_css("th", text: "Materials supplier")
      end
    end
  end
end
