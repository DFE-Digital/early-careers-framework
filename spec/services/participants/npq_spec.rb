# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::NPQ, :with_default_schedules do
  let(:user) { profile_one.user }
  let(:teacher_profile) { profile_one.teacher_profile }

  let!(:profile_one) { create(:npq_participant_profile) }
  let!(:profile_two) { create(:npq_participant_profile, user:, teacher_profile:) }

  let(:klass) do
    Class.new do
      include Participants::NPQ

      attr_reader :cpd_lead_provider, :course_identifier

      def initialize(cpd_lead_provider:, course_identifier:)
        @cpd_lead_provider = cpd_lead_provider
        @course_identifier = course_identifier
      end

      def participant_identity
        ParticipantIdentity.first
      end
    end
  end

  describe "#user_profile" do
    context "when there are 2 active profiles with different lead providers" do
      it "returns profile relevant to the provider" do
        cpd_lead_provider = profile_one.npq_application.npq_lead_provider.cpd_lead_provider
        course_identifier = profile_one.npq_application.npq_course.identifier

        instance = klass.new(cpd_lead_provider:, course_identifier:)
        expect(instance.user_profile).to eql(profile_one)

        cpd_lead_provider = profile_two.npq_application.npq_lead_provider.cpd_lead_provider
        course_identifier = profile_two.npq_application.npq_course.identifier

        instance = klass.new(cpd_lead_provider:, course_identifier:)
        expect(instance.user_profile).to eql(profile_two)
      end
    end
  end
end
