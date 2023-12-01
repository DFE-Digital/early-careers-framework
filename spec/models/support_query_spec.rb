# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportQuery, type: :model do
  it "has a valid factory" do
    expect(build(:support_query)).to be_valid
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }
  end

  describe "enqueue_support_query_sync_job" do
    it "enqueues a job" do
      support_query = create(:support_query)
      expect {
        support_query.enqueue_support_query_sync_job
      }.to have_enqueued_job(SupportQuerySyncJob).with(support_query)
    end
  end

  describe "sync_to_support_queue" do
    it "sends the ticket to Zendesk and stores the resulting ID" do
      support_query = build(:support_query)
      expect(support_query.zendesk_ticket_id).to eq(nil)

      response_ticket_id = rand(1_000_000)
      allow(Rails.application.config.zendesk_client).to receive_message_chain(:users, :search).and_return([double(id: SecureRandom.uuid, email: support_query.user.email)])
      allow(ZendeskAPI::Ticket).to receive(:create!).and_return(double(id: response_ticket_id))

      expect(support_query.sync_to_support_queue).to eq(response_ticket_id)
      expect(support_query.zendesk_ticket_id).to eq(response_ticket_id)
    end
  end

  describe "comment_body" do
    it "returns a string" do
      support_query = build(:support_query)
      expect(support_query.comment_body).to be_a(String)
    end

    it "includes the user message" do
      support_query = build(:support_query)
      expect(support_query.comment_body).to eq(
        <<~BODY,
          #{support_query.message}

          ---

          Ticket Created By:
          User ID: #{support_query.user.id}
          Name: #{support_query.user.full_name}
          Email: #{support_query.user.email}

          School:
          No school provided

          Participant Profile:
          No participant profile provided

        BODY
      )
    end
  end
end
