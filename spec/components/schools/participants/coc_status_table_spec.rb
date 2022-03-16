# frozen_string_literal: true

RSpec.describe Schools::Participants::CocStatusTable, type: :view_component do
  let(:participant_profile) { create(:ecf_participant_profile, :ecf_participant_eligibility, school_cohort: school_cohort) }
  let(:induction_record) { Induction::Enrol.call(participant_profile: participant_profile, induction_programme: programme) }

  component { described_class.new induction_records: [induction_record] }

  stub_component Schools::Participants::CocStatusTableRow

  context "participant is on fip" do
    let(:school_cohort) { create(:school_cohort, :fip) }
    let(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }
    let(:programme) { create(:induction_programme, :fip, school_cohort: school_cohort, partnership: partnership) }

    context "eligible" do
      it "renders table row" do
        expect(rendered).to have_rendered(Schools::Participants::CocStatusTableRow).with(induction_record: induction_record)
        expect(rendered).to have_css("th", text: "Name")
        expect(rendered).to have_css("th", text: "Lead provider")
        expect(rendered).to have_css("th", text: "Delivery partner")
        expect(rendered).to have_css("th", text: "Induction start")
      end
    end

    context "ineligible" do
      it "renders table row" do
        participant_profile.ecf_participant_eligibility.update!(status: "ineligible", previous_induction: true)

        expect(rendered).to have_rendered(Schools::Participants::CocStatusTableRow).with(induction_record: induction_record)
        expect(rendered).to have_css("th", text: "Name")
        expect(rendered).to have_css("th", text: "Action required")
      end
    end
  end

  context "participant is on cip" do
    let(:cip) { create(:core_induction_programme) }
    let(:school_cohort) { create(:school_cohort, :cip) }
    let(:programme) { create(:induction_programme, :cip, school_cohort: school_cohort, core_induction_programme: cip) }

    context "eligible" do
      it "renders table row" do
        expect(rendered).to have_rendered(Schools::Participants::CocStatusTableRow).with(induction_record: induction_record)
        expect(rendered).to have_css("th", text: "Name")
        expect(rendered).to have_css("th", text: "Materials supplier")
        expect(rendered).to have_css("th", text: "Induction start")
      end
    end
  end
end
