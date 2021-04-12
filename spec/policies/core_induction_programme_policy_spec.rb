# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoreInductionProgrammePolicy, type: :policy do
  subject { described_class.new(user, core_induction_programme) }
  let(:core_induction_programme) { create(:core_induction_programme) }

  context "accessing cip views as admin" do
    let(:user) { create(:user, :admin) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
  end

  context "accessing cip views as an early career teacher" do
    let(:user) { create(:user, :early_career_teacher, { core_induction_programme: core_induction_programme }) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
  end

  context "being a visitor" do
    let(:user) { nil }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
  end
end
