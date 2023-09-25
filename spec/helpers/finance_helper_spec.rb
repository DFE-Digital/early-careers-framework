# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinanceHelper, type: :helper do
  describe "#number_to_pounds" do
    context "when negative zero" do
      it "returns unsigned zero" do
        expect(helper.number_to_pounds(BigDecimal("-0"))).to eql("£0.00")
      end
    end
  end

  describe "#float_to_percentage" do
    it "returns the percentage" do
      expect(helper.float_to_percentage(BigDecimal("0.12"))).to eql("12%")
    end
  end

  describe "#latest_induction_record_for_provider?" do
    let(:participant_profile) { create(:ect_participant_profile) }
    subject { latest_induction_record_for_provider?(induction_record, participant_profile) }

    context "when the induction record is the latest for the provider" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort: participant_profile.school_cohort) }
      let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

      it { is_expected.to be(true) }
    end

    context "when the induction record is not the latest for the provider" do
      let!(:induction_record) { create(:induction_record, participant_profile:) }

      it { is_expected.to be(false) }
    end
  end

  describe "#npq_application_api_response" do
    let(:npq_application) { create(:npq_application) }

    subject { npq_application_api_response(npq_application) }

    it { is_expected.to match(%r{<pre><code>}) }
    it { is_expected.to include(npq_application.id) }
  end

  describe "#npq_participant_api_response" do
    let(:npq_participant) { create(:npq_participant_profile) }

    subject { npq_participant_api_response(npq_participant) }

    it { is_expected.to match(%r{<pre><code>}) }
    it { is_expected.to include(npq_participant.id) }
  end

  describe "#induction_record_participant_api_response" do
    let(:induction_record) { create(:induction_record) }
    let(:participant_profile) { induction_record.participant_profile }

    subject { induction_record_participant_api_response(induction_record, participant_profile) }

    it { is_expected.to match(%r{<pre><code>}) }
    it { is_expected.to include(participant_profile.user.id) }
  end

  describe "#change_induction_record_training_status_button" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:row) { double }

    context "when action is displayed" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort: participant_profile.school_cohort) }
      let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

      it "returns the change training status action button" do
        expect(row).to receive(:with_action).with(
          text: "Change",
          visually_hidden_text: "training status",
          href: new_finance_participant_profile_ecf_induction_records_path(participant_profile.id, induction_record.id),
        )

        helper.change_induction_record_training_status_button(induction_record, participant_profile, row)
      end
    end

    context "when action is not displayed" do
      let!(:induction_record) { create(:induction_record, participant_profile:) }

      it "returns the change training status action button" do
        expect(row).to receive(:with_action).with(text: :none)

        helper.change_induction_record_training_status_button(induction_record, participant_profile, row)
      end
    end
  end

  describe "#authorise_for_payment_button_visible?" do
    let!(:participant_declaration) do
      create(
        :ect_participant_declaration,
        :eligible,
      )
    end

    before { participant_declaration.statement_line_items.first.update!(statement:) }

    context "when mark as paid is allowed" do
      let(:statement) { create(:ecf_payable_statement) }

      it "returns true" do
        expect(authorise_for_payment_button_visible?(statement)).to eq(true)
      end
    end

    context "when mark as paid is not allowed" do
      context "already paid statement" do
        let(:statement) { create(:ecf_paid_statement) }

        it "returns false" do
          expect(authorise_for_payment_button_visible?(statement)).to eq(false)
        end
      end

      context "no output fee statement" do
        let(:statement) { create(:ecf_payable_statement, output_fee: false) }

        it "returns false" do
          expect(authorise_for_payment_button_visible?(statement)).to eq(false)
        end
      end

      context "marked as paid statement" do
        let(:statement) { create(:ecf_paid_statement) }

        it "returns false" do
          expect(authorise_for_payment_button_visible?(statement)).to eq(false)
        end
      end

      context "marked as to be paid statement" do
        let(:statement) { create(:ecf_payable_statement, marked_as_paid_at: Time.zone.now) }

        it "returns false" do
          expect(authorise_for_payment_button_visible?(statement)).to eq(false)
        end
      end

      context "deadline date in the future statement" do
        let(:statement) { create(:ecf_payable_statement, deadline_date: Date.tomorrow) }

        it "returns false" do
          expect(authorise_for_payment_button_visible?(statement)).to eq(false)
        end
      end

      context "no participant declarations statement" do
        let(:statement) { create(:ecf_payable_statement) }

        before { participant_declaration.statement_line_items.destroy_all }

        it "returns false" do
          expect(authorise_for_payment_button_visible?(statement)).to eq(false)
        end
      end
    end
  end

  describe "#authorising_for_payment_banner_visible?" do
    context "when statement is payable" do
      context "when mark as paid is set" do
        let(:statement) { create(:ecf_payable_statement, marked_as_paid_at: Time.zone.now) }

        it "returns true" do
          expect(authorising_for_payment_banner_visible?(statement)).to eq(true)
        end
      end

      context "when mark as paid is not set" do
        let(:statement) { create(:ecf_payable_statement) }

        it "returns false" do
          expect(authorising_for_payment_banner_visible?(statement)).to eq(false)
        end
      end
    end

    context "when statement is not payable" do
      let(:statement) { create(:ecf_paid_statement) }

      it "returns false" do
        expect(authorising_for_payment_banner_visible?(statement)).to eq(false)
      end
    end
  end
end
