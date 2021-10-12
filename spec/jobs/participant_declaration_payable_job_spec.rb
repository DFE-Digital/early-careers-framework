# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclarationPayableJob do
  describe "#perform" do
    let!(:declaration) { create(:ect_participant_declaration, :eligible) }

    def execute
      subject.perform
      declaration.reload
    end

    it "enqueues the Payable Job" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class)
    end

    it "updates the declaration state" do
      execute

      expect(declaration.payable?).to be_truthy
    end
  end
end
