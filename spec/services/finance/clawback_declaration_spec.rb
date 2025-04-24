# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ClawbackDeclaration do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let!(:participant_declaration) { create(:ect_participant_declaration, :paid, cpd_lead_provider:) }
  let(:participant_profile) { participant_declaration.participant_profile }
  let!(:next_statement) { create(:ecf_statement, :next_output_fee, cpd_lead_provider:, deadline_date: 3.months.from_now) }

  let(:cohort) { Cohort.current }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:, cohort:) }
  let(:partnership) { create(:partnership, school:, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, partnership:) }

  let(:voided_by_user) { nil }

  subject { described_class.new(participant_declaration, voided_by_user:) }

  before do
    if participant_declaration.ecf?
      Induction::Enrol.call(participant_profile:, induction_programme:)
    end
  end

  describe "#call" do
    it "mutates state of declaration to awaiting_clawback" do
      expect { subject.call }.to change { participant_declaration.reload.state }.from("paid").to("awaiting_clawback")
    end

    it "creates correct clawback line item" do
      expect { subject.call }.to change { Finance::StatementLineItem.where(state: "awaiting_clawback", participant_declaration:, statement: next_statement).count }.by(1)
    end

    it "create a correct declaration state record" do
      participant_declaration

      expect {
        subject.call
      }.to change { DeclarationState.where(participant_declaration:, state: "awaiting_clawback").count }.by(1)
    end

    context "when the voided_by_user is nil" do
      it "does not mark as voided by a user" do
        subject.call
        expect(participant_declaration.reload).to have_attributes({ voided_by_user: nil, voided_at: nil })
      end
    end

    context "when the voided_by_user is specified" do
      let(:voided_by_user) { create(:user) }

      it "marks the declaration as voided by the user" do
        subject.call
        expect(participant_declaration.reload).to have_attributes({ voided_by_user:, voided_at: be_within(5.seconds).of(Time.zone.now) })
      end
    end

    context "when there are no output fee statements available" do
      before { next_statement.update!(output_fee: false) }

      it "returns an error" do
        expect(subject).to be_invalid

        cohort = participant_declaration.cohort.start_year
        expect(subject.errors.messages_for(:participant_declaration)).to include(/You cannot submit or void declarations for the #{cohort}/)
      end
    end

    context "when the participant has since changed to a later cohort" do
      before do
        participant_profile.schedule.update!(cohort: cohort.next)
        participant_profile.latest_induction_record.induction_programme.school_cohort.update!(cohort: cohort.next)
      end

      it "will clawback against the statement in the original declaration cohort" do
        expect { subject.call }.to change { Finance::StatementLineItem.where(state: "awaiting_clawback", participant_declaration:, statement: next_statement).count }.by(1)
      end
    end

    context "when declaration already clawed back" do
      before do
        subject.call
      end

      it "does not create a line item" do
        expect { subject.call }.to_not change { participant_declaration.statement_line_items.count }
      end

      it "attaches an error to the object" do
        subject.call

        expect(subject.errors[:participant_declaration]).to be_present
      end

      it "does not call the ParticipantDeclarations::HandleMentorCompletion service" do
        expect_any_instance_of(ParticipantDeclarations::HandleMentorCompletion).not_to receive(:call)
        subject.call
      end
    end

    shared_examples "declaration cannot be clawed back in certain state" do
      it "does not create a line item" do
        expect { subject.call }.to_not change { Finance::StatementLineItem.count }
      end

      it "attaches an error to the object" do
        subject.call

        expect(subject.errors[:participant_declaration]).to be_present
      end

      it "does not call the ParticipantDeclarations::HandleMentorCompletion service" do
        expect_any_instance_of(ParticipantDeclarations::HandleMentorCompletion).not_to receive(:call)
        subject.call
      end
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :ineligible, cpd_lead_provider:) }
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :submitted, cpd_lead_provider:) }
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :eligible, cpd_lead_provider:) }
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :voided, cpd_lead_provider:) }
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :payable, cpd_lead_provider:) }
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :awaiting_clawback, cpd_lead_provider:) }
    end

    it_behaves_like "declaration cannot be clawed back in certain state" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :clawed_back, cpd_lead_provider:) }
    end

    it "calls the ParticipantDeclarations::HandleMentorCompletion service" do
      expect_any_instance_of(ParticipantDeclarations::HandleMentorCompletion).to receive(:call)
      subject.call
    end
  end
end
