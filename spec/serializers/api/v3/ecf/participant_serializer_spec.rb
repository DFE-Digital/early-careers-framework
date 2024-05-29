# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.describe ParticipantSerializer do
        describe "serialization" do
          let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
          let(:school) { create(:school) }
          let(:cohort) { create(:cohort, :current) }
          let(:delivery_partner) { create(:delivery_partner) }
          let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, delivery_partner:, school:, cohort:, lead_provider: cpd_lead_provider.lead_provider) }
          let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider: cpd_lead_provider.lead_provider) }
          let(:participant) { create(:user) }
          let!(:ect_profile) { create(:ect, :eligible_for_funding, school_cohort:, user: participant, induction_completion_date: Date.parse("2022-01-12"), cohort_changed_after_payments_frozen: true) }
          let(:previous_cohort) { Cohort.previous.tap { |c| c.update!(payments_frozen_at: Time.zone.now) } }
          let!(:previous_cohort_declaration) { create(:participant_declaration, participant_profile: ect_profile, cohort: previous_cohort, state: :paid, cpd_lead_provider:, course_identifier: "ecf-induction") }

          before { freeze_time }

          subject { described_class.new([participant], params: { cpd_lead_provider: }) }

          let(:result) { subject.serializable_hash }

          it "returns the expected data" do
            expect(result[:data]).to match_array([
              id: participant.id,
              type: :participant,
              attributes: {
                full_name: participant.full_name,
                teacher_reference_number: participant.teacher_profile.trn,
                updated_at: [
                  ect_profile.updated_at,
                  participant.updated_at,
                  participant.participant_identities.map(&:updated_at),
                  ect_profile.induction_records.map(&:updated_at),
                ].flatten.compact.max.rfc3339,
                ecf_enrolments:
                  [
                    {
                      training_record_id: ect_profile.id,
                      email: participant.email,
                      mentor_id: nil,
                      school_urn: school.urn,
                      participant_type: :ect,
                      cohort: school_cohort.cohort.start_year&.to_s,
                      training_status: "active",
                      participant_status: "active",
                      teacher_reference_number_validated: true,
                      eligible_for_funding: true,
                      pupil_premium_uplift: ect_profile.pupil_premium_uplift,
                      sparsity_uplift: ect_profile.sparsity_uplift,
                      schedule_identifier: ect_profile.schedule&.schedule_identifier,
                      delivery_partner_id: delivery_partner.id,
                      withdrawal: nil,
                      deferral: nil,
                      created_at: ect_profile.created_at.rfc3339,
                      induction_end_date: "2022-01-12",
                      mentor_funding_end_date: nil,
                      previous_payments_frozen_cohort: previous_cohort.start_year,
                    },
                  ],
                participant_id_changes: [],
              },
            ])
          end

          describe "ecf_enrolments" do
            context "when there are multiple providers involved" do
              let(:another_school_cohort) { create(:school_cohort, :fip, :with_induction_programme) }
              let!(:mentor_profile) { create(:mentor, school_cohort: another_school_cohort, user: participant) }

              it "only includes enrolments from the querying provider" do
                expect(result[:data][0][:attributes][:ecf_enrolments].size).to be(1)
              end
            end

            context "when there are multiple profiles involved" do
              let!(:mentor_profile) { create(:mentor, school_cohort:, user: participant) }

              before do
                mentor_profile.update!(mentor_completion_date: Date.new(2021, 4, 19))
              end

              it "includes the second profile data" do
                expect(result[:data][0][:attributes][:ecf_enrolments].find { |efce| efce[:participant_type] == :mentor }).to eq({
                  training_record_id: mentor_profile.id,
                  email: participant.email,
                  mentor_id: nil,
                  school_urn: school.urn,
                  participant_type: :mentor,
                  cohort: school_cohort.cohort.start_year&.to_s,
                  training_status: "active",
                  participant_status: "active",
                  teacher_reference_number_validated: false,
                  eligible_for_funding: nil,
                  pupil_premium_uplift: mentor_profile.pupil_premium_uplift,
                  sparsity_uplift: mentor_profile.sparsity_uplift,
                  schedule_identifier: mentor_profile.schedule&.schedule_identifier,
                  delivery_partner_id: delivery_partner.id,
                  withdrawal: nil,
                  deferral: nil,
                  created_at: mentor_profile.created_at.rfc3339,
                  induction_end_date: nil,
                  mentor_funding_end_date: "2021-04-19",
                  previous_payments_frozen_cohort: nil,
                })
              end
            end

            context "when the profile is withdrawn" do
              before do
                ect_profile.induction_records.latest.update!(training_status: "withdrawn")
                ect_profile.participant_profile_states.last.update!(state: "withdrawn", reason: "other")
              end

              it "includes a withdrawal object" do
                expect(result[:data][0][:attributes][:ecf_enrolments][0][:withdrawal][:reason]).to eq("other")
                expect(result[:data][0][:attributes][:ecf_enrolments][0][:withdrawal][:date]).to eql(ect_profile.participant_profile_state.created_at.rfc3339)
              end
            end

            context "when the profile is deferred" do
              before do
                ect_profile.induction_records.latest.update!(training_status: "deferred")
                ect_profile.participant_profile_states.last.update!(state: "deferred", reason: "other")
              end

              it "includes a deferral object" do
                expect(result[:data][0][:attributes][:ecf_enrolments][0][:deferral][:reason]).to eq("other")
                expect(result[:data][0][:attributes][:ecf_enrolments][0][:deferral][:date]).to eql(ect_profile.participant_profile_state.created_at.rfc3339)
              end
            end

            context "when the user is built by a query" do
              let(:latest_induction_record) { ect_profile.induction_records.latest }
              let(:participant_from_query) { OpenStruct.new(results) }
              let(:results) do
                {
                  latest_induction_records: [latest_induction_record.id],
                  participant_profiles: [ect_profile],
                  participant_identities: participant.participant_identities,
                }.merge(participant.attributes)
              end
              subject { described_class.new([participant_from_query], params: { cpd_lead_provider: }) }

              it "selects the latest induction record correctly" do
                expect(result[:data][0][:attributes][:ecf_enrolments][0][:email]).to eq(latest_induction_record.preferred_identity.email)
              end
            end
          end

          describe "participant_id_changes" do
            context "when there are no participant_id_changes" do
              it "should returne empty array" do
                expect(result[:data][0][:attributes][:participant_id_changes]).to eql([])
              end
            end

            context "when there is one participant_id_changes" do
              let!(:participant_id_change) { create(:participant_id_change, user: participant, to_participant: participant) }

              it "should returns participant id change" do
                expect(result[:data][0][:attributes][:participant_id_changes]).to eql([
                  {
                    from_participant_id: participant_id_change.from_participant_id,
                    to_participant_id: participant_id_change.to_participant_id,
                    changed_at: participant_id_change.created_at.rfc3339,
                  },
                ])
              end
            end

            context "when there are multiple participant_id_changes" do
              let!(:participant_id_change1) { create(:participant_id_change, user: participant, to_participant: participant) }
              let!(:participant_id_change2) { create(:participant_id_change, user: participant, to_participant: participant) }

              it "should returns participant id changes" do
                expect(result[:data][0][:attributes][:participant_id_changes]).to match_array([
                  {
                    from_participant_id: participant_id_change2.from_participant_id,
                    to_participant_id: participant_id_change2.to_participant_id,
                    changed_at: participant_id_change2.created_at.rfc3339,
                  },
                  {
                    from_participant_id: participant_id_change1.from_participant_id,
                    to_participant_id: participant_id_change1.to_participant_id,
                    changed_at: participant_id_change1.created_at.rfc3339,
                  },
                ])
              end
            end
          end
        end
      end
    end
  end
end
