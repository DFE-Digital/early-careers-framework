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
        BODY
      )
    end

    it "includes additional information" do
      school = create(:school)
      cohort_year = rand(2020..2030)
      cohort = NewSeeds::Scenarios::Cohorts::Cohort.new(start_year: cohort_year)
                                                   .build
                                                   .with_schedule_and_milestone
                                                   .cohort
      school_cohort = NewSeeds::Scenarios::SchoolCohorts::Fip
        .new(cohort:, school:)
        .build
        .with_partnership(lead_provider: create(:lead_provider), delivery_partner: create(:delivery_partner))
        .with_programme(default_induction_programme: true)
        .school_cohort
      participant_profile = NewSeeds::Scenarios::Participants::Ects::EctInTraining
                              .new(school_cohort:)
                              .build
                              .participant_profile

      support_query = build(:support_query, additional_information: {
        participant_profile_id: participant_profile.id,
        school_id: school.id,
        cohort_year:,
      })

      expect(support_query.comment_body).to match(
        <<~BODY,
          #{support_query.message}

          ---

          Ticket Created By:
          User ID: #{support_query.user.id}
          Name: #{support_query.user.full_name}
          Email: #{support_query.user.email}

          School:
          URN: #{school.urn}
          Name: #{school.name}

          Participant Profile:
          User ID: #{participant_profile.user.id}
          Participant Profile ID: #{participant_profile.id}
          Current Name: #{participant_profile.user.full_name}
          Current Email: #{participant_profile.user.email}
          Current Lead Provider: #{participant_profile.lead_provider.name}
          Current Delivery Partner: #{participant_profile.delivery_partner.name}
          Current Cohort: #{participant_profile.cohort_start_year}
          Current Induction Status: #{participant_profile.latest_induction_record.induction_status}
          Current Training Status: #{participant_profile.latest_induction_record.training_status}
          Current Type: #{participant_profile.participant_type}
        BODY
      )
    end
  end
end
