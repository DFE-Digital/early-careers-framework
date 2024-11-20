# frozen_string_literal: true

describe Oneoffs::NPQ::MigrateDeclarationsBetweenStatements, mid_cohort: true do
  let(:from_statement_updates) { {} }
  let(:to_statement_updates) { {} }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:from_statement) { create(:npq_statement, name: "April 2023", cpd_lead_provider:, cohort:, output_fee: true) }
  let(:to_statement) { create(:npq_statement, :next_output_fee, name: "May 2023", cpd_lead_provider:, cohort:) }
  let(:from_statement_name) { from_statement.name }
  let(:to_statement_name) { to_statement.name }
  let(:cohort) { Cohort.current }
  let(:restrict_to_lead_providers) { nil }
  let(:restrict_to_declaration_types) { nil }
  let(:restrict_to_declaration_states) { nil }
  let(:restrict_to_course_identifiers) { nil }

  let(:instance) do
    described_class.new(
      cohort:,
      from_statement_name:,
      to_statement_name:,
      from_statement_updates:,
      to_statement_updates:,
      restrict_to_lead_providers:,
      restrict_to_declaration_types:,
      restrict_to_declaration_states:,
      restrict_to_course_identifiers:,
    )
  end

  before { allow(Rails.logger).to receive(:info) }

  describe "#migrate" do
    let(:dry_run) { false }

    subject(:migrate) { instance.migrate(dry_run:) }

    it { is_expected.to eq(instance.recorded_info) }

    context "when there are declarations" do
      let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
      let(:declaration) { create(:npq_participant_declaration, :payable, cohort:, cpd_lead_provider:, declaration_type: :started, npq_course:) }
      let(:from_statement) { declaration.statements.first }

      let(:cpd_lead_provider2) { declaration2.cpd_lead_provider }
      let(:npq_lead_provider2) { cpd_lead_provider2.npq_lead_provider }
      let(:npq_course2) { create(:npq_course, identifier: "npq-leading-behaviour-culture") }
      let(:declaration2) { create(:npq_participant_declaration, :eligible, cohort:, declaration_type: :"retained-1", npq_course: npq_course2) }
      let!(:from_statement2) { declaration2.statements.first.tap { |s| s.update!(name: from_statement.name) } }
      let!(:to_statement2) { create(:npq_statement, :next_output_fee, name: to_statement.name, cpd_lead_provider: cpd_lead_provider2, cohort:) }

      let(:declarations) { [declaration1, declaration2] }

      it "migrates them to the new statement" do
        migrate

        expect(declaration.statement_line_items.map(&:statement)).to all(eq(to_statement))
        expect(declaration2.statement_line_items.map(&:statement)).to all(eq(to_statement2))
      end

      it "records information" do
        migrate

        expect(instance).to have_recorded_info([
          "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 2 providers",
          "Migrating 1 declarations for #{npq_lead_provider.name}",
          "Migrating 1 declarations for #{npq_lead_provider2.name}",
        ])
      end

      context "when restrict_to_lead_providers is provided" do
        let(:restrict_to_lead_providers) { [npq_lead_provider] }

        it "migrates only the declarations for the given lead provider to the new statement" do
          migrate

          expect(declaration.statement_line_items.map(&:statement)).to all(eq(to_statement))
          expect(declaration2.statement_line_items.map(&:statement)).to all(eq(from_statement2))
        end

        it "records information" do
          migrate

          expect(instance).to have_recorded_info([
            "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 1 providers",
            "Migrating 1 declarations for #{npq_lead_provider.name}",
          ])
        end
      end

      context "when restrict_to_declaration_types is provided" do
        let(:restrict_to_declaration_types) { [:started] }

        it "migrates only the declarations with the given declaration type" do
          migrate

          expect(declaration.statement_line_items.map(&:statement)).to all(eq(to_statement))
          expect(declaration2.statement_line_items.map(&:statement)).to all(eq(from_statement2))
        end

        it "records information" do
          migrate

          expect(instance).to have_recorded_info([
            "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 2 providers",
            "Migrating 1 declarations for #{npq_lead_provider.name}",
            "Migrating 0 declarations for #{npq_lead_provider2.name}",
          ])
        end

        context "when restrict_to_declaration_types contains a string" do
          let(:restrict_to_declaration_types) { %w[retained-1] }

          it "migrates only the declarations with the given declaration type" do
            migrate

            expect(declaration2.statement_line_items.map(&:statement)).to all(eq(to_statement2))
            expect(declaration.statement_line_items.map(&:statement)).to all(eq(from_statement))
          end
        end
      end

      context "when restrict_to_declaration_states is provided" do
        let(:restrict_to_declaration_states) { [:eligible] }

        it "migrates only the declarations with the given declaration type" do
          migrate

          expect(declaration.statement_line_items.map(&:statement)).to all(eq(from_statement))
          expect(declaration2.statement_line_items.map(&:statement)).to all(eq(to_statement2))
        end

        it "records information" do
          migrate

          expect(instance).to have_recorded_info([
            "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 2 providers",
            "Migrating 0 declarations for #{npq_lead_provider.name}",
            "Migrating 1 declarations for #{npq_lead_provider2.name}",
          ])
        end

        context "when restrict_to_declaration_types contains a string" do
          let(:restrict_to_declaration_states) { %w[eligible] }

          it "migrates only the declarations with the given declaration type" do
            migrate

            expect(declaration.statement_line_items.map(&:statement)).to all(eq(from_statement))
            expect(declaration2.statement_line_items.map(&:statement)).to all(eq(to_statement2))
          end
        end
      end

      context "when from_statement_updates are provided" do
        let(:from_statement_updates) { { output_fee: false } }

        it "updates the to statements" do
          migrate

          expect(from_statement.reload).to have_attributes(from_statement_updates)
          expect(instance).to have_recorded_info([
            "Statement #{from_statement.name} for #{from_statement.npq_lead_provider.name} updated with #{from_statement_updates}",
          ])
        end
      end

      context "when to_statement_updates are provided" do
        let(:to_statement_updates) { { deadline_date: 5.days.from_now.to_date, payment_date: 2.days.from_now.to_date } }

        it "updates the to statements" do
          migrate

          expect(to_statement.reload).to have_attributes(to_statement_updates)
          expect(instance).to have_recorded_info([
            "Statement #{to_statement.name} for #{to_statement.npq_lead_provider.name} updated with #{to_statement_updates}",
          ])
        end
      end

      context "when dry_run is true" do
        let(:dry_run) { true }

        it "does not make any changes, but logs out as if it does" do
          expect { migrate }.not_to change { declaration.statement_line_items.first.reload.statement }

          expect(instance).to have_recorded_info([
            "~~~ DRY RUN ~~~",
            "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 2 providers",
            "Migrating 1 declarations for #{npq_lead_provider.name}",
            "Migrating 1 declarations for #{npq_lead_provider2.name}",
          ])
        end
      end

      context "when restrict_to_course_identifiers is provided" do
        let(:restrict_to_course_identifiers) { [declaration2.course_identifier] }

        it "migrates only the declarations with the given course identifier" do
          migrate

          expect(declaration.statement_line_items.map(&:statement)).to all(eq(from_statement))
          expect(declaration2.statement_line_items.map(&:statement)).to all(eq(to_statement2))
        end

        it "records information" do
          migrate

          expect(instance).to have_recorded_info([
            "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 2 providers",
            "Migrating 0 declarations for #{npq_lead_provider.name}",
            "Migrating 1 declarations for #{npq_lead_provider2.name}",
          ])
        end
      end
    end

    context "when migrating to a payable statement" do
      let(:to_statement) { create(:npq_payable_statement, name: "May 2023", cpd_lead_provider:, cohort:) }
      let(:declaration) { create(:npq_participant_declaration, :eligible, cohort:, cpd_lead_provider:) }
      let(:from_statement) { declaration.statements.first }

      it "migrates eligible declarations to the new statement and makes them payable" do
        migrate

        declaration.reload

        expect(declaration.statement_line_items.map(&:statement)).to all(eq(to_statement))
        expect(declaration).to be_payable
      end

      it "records information" do
        migrate

        expect(instance).to have_recorded_info([
          "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 1 providers",
          "Migrating 1 declarations for #{npq_lead_provider.name}",
          "Marking 1 eligible declarations as payable for #{to_statement_name} statement",
        ])
      end

      context "when there are declarations awaiting_clawback" do
        let(:declaration) { create(:npq_participant_declaration, :awaiting_clawback, cohort:, cpd_lead_provider:) }
        let(:awaiting_clawback_line_item) { declaration.statement_line_items.find(&:awaiting_clawback?) }
        let(:from_statement) { awaiting_clawback_line_item.statement }

        # Fixes flakey test where the paid statement and awaiting clawback statement can
        # end up with the same name, resulting in an exception from the migration operation
        # as we don't allow migrating from paid statements.
        before { from_statement.update!(name: "#{from_statement.name} - Clawback") }

        it "migrates them, but does not make them payable" do
          migrate

          declaration.reload

          migrated_statement_line_item = declaration.statement_line_items.find(&:awaiting_clawback?)
          expect(migrated_statement_line_item.statement).to eq(to_statement)
          expect(declaration).to be_awaiting_clawback
          expect(instance.recorded_info).not_to include(/eligible declarations as payable/)
        end
      end

      context "when there are declarations are already payable" do
        let(:declaration) { create(:npq_participant_declaration, :payable, cohort:, cpd_lead_provider:) }
        let(:from_statement) { declaration.statement_line_items.first.statement }

        it "migrates them, but does not attempt to make them payable" do
          migrate

          declaration.reload

          expect(declaration.statement_line_items.map(&:statement)).to all(eq(to_statement))
          expect(declaration).to be_payable
          expect(instance.recorded_info).not_to include(/eligible declarations as payable/)
        end
      end
    end

    context "when migrating to an eligible statement" do
      let(:to_statement) { create(:npq_statement, name: "May 2023", cpd_lead_provider:, cohort:) }
      let(:declaration) { create(:npq_participant_declaration, :payable, cohort:, cpd_lead_provider:) }
      let(:from_statement) { declaration.statements.first }

      it "migrates payable declarations to the new statement and makes them eligible" do
        migrate

        declaration.reload

        expect(declaration.statement_line_items.map(&:statement)).to all(eq(to_statement))
        expect(declaration).to be_eligible
      end

      it "records information" do
        migrate

        expect(instance).to have_recorded_info([
          "Migrating declarations from #{from_statement_name} to #{to_statement_name} for 1 providers",
          "Migrating 1 declarations for #{npq_lead_provider.name}",
          "Marking 1 payable declarations back as eligible for #{to_statement_name} statement",
        ])
      end
    end

    context "when migrating from a paid statement" do
      let(:declaration) { create(:npq_participant_declaration, :paid, cohort:, cpd_lead_provider:) }
      let(:from_statement) { declaration.statements.first }

      it { expect { migrate }.to raise_error(described_class::PaidStatementMigrationError, "Cannot migrate from a paid statement") }
    end

    describe "integrity checks" do
      context "when there is a mismatch between the number of statements" do
        let!(:mismatched_statement) { create(:npq_statement, cohort:, name: from_statement.name, output_fee: true) }

        it { expect { migrate }.to raise_error(described_class::StatementMismatchError, "There is a mismatch between to/from statements") }
      end

      context "when a to statement has a deadline date in the past" do
        before do
          to_statement.update!(deadline_date: 1.day.ago)
          migrate
        end

        it { expect(instance).to have_recorded_info(["Warning: to statements are not future dated"]) }
      end

      context "when attempting to migrate between statements on different cohorts" do
        let(:other_cohort) { Cohort.previous }

        before { from_statement.update!(cohort: other_cohort) }

        it { expect { migrate }.to raise_error(described_class::StatementMismatchError, "There is a mismatch between to/from statements") }
      end

      context "when attempting to migrate ECF statements" do
        let(:from_statement) { create(:ecf_statement, name: "April 2023", cpd_lead_provider:, output_fee: true) }

        it { expect { migrate }.to raise_error(described_class::StatementMismatchError, "There is a mismatch between to/from statements") }
      end

      context "when there are no statements found" do
        let(:from_statement_name) { "Not found" }
        let(:to_statement_name) { "Not found" }

        it { expect { migrate }.to raise_error(described_class::StatementMismatchError, "No statements were found") }
      end
    end
  end
end
