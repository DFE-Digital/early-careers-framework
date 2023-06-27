# frozen_string_literal: true

RSpec.describe Finance::DeclarationStatementAttacher do
  let(:previous_cohort) { Cohort.previous || create(:cohort, :previous) }
  let(:current_cohort) { Cohort.current || create(:cohort, :current) }

  let(:schedule_previous_cohort) { create(:ecf_schedule, cohort: previous_cohort) }
  let(:schedule_current_cohort) { create(:ecf_schedule, cohort: current_cohort) }
  let(:npq_schedule_current_cohort) { create(:npq_leadership_schedule, cohort: current_cohort) }

  let(:declaration) { create(:ect_participant_declaration, cpd_lead_provider:, participant_profile:, state: "eligible") }

  let(:ecf_statement_previous_cohort) { create(:ecf_statement, output_fee: true, cpd_lead_provider:, deadline_date: 2.months.from_now, cohort: previous_cohort) }
  let(:ecf_statement_current_cohort) { create(:ecf_statement, output_fee: true, cpd_lead_provider:, deadline_date: 2.months.from_now, cohort: current_cohort) }

  let(:npq_statement_current_cohort) { create(:npq_statement, output_fee: true, cpd_lead_provider:, deadline_date: 2.months.from_now, cohort: current_cohort) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:school) { create(:school) }

  let(:school_cohort)    { create(:school_cohort, school:, cohort:) }
  let(:partnership)      { create(:partnership, school: school_cohort.school, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let(:participant_profile) { create(:ect_participant_profile, school_cohort:, cohort:, schedule:) }

  subject { described_class.new(declaration) }

  describe "#call" do
    context "when previous cohort" do
      let!(:statement) { ecf_statement_previous_cohort }
      let!(:schedule) { schedule_previous_cohort }
      let(:cohort) { previous_cohort }

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

    context "when current cohort" do
      let(:cohort) { current_cohort }

      context "ECF" do
        let!(:schedule) { schedule_current_cohort }
        let!(:statement) { ecf_statement_current_cohort }

        before do
          Induction::Enrol.call(participant_profile:, induction_programme:)
        end

        it "attaches to current cohort statement" do
          subject.call

          expect(statement.participant_declarations).to include(declaration)
        end
      end

      context "NPQ" do
        let!(:statement) { npq_statement_current_cohort }
        let(:schedule) { npq_schedule_current_cohort }
        let(:participant_profile) { declaration.participant_profile }
        let(:declaration) { create(:npq_participant_declaration, cpd_lead_provider:, state: "eligible") }

        before do
          participant_profile.update! schedule:
        end

        it "attaches to current cohort statement" do
          subject.call

          expect(statement.participant_declarations).to include(declaration)
        end
      end
    end
  end
end
