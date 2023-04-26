# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionRecordPolicy, type: :policy do
  subject { described_class.new(user, induction_record) }

  let(:user) { scenario.user }
  let(:induction_record) { create(:induction_record) }

  context "being a super user admin" do
    let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build.with_super_user }

    it { is_expected.to permit_actions(%i[edit_preferred_email update_preferred_email]) }
  end

  context "not being a super user admin" do
    let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build }

    it { is_expected.to forbid_actions(%i[edit_preferred_email update_preferred_email]) }
  end
end
