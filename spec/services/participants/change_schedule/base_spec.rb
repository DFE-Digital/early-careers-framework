# frozen_string_literal: true

RSpec.describe Participants::ChangeSchedule::Base do
  let(:klass) do
    Class.new(described_class) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def self.valid_courses
        %w[some-course]
      end

      def user_profile
        ParticipantProfile::ECT.new
      end

      def matches_lead_provider?
        true
      end

      def call
        valid?
      end
    end
  end

  describe "validations" do
    context "when null schedule_identifier given" do
      subject do
        klass.new(params: {
          schedule_identifier: nil,
          participant_id: SecureRandom.uuid,
          course_identifier: "some-course",
          cpd_lead_provider: CpdLeadProvider.new,
        })
      end

      before do
        create(:schedule, name: "Schedule with no alias")
      end

      it "should have an error" do
        subject.call

        expect(subject.errors[:schedule]).to be_present
      end
    end
  end
end
