# frozen_string_literal: true

RSpec.describe Finance::NPQ::ParticipantOutcomes::Table, type: :component do
  let(:participant_declaration) { create :npq_participant_declaration }
  let(:component) { described_class.new participant_declaration: }

  subject { render_inline(component) }

  context "no outcomes" do
    it { is_expected.to have_table_row_count(0) }
  end

  context "failed outcome" do
    let!(:participant_outcome) { create :participant_outcome, :failed, participant_declaration: }

    it "renders correctly" do
      is_expected.to have_table_row_count(1)
      is_expected.to have_table_text("Failed", col: 1)
      is_expected.to have_table_text(participant_outcome.completion_date.to_fs(:govuk), col: 2)
      is_expected.to have_table_text(participant_outcome.created_at.to_date.to_fs(:govuk), col: 3)
      is_expected.to have_table_text("N/A", col: 4)
      is_expected.to have_table_text("Pending", col: 5)
      is_expected.not_to have_table_text("Resend", col: 6)
      is_expected.to have_table_caption("Declaration Outcomes: Failed")
    end
  end

  context "voided outcome" do
    let!(:participant_outcome) { create :participant_outcome, :voided, participant_declaration: }

    it "renders correctly" do
      is_expected.to have_table_row_count(1)
      is_expected.to have_table_text("Voided", col: 1)
      is_expected.to have_table_text(participant_outcome.completion_date.to_fs(:govuk), col: 2)
      is_expected.to have_table_text(participant_outcome.created_at.to_date.to_fs(:govuk), col: 3)
      is_expected.to have_table_text("N/A", col: 4)
      is_expected.to have_table_text("Pending", col: 5)
      is_expected.not_to have_table_text("Resend", col: 6)
      is_expected.to have_table_caption("Declaration Outcomes")
    end
  end

  context "passed outcome" do
    context "before TRA" do
      let!(:participant_outcome) { create :participant_outcome, :passed, participant_declaration:, sent_to_qualified_teachers_api_at: nil }

      it "renders correctly" do
        is_expected.to have_table_row_count(1)
        is_expected.to have_table_text("Passed", col: 1)
        is_expected.to have_table_text(participant_outcome.completion_date.to_fs(:govuk), col: 2)
        is_expected.to have_table_text(participant_outcome.created_at.to_date.to_fs(:govuk), col: 3)
        is_expected.to have_table_text("N/A", col: 4)
        is_expected.to have_table_text("Pending", col: 5)
        is_expected.not_to have_table_text("Resend", col: 6)
        is_expected.to have_table_caption("Declaration Outcomes: Passed")
      end
    end

    context "sent to TRA" do
      let(:tra_datetime) { Time.zone.now }
      let!(:participant_outcome) { create :participant_outcome, :passed, participant_declaration:, sent_to_qualified_teachers_api_at: tra_datetime }

      it "renders correctly" do
        is_expected.to have_table_row_count(1)
        is_expected.to have_table_text("Passed", col: 1)
        is_expected.to have_table_text(participant_outcome.completion_date.to_fs(:govuk), col: 2)
        is_expected.to have_table_text(participant_outcome.created_at.to_date.to_fs(:govuk), col: 3)
        is_expected.to have_table_text(tra_datetime.to_date.to_fs(:govuk), col: 4)
        is_expected.to have_table_text("Pending", col: 5)
        is_expected.not_to have_table_text("Resend", col: 6)
        is_expected.to have_table_caption("Declaration Outcomes")
      end
    end

    context "successfully sent to TRA" do
      let(:tra_datetime) { Time.zone.now }
      let!(:participant_outcome) { create :participant_outcome, :passed, participant_declaration:, sent_to_qualified_teachers_api_at: tra_datetime, qualified_teachers_api_request_successful: true }

      it "renders correctly" do
        is_expected.to have_table_row_count(1)
        is_expected.to have_table_text("Passed", col: 1)
        is_expected.to have_table_text(participant_outcome.completion_date.to_fs(:govuk), col: 2)
        is_expected.to have_table_text(participant_outcome.created_at.to_date.to_fs(:govuk), col: 3)
        is_expected.to have_table_text(tra_datetime.to_date.to_fs(:govuk), col: 4)
        is_expected.to have_table_text("YES", col: 5)
        is_expected.not_to have_table_text("Resend", col: 6)
        is_expected.to have_table_caption("Declaration Outcomes: Passed and recorded")
      end
    end

    context "unsuccessfully sent to TRA" do
      let(:tra_datetime) { Time.zone.now }
      let!(:participant_outcome) { create :participant_outcome, :passed, participant_declaration:, sent_to_qualified_teachers_api_at: tra_datetime, qualified_teachers_api_request_successful: false }

      it "renders correctly" do
        is_expected.to have_table_row_count(1)
        is_expected.to have_table_text("Passed", col: 1)
        is_expected.to have_table_text(participant_outcome.completion_date.to_fs(:govuk), col: 2)
        is_expected.to have_table_text(participant_outcome.created_at.to_date.to_fs(:govuk), col: 3)
        is_expected.to have_table_text(tra_datetime.to_date.to_fs(:govuk), col: 4)
        is_expected.to have_table_text("NO. CONTACT THE DIGITAL SERVICE TEAM", col: 5)
        is_expected.to have_table_text("Resend", col: 6)
        is_expected.to have_table_caption("Declaration Outcomes: Passed but not recorded")
      end
    end
  end

  def have_table_text(txt, col:)
    have_css(".govuk-table__body > .govuk-table__row > .govuk-table__cell:nth-child(#{col})", text: txt)
  end

  def have_table_row_count(count)
    have_css(".govuk-table__body > .govuk-table__row", count:)
  end

  def have_table_caption(txt)
    have_css(".govuk-table__caption", text: txt)
  end
end
