# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStage::School, type: :model do
  let(:local_authority) { create(:local_authority, code: "123") }
  let(:local_authority_district) { create(:local_authority_district, code: "E12345678") }
  subject(:school) { create(:staged_school, la_code: local_authority.code, administrative_district_code: local_authority_district.code) }

  describe "#create_or_sync_counterpart!" do
    it "creates the new School" do
      expect {
        school.create_or_sync_counterpart!
      }.to change { School.count }.by(1)
    end

    it "synchronises the counterpart attributes" do
      school.create_or_sync_counterpart!
      synced_attrs = school.send(:attributes_to_sync)

      expect(school.counterpart.attributes).to include(synced_attrs)
    end

    it "associates the counterpart with the local authority" do
      school.create_or_sync_counterpart!
      expect(school.counterpart.reload.local_authority).to eq local_authority
    end

    it "associates the counterpart with the local authority district" do
      school.create_or_sync_counterpart!
      expect(school.counterpart.reload.local_authority_district).to eq local_authority_district
    end

    context "when counterpart school exists" do
      let(:current_year) { Time.zone.now.year }
      let(:cohort) { Cohort.current || create(:cohort, start_year: current_year) }
      let(:old_local_authority) { create(:local_authority, code: "234") }
      let(:old_local_authority_district) { create(:local_authority_district, :sparse, code: "E234") }
      let!(:counterpart_school) { create(:school, urn: school.urn) }
      let(:school_cohort) { create(:school_cohort, cohort:, school: counterpart_school) }
      let!(:participant) { create(:ect_participant_profile, school_cohort:, sparsity_uplift: true) }

      before do
        SchoolLocalAuthority.create!(school: counterpart_school,
                                     local_authority: old_local_authority,
                                     start_year: current_year)

        SchoolLocalAuthorityDistrict.create!(school: counterpart_school,
                                             local_authority_district: old_local_authority_district,
                                             start_year: current_year)
      end

      it "does not create an additional school" do
        expect {
          school.create_or_sync_counterpart!
        }.not_to change { School.count }
      end

      it "associates the counterpart with the new local authority" do
        school.create_or_sync_counterpart!
        expect(counterpart_school.reload.local_authority).to eq local_authority
      end

      it "associates the counterpart with the new local authority district" do
        school.create_or_sync_counterpart!
        expect(counterpart_school.reload.local_authority_district).to eq local_authority_district
      end

      it "does not update the participant profiles with the sparsity uplift of the new district" do
        school.create_or_sync_counterpart!
        expect(participant.reload).to be_sparsity_uplift
      end
    end
  end
end
