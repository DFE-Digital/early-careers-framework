# frozen_string_literal: true

describe Oneoffs::Migration::ReconcileUsers do
  let(:instance) { described_class.new }

  describe "#matches" do
    subject { instance.matches }

    context "when there are no users" do
      it { is_expected.to be_empty }
    end

    context "when there are ECF users without an application that do not match an NPQ user" do
      let!(:ecf_user) { create(:user) }
      let!(:npq_user) { create(:npq_reg_user) }

      it { is_expected.not_to include(an_object_having_attributes(matches: [ecf_user])) }
      it { is_expected.to include(an_object_having_attributes(matches: [npq_user])) }
    end

    context "when there are ECF users without an application that match an NPQ user" do
      let!(:ecf_user) { create(:user) }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_user, ecf_user))) }
    end

    context "when there are ECF users with an application and NPQ users that do not match" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user) }

      it { is_expected.to include(an_object_having_attributes(matches: [ecf_user])) }
      it { is_expected.to include(an_object_having_attributes(matches: [npq_user])) }
    end

    context "when there are ECF and NPQ users that match on ecf_id" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_user, ecf_user))) }
    end

    context "when there are ECF and NPQ users that match on get_an_identity_id" do
      let(:get_an_identity_id) { SecureRandom.uuid }
      let!(:ecf_user) do
        create(:npq_application).user.tap do |user|
          user.update!(get_an_identity_id:)
        end
      end
      let!(:npq_user) { create(:npq_reg_user, get_an_identity_id:) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_user, ecf_user))) }
    end

    context "when there are ECF and NPQ users that match on trn" do
      let!(:ecf_user) do
        create(:user, :teacher).tap do |user|
          create(:npq_application, user:)
        end
      end
      let!(:npq_user) { create(:npq_reg_user, trn: ecf_user.teacher_profile.trn) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_user, ecf_user))) }
    end

    context "when there are ECF and NPQ users that match on email" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, email: ecf_user.email) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_user, ecf_user))) }
    end
  end

  describe "#orphaned" do
    subject { instance.orphaned }

    context "when there are no orphaned matches" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to be_empty }
    end

    context "when there are orphaned matches" do
      let!(:ecf_user) { create(:npq_application).user }

      it { is_expected.to include(an_object_having_attributes(matches: [ecf_user])) }
    end
  end

  describe "#duplicated" do
    subject { instance.duplicated }

    context "when there are no duplicated matches" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to be_empty }
    end

    context "when there are duplicated matches" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }
      let!(:duplicate_npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(ecf_user, npq_user, duplicate_npq_user))) }
    end
  end

  describe "#matched" do
    subject { instance.matched }

    context "when there are matches" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(ecf_user, npq_user))) }
    end

    context "when there are duplicates" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }
      let!(:duplicate_npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }

      it { is_expected.to be_empty }
    end

    context "when there are orphans" do
      let!(:ecf_user) { create(:npq_application).user }

      it { is_expected.to be_empty }
    end
  end

  describe "#orphaned_ecf" do
    subject { instance.orphaned_ecf }

    context "when there are orphaned ECF and NPQ users" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(ecf_user))) }
      it { is_expected.not_to include(an_object_having_attributes(matches: array_including(npq_user))) }
    end
  end

  describe "#orphaned_npq" do
    subject { instance.orphaned_npq }

    context "when there are orphaned ECF and NPQ users" do
      let!(:ecf_user) { create(:npq_application).user }
      let!(:npq_user) { create(:npq_reg_user) }

      it { is_expected.not_to include(an_object_having_attributes(matches: array_including(ecf_user))) }
      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_user))) }
    end
  end
end
