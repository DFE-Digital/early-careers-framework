# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPayable do
  let(:submission_time) { Time.zone.local(2021, 9, 30).to_s(:db) }
  let(:start_date) { Time.zone.local(2021, 9, 1).to_s(:db) }
  let(:end_date) { Time.zone.local(2021, 11, 1).to_s(:db) }
  let!(:declaration) { create(:ect_participant_declaration, :eligible, declaration_date: submission_time, created_at: submission_time) }

  it "updates the declaration state" do
    expect(declaration.eligible?).to be_truthy
    expect(declaration.payable?).to be_falsey
    described_class.call(start_date: start_date, end_date: end_date)
    declaration.reload
    expect(declaration.eligible?).to be_falsey
    expect(declaration.payable?).to be_truthy
  end
end
