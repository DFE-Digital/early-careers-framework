# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    RSpec.describe NPQApplicationSerializer, :with_default_schedules do
      subject(:result) { described_class.new(npq_application).serializable_hash }

      describe "serialization" do
        let(:npq_application) { create(:npq_application, targeted_delivery_funding_eligibility: true) }

        it "returns expected data", :aggregate_failures do
          expect(result[:data][:attributes][:course_identifier]).to eql(npq_application.npq_course.identifier)
          expect(result[:data][:attributes][:email]).to eql(npq_application.participant_identity.email)
          expect(result[:data][:attributes][:email_validated]).to eql(true)
          expect(result[:data][:attributes][:employer_name]).to eql(npq_application.employer_name)
          expect(result[:data][:attributes][:employment_role]).to eql(npq_application.employment_role)
          expect(result[:data][:attributes][:full_name]).to eql(npq_application.participant_identity.user.full_name)
          expect(result[:data][:attributes][:funding_choice]).to eql(npq_application.funding_choice)
          expect(result[:data][:attributes][:headteacher_status]).to eql(npq_application.headteacher_status)
          expect(result[:data][:attributes][:ineligible_for_funding_reason]).to eql(npq_application.ineligible_for_funding_reason)
          expect(result[:data][:attributes][:participant_id]).to eql(npq_application.participant_identity.user_id)
          expect(result[:data][:attributes][:private_childcare_provider_urn]).to eql(npq_application.private_childcare_provider_urn)
          expect(result[:data][:attributes][:teacher_reference_number]).to eql(npq_application.teacher_reference_number)
          expect(result[:data][:attributes][:teacher_reference_number_validated]).to eql(npq_application.teacher_reference_number_verified)
          expect(result[:data][:attributes][:school_urn]).to eql(npq_application.school_urn)
          expect(result[:data][:attributes][:school_ukprn]).to eql(npq_application.school_ukprn)
          expect(result[:data][:attributes][:status]).to eql(npq_application.lead_provider_approval_status)
          expect(result[:data][:attributes][:works_in_school]).to eql(npq_application.works_in_school)
          expect(result[:data][:attributes][:eligible_for_funding]).to eql(npq_application.eligible_for_dfe_funding)
          expect(result[:data][:attributes][:itt_provider]).to eql(npq_application.itt_provider)
          expect(result[:data][:attributes][:lead_mentor]).to eql(npq_application.lead_mentor)
          expect(result[:data][:attributes][:targeted_delivery_funding_eligibility]).to eql(npq_application.targeted_delivery_funding_eligibility)
        end

        describe "#updated_at" do
          let(:npq_application) { create(:npq_application, targeted_delivery_funding_eligibility: true) }
          let(:profile) { npq_application.profile }
          let(:user) { npq_application.user }
          let(:participant_identity) { npq_application.participant_identity }
          let(:updated_at_attribute) { subject[:data][:attributes][:updated_at] }

          context "when npq application touched" do
            before do
              ActiveRecord::Base.no_touching do
                user.update!(updated_at: 10.days.ago)
                participant_identity.update!(updated_at: 1.day.ago)
              end
            end

            it "considers updated_at of the npq application" do
              expect(Time.zone.parse(updated_at_attribute)).to be_within(1.minute).of(Time.zone.now)
            end
          end

          context "when user touched" do
            before do
              ActiveRecord::Base.no_touching do
                participant_identity.update!(updated_at: 10.days.ago)
                npq_application.update!(updated_at: 5.days.ago)
                user.update!(updated_at: 1.day.ago)
              end
            end

            it "considers updated_at of user" do
              expect(Time.zone.parse(updated_at_attribute)).to be_within(1.minute).of(1.day.ago)
            end
          end

          context "when profile touched" do
            let(:npq_application) { create(:npq_application, :accepted) }

            before do
              ActiveRecord::Base.no_touching do
                user.update!(updated_at: 10.days.ago)
                participant_identity.update!(updated_at: 10.days.ago)
                npq_application.update!(updated_at: 5.days.ago)
                profile.update!(updated_at: 1.day.ago)
              end
            end

            it "considers updated_at of profile" do
              expect(Time.zone.parse(updated_at_attribute)).to be_within(1.minute).of(1.day.ago)
            end
          end

          context "when identity touched" do
            before do
              ActiveRecord::Base.no_touching do
                user.update!(updated_at: 10.days.ago)
                npq_application.update!(updated_at: 5.days.ago)
                participant_identity.update!(updated_at: 1.day.ago)
              end
            end

            it "considers updated_at of identity" do
              expect(Time.zone.parse(updated_at_attribute)).to be_within(1.minute).of(1.day.ago)
            end
          end
        end
      end
    end
  end
end
