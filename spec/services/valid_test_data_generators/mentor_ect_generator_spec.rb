# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::MentorECTGenerator do
  let(:shared_users_data) { YAML.load_file(Rails.root.join("db/data/sandbox_shared_data.yml")) }
  let(:cohort) { create(:cohort, :current) }
  let(:lead_provider) { create(:lead_provider, name: shared_users_data.keys.sample) }

  let(:instance) { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    let(:number) { 1 }
    subject(:generate) { instance.call(number:) }

    context "when the lead provider does not have a partnership for the cohort" do
      it { expect { generate }.not_to change(ParticipantProfile, :count) }
    end

    context "when the cohort has a default schedule and the lead provider has a school" do
      before do
        create(:local_authority)
        create(:partnership, cohort:, lead_provider:)
      end

      it { expect { generate }.to change(ParticipantProfile::ECT, :count).by(number) }
      it { expect { generate }.to change(ParticipantProfile::Mentor, :count).by(number) }

      it "creates participants that can be declared against" do
        created_ect = ParticipantProfile::ECT.last

        ParticipantProfile.find_each do |created_participant|
          schedule_start_date = created_ect.schedule.milestones.first.start_date
          travel_to(schedule_start_date) do
            service = RecordDeclaration.new(
              participant_id: created_ect.user_id,
              course_identifier: created_participant.ect? ? "ecf-induction" : "ecf-mentor",
              declaration_date: schedule_start_date.rfc3339,
              cpd_lead_provider: lead_provider.cpd_lead_provider,
              declaration_type: :started,
            )

            expect(service).to be_valid
          end
        end
      end

      context "when creating multiple participants" do
        let(:number) { 5 }

        it { expect { generate }.to change(ParticipantProfile::ECT, :count).by(number) }
        it { expect { generate }.to change(ParticipantProfile::Mentor, :count).by(number) }
      end
    end
  end
end
