# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.describe UnfundedMentorSerializer, :with_default_schedules do
        let(:query_result) { OpenStruct.new(results) }
        let(:results) do
          {
            participant_profile_created_at: Time.zone.now,
            user_created_at: Time.zone.now,
            participant_identity_created_at: Time.zone.now,
            created_at: Time.zone.now,
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

        describe "#type" do
          let(:fields) { {} }

          it "returns the correct type" do
            expect(subject.serializable_hash[:data][:type]).to eq(:'unfunded-mentor')
          end
        end

        describe "#full_name" do
          let(:full_name) { "John Doe" }
          let(:fields) { { full_name: } }

          it "returns the full name" do
            expect(subject.serializable_hash[:data][:attributes][:full_name]).to eql(full_name)
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

        describe "#created_at" do
          let(:fields) do
            {
              participant_profile_created_at:,
              user_created_at:,
              participant_identity_created_at:,
              created_at:,
            }
          end

          context "when induction record touched" do
            let(:participant_profile_created_at) { Time.zone.now - 3.days }
            let(:user_created_at) { Time.zone.now - 2.days }
            let(:participant_identity_created_at) { Time.zone.now - 1.day }
            let(:created_at) { Time.zone.now }

            it "considers created_at of induction record" do
              expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:created_at])).to eq(created_at.rfc3339)
            end
          end

          context "when user touched" do
            let(:participant_profile_created_at) { Time.zone.now - 3.days }
            let(:user_created_at) { Time.zone.now }
            let(:participant_identity_created_at) { Time.zone.now - 1.day }
            let(:created_at) { Time.zone.now - 2.days }

            it "considers created_at of user" do
              expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:created_at])).to eq(user_created_at.rfc3339)
            end
          end

          context "when profile touched" do
            let(:participant_profile_created_at) { Time.zone.now }
            let(:user_created_at) { Time.zone.now - 3.days }
            let(:participant_identity_created_at) { Time.zone.now - 1.day }
            let(:created_at) { Time.zone.now - 2.days }

            it "considers created_at of profile" do
              expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:created_at])).to eq(participant_profile_created_at.rfc3339)
            end
          end

          context "when identity touched" do
            let(:participant_profile_created_at) { Time.zone.now - 1.day }
            let(:user_created_at) { Time.zone.now - 3.days }
            let(:participant_identity_created_at) { Time.zone.now }
            let(:created_at) { Time.zone.now - 2.days }

            it "considers created_at of identity" do
              expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:created_at])).to eq(participant_identity_created_at.rfc3339)
            end
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
end
