# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ParticipantFromQuerySerializer, :with_default_schedules do
      let(:query_result) { OpenStruct.new(results) }
      let(:results) do
        {
          participant_profile_updated_at: Time.zone.now,
          user_updated_at: Time.zone.now,
          participant_identity_updated_at: Time.zone.now,
          updated_at: Time.zone.now,
        }.merge(fields)
      end

      subject { described_class.new(query_result) }

      describe "#id" do
        let(:user_id) { Faker::Internet.uuid }
        let(:fields) { { user_id: } }

        it "returns the user id" do
          expect(subject.serializable_hash[:data][:id]).to eql(user_id)
        end
      end

      describe "#email" do
        context "when user email present" do
          let(:fields) do
            {
              preferred_identity_email: nil,
              user_email: "firsts_email@example.com",
            }
          end

          it "returns user email" do
            expect(subject.serializable_hash[:data][:attributes][:email]).to eql("firsts_email@example.com")
          end
        end

        context "when preferred identity email present" do
          let(:fields) do
            {
              preferred_identity_email: "preferred_email@example.com",
              user_email: "firsts_email@example.com",
            }
          end

          it "returns preferred identity email" do
            expect(subject.serializable_hash[:data][:attributes][:email]).to eql("preferred_email@example.com")
          end
        end
      end

      describe "#full_name" do
        let(:full_name) { "John Doe" }
        let(:fields) { { full_name: } }

        it "returns the full name" do
          expect(subject.serializable_hash[:data][:attributes][:full_name]).to eql(full_name)
        end
      end

      describe "#mentor_id" do
        let(:user_id) { Faker::Internet.uuid }

        context "when participant is an ECT" do
          let(:fields) do
            {
              mentor_user_id: user_id,
              participant_profile_type: "ParticipantProfile::ECT",
            }
          end

          it "returns the mentor user id" do
            expect(subject.serializable_hash[:data][:attributes][:mentor_id]).to eql(user_id)
          end
        end

        context "when participant is a Mentor" do
          let(:fields) do
            {
              mentor_user_id: user_id,
              participant_profile_type: "ParticipantProfile::Mentor",
            }
          end

          it "returns nil" do
            expect(subject.serializable_hash[:data][:attributes][:mentor_id]).to be_nil
          end
        end
      end

      describe "#school_urn" do
        let(:school_urn) { 123_456 }
        let(:fields) { { schools_urn: school_urn } }

        it "returns the school urn" do
          expect(subject.serializable_hash[:data][:attributes][:school_urn]).to eql(school_urn)
        end
      end

      describe "#participant_type" do
        context "when participant is an ECT" do
          let(:fields) do
            {
              participant_profile_type: "ParticipantProfile::ECT",
            }
          end

          it "returns the participant type as an ect" do
            expect(subject.serializable_hash[:data][:attributes][:participant_type]).to eql(:ect)
          end
        end

        context "when participant is a Mentor" do
          let(:fields) do
            {
              participant_profile_type: "ParticipantProfile::Mentor",
            }
          end

          it "returns the participant type as a mentor" do
            expect(subject.serializable_hash[:data][:attributes][:participant_type]).to eql(:mentor)
          end
        end
      end

      describe "#cohort" do
        let(:start_year) { 2021 }
        let(:fields) { { start_year: } }

        it "returns the cohort" do
          expect(subject.serializable_hash[:data][:attributes][:cohort]).to eql("2021")
        end
      end

      describe "#status" do
        context "when active" do
          let(:fields) do
            {
              induction_status: "active",
            }
          end

          it "returns active" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
          end
        end

        context "when the status has changed" do
          context "when completed" do
            let(:fields) do
              {
                induction_status: "completed",
              }
            end

            it "returns active" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
            end
          end

          context "when leaving" do
            let(:induction_record) { ect.reload.current_induction_record }
            let(:fields) do
              {
                induction_status: "leaving",
              }
            end

            it "returns active" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
            end
          end

          context "when withdrawn" do
            let(:fields) do
              {
                induction_status: "withdrawn",
              }
            end

            it "returns withdrawn" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("withdrawn")
            end
          end

          context "when changed" do
            let(:fields) do
              {
                induction_status: "changed",
              }
            end

            it "returns withdrawn" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("withdrawn")
            end
          end
        end
      end

      describe "#teacher_reference_number" do
        let(:fields) do
          {
            teacher_profile_trn:,
            ecf_participant_validation_data_trn: 654_321,
          }
        end
        context "when no teacher profile trn present" do
          let(:teacher_profile_trn) { nil }

          it "returns the validation data trn" do
            expect(subject.serializable_hash[:data][:attributes][:teacher_reference_number]).to eql(654_321)
          end
        end

        context "when teacher profile trn present" do
          let(:teacher_profile_trn) { 123_456 }

          it "returns the teacher profile trn" do
            expect(subject.serializable_hash[:data][:attributes][:teacher_reference_number]).to eql(teacher_profile_trn)
          end
        end
      end

      describe "#teacher_reference_number_validated" do
        let(:fields) do
          {
            teacher_profile_trn:,
            ecf_participant_validation_data_trn:,
            ecf_participant_eligibility_reason:,
          }
        end

        context "when no trn present" do
          let(:teacher_profile_trn) { nil }
          let(:ecf_participant_validation_data_trn) { nil }
          let(:ecf_participant_eligibility_reason) { nil }

          it "returns nil" do
            expect(subject.serializable_hash[:data][:attributes][:teacher_reference_number_validated]).to be_nil
          end
        end

        context "when a trn is present but there is no participant eligibility reason" do
          let(:teacher_profile_trn) { 123_456 }
          let(:ecf_participant_validation_data_trn) { 654_321 }
          let(:ecf_participant_eligibility_reason) { nil }

          it "returns false" do
            expect(subject.serializable_hash[:data][:attributes][:teacher_reference_number_validated]).to be false
          end
        end

        context "when a trn is present and the participant eligibility reason is not 'different_trn'" do
          let(:teacher_profile_trn) { 123_456 }
          let(:ecf_participant_validation_data_trn) { 654_321 }
          let(:ecf_participant_eligibility_reason) { "active_flags" }

          it "returns true" do
            expect(subject.serializable_hash[:data][:attributes][:teacher_reference_number_validated]).to be true
          end
        end

        context "when a trn is present and the participant eligibility reason is 'different_trn'" do
          let(:teacher_profile_trn) { 123_456 }
          let(:ecf_participant_validation_data_trn) { 654_321 }
          let(:ecf_participant_eligibility_reason) { "different_trn" }

          it "returns false" do
            expect(subject.serializable_hash[:data][:attributes][:teacher_reference_number_validated]).to be false
          end
        end
      end

      describe "#eligible_for_funding" do
        let(:fields) { { ecf_participant_eligibility_status: } }

        context "when status is empty" do
          let(:ecf_participant_eligibility_status) { nil }

          it "returns nil" do
            expect(subject.serializable_hash[:data][:attributes][:eligible_for_funding]).to be_nil
          end
        end

        context "when status is eligible" do
          let(:ecf_participant_eligibility_status) { "eligible" }

          it "returns true" do
            expect(subject.serializable_hash[:data][:attributes][:eligible_for_funding]).to be true
          end
        end

        context "when status is ineligible" do
          let(:ecf_participant_eligibility_status) { "ineligible" }

          it "returns false" do
            expect(subject.serializable_hash[:data][:attributes][:eligible_for_funding]).to be false
          end
        end
      end

      describe "#pupil_premium_uplift" do
        let(:fields) { { pupil_premium_uplift: true } }

        it "returns the pupil_premium_uplift" do
          expect(subject.serializable_hash[:data][:attributes][:pupil_premium_uplift]).to be true
        end
      end

      describe "#pupil_premium_uplift" do
        let(:fields) { { pupil_premium_uplift: true } }

        it "returns the pupil_premium_uplift" do
          expect(subject.serializable_hash[:data][:attributes][:pupil_premium_uplift]).to be true
        end
      end

      describe "#sparsity_uplift" do
        let(:fields) { { sparsity_uplift: false } }

        it "returns the sparsity_uplift" do
          expect(subject.serializable_hash[:data][:attributes][:sparsity_uplift]).to be false
        end
      end

      describe "#training_status" do
        let(:fields) { { training_status: "active" } }

        it "returns the training_status" do
          expect(subject.serializable_hash[:data][:attributes][:training_status]).to eql("active")
        end
      end

      describe "#schedule_identifier" do
        let(:fields) { { schedule_identifier: "ecf-standard-september" } }

        it "returns the schedule_identifier" do
          expect(subject.serializable_hash[:data][:attributes][:schedule_identifier]).to eql("ecf-standard-september")
        end
      end

      describe "#updated_at" do
        let(:fields) do
          {
            participant_profile_updated_at:,
            user_updated_at:,
            participant_identity_updated_at:,
            updated_at:,
          }
        end

        context "when induction record touched" do
          let(:participant_profile_updated_at) { Time.zone.now - 3.days }
          let(:user_updated_at) { Time.zone.now - 2.days }
          let(:participant_identity_updated_at) { Time.zone.now - 1.day }
          let(:updated_at) { Time.zone.now }

          it "considers updated_at of induction record" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to eq(updated_at.rfc3339)
          end
        end

        context "when user touched" do
          let(:participant_profile_updated_at) { Time.zone.now - 3.days }
          let(:user_updated_at) { Time.zone.now }
          let(:participant_identity_updated_at) { Time.zone.now - 1.day }
          let(:updated_at) { Time.zone.now - 2.days }

          it "considers updated_at of user" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to eq(user_updated_at.rfc3339)
          end
        end

        context "when profile touched" do
          let(:participant_profile_updated_at) { Time.zone.now }
          let(:user_updated_at) { Time.zone.now - 3.days }
          let(:participant_identity_updated_at) { Time.zone.now - 1.day }
          let(:updated_at) { Time.zone.now - 2.days }

          it "considers updated_at of profile" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to eq(participant_profile_updated_at.rfc3339)
          end
        end

        context "when identity touched" do
          let(:participant_profile_updated_at) { Time.zone.now - 1.day }
          let(:user_updated_at) { Time.zone.now - 3.days }
          let(:participant_identity_updated_at) { Time.zone.now }
          let(:updated_at) { Time.zone.now - 2.days }

          it "considers updated_at of identity" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to eq(participant_identity_updated_at.rfc3339)
          end
        end
      end
    end
  end
end
