# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseValidator do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      validates :course_identifier, course: true

      attr_reader :participant_identity, :course_identifier

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def initialize(participant_identity:, course_identifier:)
        @participant_identity = participant_identity
        @course_identifier = course_identifier
      end
    end
  end

  describe "#validate" do
    context "ECF user" do
      let(:declaration) { create(:ect_participant_declaration) }
      let(:profile) { declaration.participant_profile }
      let(:user) { profile.user }
      let(:participant_identity) { profile.participant_identity }
      let(:course_identifier) { declaration.course_identifier }

      subject { klass.new(participant_identity:, course_identifier:) }

      context "with one identity" do
        it { is_expected.to be_valid }

        context "when the profile status is not active" do
          before { profile.withdrawn_record! }

          it { is_expected.to be_invalid }
        end
      end

      context "with multiple identities" do
        let(:second_email) { "#{rand(99_999)}@example.com" }
        let(:second_external_identifier) { SecureRandom.uuid }

        let(:participant_identity) do
          create(
            :participant_identity,
            user:,
            email: second_email,
            external_identifier: second_external_identifier,
          )
        end

        it { is_expected.to be_valid }
      end

      context "with different course_identifier" do
        let(:course_identifier) { "incorrect-course-identifier" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
