# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::DeclarationStatementAttacher do
  let(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, :current) }
  let(:cohort_2022) { Cohort.find_by(start_year: 2022) || create(:cohort, :next) }

  let(:schedule_2021) { create(:ecf_schedule, cohort: cohort_2021) }
  let(:schedule_2022) { create(:ecf_schedule, cohort: cohort_2022) }
  let(:npq_schedule_2022) { create(:npq_leadership_schedule, cohort: cohort_2022) }

  let(:declaration) { create(:ect_participant_declaration, cpd_lead_provider:, participant_profile:) }

  let(:ecf_statement_2021) { create(:ecf_statement, output_fee: true, cpd_lead_provider:, deadline_date: 2.months.from_now) }
  let(:ecf_statement_2022) { create(:ecf_statement, output_fee: true, cpd_lead_provider:, deadline_date: 2.months.from_now, cohort: cohort_2022) }

  let(:npq_statement_2022) { create(:npq_statement, output_fee: true, cpd_lead_provider:, deadline_date: 2.months.from_now, cohort: cohort_2022) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:school) { create(:school) }

  let(:school_cohort)    { create(:school_cohort, school:, cohort:) }
  let(:partnership)      { create(:partnership, school: school_cohort.school, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let(:participant_profile) { create(:ect_participant_profile, school_cohort:, cohort:, schedule:) }

  subject { described_class.new(participant_declaration: declaration) }

  describe "#call" do
    context "when cohort 2021" do
      let!(:statement) { ecf_statement_2021 }
      let!(:schedule) { schedule_2021 }
      let(:cohort) { cohort_2021 }

      before do
        Induction::Enrol.call(participant_profile:, induction_programme:)
      end

      it "creates line item" do
        expect {
          subject.call
        }.to change { statement.reload.statement_line_items.count }.by(1)
      end

      it "create line item with same state as declaration" do
        subject.call

        line_item = Finance::StatementLineItem.last
        expect(line_item.state).to eql(declaration.state)
      end
    end

    context "when cohort 2022" do
      let(:cohort) { cohort_2022 }

      context "ECF" do
        let!(:schedule) { schedule_2022 }
        let!(:statement) { ecf_statement_2022 }

        before do
          Induction::Enrol.call(participant_profile:, induction_programme:)
        end

        it "attaches to 2022 statement" do
          subject.call

          expect(statement.participant_declarations).to include(declaration)
        end
      end

      context "NPQ" do
        # let(:npq_course) { create(:npq_leadership_course) }

        let!(:statement) { npq_statement_2022 }
        let(:schedule) { npq_schedule_2022 }
        let(:participant_profile) { create(:npq_participant_profile, schedule:) }
        let(:declaration) { create(:npq_participant_declaration, cpd_lead_provider:, participant_profile:) }

        it "attaches to 2022 statement" do
          subject.call

          expect(statement.participant_declarations).to include(declaration)
        end
      end
    end
  end
end
