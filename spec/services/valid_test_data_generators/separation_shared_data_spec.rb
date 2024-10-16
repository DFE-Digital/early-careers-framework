# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::SeparationSharedData do
  let(:cohort) { create(:cohort, :current) }
  let(:lead_provider) { create(:lead_provider, :with_delivery_partner, name: shared_users_data.keys.sample) }
  let(:school) { create(:school) }
  let!(:partnership) { create(:partnership, cohort:, lead_provider:) }
  let!(:school_cohort) { create(:school_cohort, school:, cohort:, induction_programme_choice: "full_induction_programme") }
  let!(:schedule_sep) { create(:ecf_schedule, schedule_identifier: "ecf-standard-september") }
  let!(:schedule_jan) { create(:ecf_schedule, schedule_identifier: "ecf-standard-january") }

  let(:shared_users_data) { YAML.load_file(Rails.root.join("db/data/separation_shared_data.yml")) }
  let(:user_params) { shared_users_data[lead_provider.name] }

  subject { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    it "creates users with provided details" do
      subject.call

      user_params.each do |params|
        participant_identity = ParticipantIdentity.find_by_email(params[:email])
        user = participant_identity.user
        teacher_profile = user.teacher_profile

        expect(user.full_name).to eq(params[:name])
        expect(teacher_profile.trn).to eq(params[:trn])

        if params[:ecf_id].present?
          expect(user.id).to eq(params[:ecf_id])
        end
      end
    end

    it "creates participant profiles" do
      expect {
        subject.call
      }.to(change(ParticipantProfile, :count))
    end

    it "creates participant profiles for the given cohort" do
      subject.call

      expect(ParticipantProfile::ECF.includes(:school_cohort).pluck("school_cohorts.cohort_id")).to all(eq(cohort.id))
    end

    it "creates participant profiles for the given lead provider" do
      expect {
        subject.call
      }.to(change(lead_provider.ecf_participant_profiles, :count))
    end
  end
end
