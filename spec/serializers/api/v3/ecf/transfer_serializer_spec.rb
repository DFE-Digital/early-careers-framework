# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.shared_examples "sets an incomplete transfer" do
        let(:expected_transfer) do
          {
            training_record_id: expected_participant_profile.id,
            transfer_type: "unknown",
            status: "incomplete",
            created_at: expected_created_at.rfc3339,
            leaving: {
              school_urn: expected_leaving_school.urn,
              provider: lead_provider&.name,
              date: end_date.strftime("%Y-%m-%d"),
            },
            joining: nil,
          }
        end

        it "sets correct transfer attributes" do
          expect(transfer).to eq(expected_transfer)
        end
      end

      RSpec.shared_examples "sets a complete transfer" do
        let(:expected_transfer) do
          {
            training_record_id: participant_profile.id,
            transfer_type: expected_transfer_type,
            status: "complete",
            created_at: expected_created_at.rfc3339,
            leaving: {
              school_urn: leaving_school_cohort.school.urn,
              provider: expected_leaving_provider&.name,
              date: end_date.strftime("%Y-%m-%d"),
            },
            joining: {
              school_urn: joining_school_cohort.school.urn,
              provider: expected_joining_provider&.name,
              date: expected_joining_date.strftime("%Y-%m-%d"),
            },
          }
        end

        it "sets correct transfer attributes" do
          expect(transfer).to eq(expected_transfer)
        end
      end

      RSpec.describe TransferSerializer, :with_default_schedules do
        describe "serialization" do
          let!(:cohort) { Cohort.current || create(:cohort, :current) }
          let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
          let(:lead_provider) { cpd_lead_provider.lead_provider }
          let(:leaving_partnership) { create(:partnership, lead_provider:, cohort:) }
          let(:leaving_school_cohort) { create(:school_cohort, cohort:) }
          let(:leaving_induction_programme) { create(:induction_programme, :fip, partnership: leaving_partnership, school_cohort: leaving_school_cohort) }
          let!(:leaving_induction_record) do
            create(:induction_record, :leaving, :preferred_identity, induction_programme: leaving_induction_programme, end_date:)
          end
          let(:participant_profile) { leaving_induction_record.participant_profile }
          let(:user) { participant_profile.user }
          let(:end_date) { Time.zone.now }
          let(:transfer) { subject.serializable_hash[:data][:attributes][:transfers].first }

          subject { described_class.new(user, params: { cpd_lead_provider: }) }

          it "sets the ID as the user ID" do
            expect(subject.serializable_hash[:data][:id]).to eq(user.id)
          end

          it "sets the type" do
            expect(subject.serializable_hash[:data][:type]).to eq(:'participant-transfer')
          end

          it "returns the latest induction record updated_at" do
            expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(leaving_induction_record.updated_at.rfc3339)
          end

          context "when leaving SIT triggers a FIP transfer" do
            let(:expected_leaving_school) { leaving_school_cohort.school }
            let(:expected_participant_profile) { participant_profile }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it_behaves_like "sets an incomplete transfer"
          end

          context "when joining SIT triggers a FIP transfer with same lead provider" do
            let(:joining_partnership) { create(:partnership, lead_provider:, cohort:) }
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: end_date, participant_profile:)
            end
            let(:expected_transfer_type) { "new_school" }
            let(:expected_leaving_provider) { lead_provider }
            let(:expected_joining_provider) { lead_provider }
            let(:expected_joining_date) { end_date }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it_behaves_like "sets a complete transfer"
          end

          context "when joining SIT triggers a FIP transfer with different lead provider" do
            let(:joining_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
            let(:joining_lead_provider) { joining_cpd_lead_provider.lead_provider }
            let(:joining_partnership) { create(:partnership, lead_provider: joining_lead_provider, cohort:) }
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date:, participant_profile:)
            end
            let(:start_date) { 1.day.from_now }
            let(:expected_transfer_type) { "new_provider" }
            let(:expected_leaving_provider) { lead_provider }
            let(:expected_joining_provider) { joining_lead_provider }
            let(:expected_joining_date) { start_date }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it_behaves_like "sets a complete transfer"
          end

          context "with FIP to CIP school transfers" do
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :cip, school_cohort: joining_school_cohort) }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date:, participant_profile:)
            end
            let(:start_date) { 1.day.from_now }
            let(:expected_transfer_type) { "new_school" }
            let(:expected_leaving_provider) { lead_provider }
            let(:expected_joining_provider) { nil }
            let(:expected_joining_date) { start_date }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it_behaves_like "sets a complete transfer"
          end

          context "with CIP to FIP school transfers" do
            let(:leaving_induction_programme) { create(:induction_programme, :cip, school_cohort: leaving_school_cohort) }
            let(:joining_partnership) { create(:partnership, lead_provider:, cohort:) }
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let(:start_date) { 1.day.from_now }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date:, participant_profile:)
            end

            let(:start_date) { 1.day.from_now }
            let(:expected_transfer_type) { "new_school" }
            let(:expected_leaving_provider) { nil }
            let(:expected_joining_provider) { lead_provider }
            let(:expected_joining_date) { start_date }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it_behaves_like "sets a complete transfer"
          end

          context "when transferred ECT participant becomes mentor" do
            let(:mentor_profile) { create(:mentor_participant_profile, participant_identity: participant_profile.participant_identity, teacher_profile: participant_profile.teacher_profile) }
            let(:mentor_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
            let(:mentor_lead_provider) { mentor_cpd_lead_provider.lead_provider }
            let(:mentor_partnership) { create(:partnership, lead_provider: mentor_lead_provider, cohort:) }
            let(:mentor_school_cohort) { create(:school_cohort, cohort:) }
            let(:mentor_induction_programme) { create(:induction_programme, :fip, partnership: mentor_partnership, school_cohort: mentor_school_cohort) }
            let!(:mentor_induction_record) do
              create(:induction_record, :preferred_identity, :leaving, induction_programme: mentor_induction_programme, end_date:, participant_profile: mentor_profile)
            end
            let(:end_date) { 1.day.from_now }

            it "only surfaces a single transfer" do
              expect(subject.serializable_hash[:data][:attributes][:transfers].size).to eq(1)
              expect(transfer[:training_record_id]).to eq(participant_profile.id)
            end

            context "when mentor with same lead_provider" do
              let(:transfer) { subject.serializable_hash[:data][:attributes][:transfers].detect { |t| t[:training_record_id] == mentor_profile.id } }

              let(:mentor_partnership) { create(:partnership, lead_provider:, cohort:) }

              it "surfaces all transfers" do
                expect(subject.serializable_hash[:data][:attributes][:transfers].size).to eq(2)
              end

              let(:expected_leaving_school) { mentor_school_cohort.school }
              let(:expected_participant_profile) { mentor_profile }
              let(:expected_created_at) { mentor_induction_record.created_at }

              it_behaves_like "sets an incomplete transfer"
            end
          end

          context "with ECT and NPQ profiles" do
            let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider:) }
            let!(:npq_application) { create(:npq_application, :accepted, :eligible_for_funding, npq_lead_provider:, user:) }

            it "only surfaces a single transfer" do
              expect(subject.serializable_hash[:data][:attributes][:transfers].size).to eq(1)
            end
          end

          context "with multiple transfers" do
            let!(:leaving_induction_record) do
              create(:induction_record, :leaving, :preferred_identity, induction_programme: leaving_induction_programme, start_date: leaving_start_date, end_date: leaving_end_date)
            end
            let(:joining_partnership) { create(:partnership, lead_provider:, cohort:) }
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: joining_start_date, participant_profile:)
            end
            let(:latest_leaving_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:latest_leaving_induction_record) do
              create(:induction_record, :leaving, :preferred_identity, induction_programme: latest_leaving_induction_programme, start_date: latest_leaving_start_date, end_date: latest_leaving_end_date, participant_profile:)
            end
            let(:leaving_start_date) { 3.days.ago }
            let(:leaving_end_date) { 2.days.ago }
            let(:joining_start_date) { 1.day.ago }
            let(:latest_leaving_start_date) { Time.zone.now }
            let(:latest_leaving_end_date) { 1.day.from_now }

            it "surfaces all transfers" do
              expect(subject.serializable_hash[:data][:attributes][:transfers].size).to eq(2)
            end

            it "surfaces correct attributes" do
              transfer_1 = {
                training_record_id: participant_profile.id,
                transfer_type: "new_school",
                status: "complete",
                created_at: leaving_induction_record.created_at.rfc3339,
                leaving: {
                  school_urn: leaving_school_cohort.school.urn,
                  provider: lead_provider.name,
                  date: leaving_end_date.strftime("%Y-%m-%d"),
                },
                joining: {
                  school_urn: joining_school_cohort.school.urn,
                  provider: lead_provider.name,
                  date: joining_start_date.strftime("%Y-%m-%d"),
                },
              }
              transfer_2 = {
                training_record_id: participant_profile.id,
                transfer_type: "unknown",
                status: "incomplete",
                created_at: latest_leaving_induction_record.created_at.rfc3339,
                leaving: {
                  school_urn: joining_school_cohort.school.urn,
                  provider: lead_provider.name,
                  date: latest_leaving_end_date.strftime("%Y-%m-%d"),
                },
                joining: nil,
              }

              expect(subject.serializable_hash[:data][:attributes][:transfers]).to contain_exactly(transfer_1, transfer_2)
            end
          end

          context "with multiple transfers and lead providers" do
            let(:transfer) { subject.serializable_hash[:data][:attributes][:transfers].first }
            let!(:leaving_induction_record) do
              create(:induction_record, :leaving, :preferred_identity, induction_programme: leaving_induction_programme, start_date:, end_date:)
            end
            let(:joining_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
            let(:joining_lead_provider) { joining_cpd_lead_provider.lead_provider }
            let(:joining_partnership) { create(:partnership, lead_provider: joining_lead_provider, cohort:) }
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: joining_start_date, participant_profile:)
            end
            let(:latest_leaving_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:latest_leaving_induction_record) do
              create(:induction_record, :leaving, :preferred_identity, induction_programme: latest_leaving_induction_programme, start_date: latest_leaving_start_date, end_date: latest_leaving_end_date, participant_profile:)
            end

            let(:start_date) { 3.days.ago }
            let(:end_date) { 2.days.ago }
            let(:joining_start_date) { 1.day.ago }
            let(:latest_leaving_start_date) { Time.zone.now }
            let(:latest_leaving_end_date) { 1.day.from_now }

            it "surfaces only the lead provider transfer" do
              expect(subject.serializable_hash[:data][:attributes][:transfers].size).to eq(1)
            end

            let(:expected_transfer_type) { "new_provider" }
            let(:expected_leaving_provider) { lead_provider }
            let(:expected_joining_provider) { joining_lead_provider }
            let(:expected_joining_date) { joining_start_date }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it_behaves_like "sets a complete transfer"

            context "when other lead provider gets transfers" do
              subject { described_class.new(user, params: { cpd_lead_provider: joining_cpd_lead_provider }) }

              it "surfaces both transfers" do
                expect(subject.serializable_hash[:data][:attributes][:transfers].size).to eq(2)
              end
            end
          end

          context "with out of order induction records" do
            let(:transfer) { subject.serializable_hash[:data][:attributes][:transfers].first }
            let!(:changing_induction_record) do
              create(:induction_record, :preferred_identity, induction_status: "changed", induction_programme: leaving_induction_programme, end_date: Time.zone.now)
            end
            let(:participant_profile) { changing_induction_record.participant_profile }
            let(:joining_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
            let(:joining_lead_provider) { joining_cpd_lead_provider.lead_provider }
            let(:joining_partnership) { create(:partnership, lead_provider: joining_lead_provider, cohort:) }
            let(:joining_school_cohort) { create(:school_cohort, cohort:) }
            let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
            let!(:joining_induction_record) do
              create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: end_date, participant_profile:)
            end

            let(:leaving_induction_record) do
              travel_to(joining_induction_record.created_at + 1.day) do
                create(:induction_record, :leaving, induction_programme: leaving_induction_programme, start_date: Time.zone.now, end_date:, participant_profile:)
              end
            end
            let(:end_date) { 1.day.ago }

            let(:expected_transfer_type) { "new_provider" }
            let(:expected_leaving_provider) { lead_provider }
            let(:expected_joining_provider) { joining_lead_provider }
            let(:expected_joining_date) { end_date }
            let(:expected_created_at) { leaving_induction_record.created_at }

            it "returns the latest induction record updated_at" do
              expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(leaving_induction_record.updated_at.rfc3339)
            end

            it_behaves_like "sets a complete transfer"

            context "when other lead provider gets transfers" do
              subject { described_class.new(user, params: { cpd_lead_provider: joining_cpd_lead_provider }) }

              let(:expected_transfer_type) { "new_provider" }
              let(:expected_leaving_provider) { lead_provider }
              let(:expected_joining_provider) { joining_lead_provider }
              let(:expected_joining_date) { end_date }
              let(:expected_created_at) { leaving_induction_record.created_at }

              it_behaves_like "sets a complete transfer"
            end
          end
        end
      end
    end
  end
end
