# frozen_string_literal: true

require "rails_helper"

RSpec.describe Migrators::CacheUpliftFlags do
  let(:ect_profile) { create(:ect_participant_profile, pupil_premium_uplift: true, sparsity_uplift: false) }
  let(:mentor_profile) { create(:mentor_participant_profile, pupil_premium_uplift: false, sparsity_uplift: true) }
  let(:npq_profile) { create(:npq_participant_profile) }

  let!(:ect_declaration) { create(:ect_participant_declaration, participant_profile: ect_profile) }
  let!(:mentor_declaration) { create(:mentor_participant_declaration, participant_profile: mentor_profile) }
  let!(:npq_declaration) { create(:npq_participant_declaration, participant_profile: npq_profile) }

  describe "#call" do
    it "caches uplift flags" do
      expect {
        subject.call
        ect_declaration.reload
        mentor_declaration.reload
        npq_declaration.reload
      }.to change { ect_declaration.reload.pupil_premium_uplift }.from(nil).to(true)
       .and change { ect_declaration.reload.sparsity_uplift }.from(nil).to(false)
       .and change { mentor_declaration.reload.pupil_premium_uplift }.from(nil).to(false)
       .and change { mentor_declaration.reload.sparsity_uplift }.from(nil).to(true)
       .and change { npq_declaration.reload.pupil_premium_uplift }.from(nil).to(false)
       .and change { npq_declaration.reload.sparsity_uplift }.from(nil).to(false)
    end
  end
end
