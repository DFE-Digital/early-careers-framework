# frozen_string_literal: true

describe Oneoffs::Migration::ReconcileApplications do
  let(:instance) { described_class.new }

  describe "#matches" do
    subject { instance.matches }

    context "when there are no applications" do
      it { is_expected.to be_empty }
    end

    context "when there are ECF and NPQ applications that do not match" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application) }

      it { is_expected.to include(an_object_having_attributes(matches: [ecf_application])) }
      it { is_expected.to include(an_object_having_attributes(matches: [npq_application])) }
    end

    context "when there are ECF and NPQ applications that match on ecf_id" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(npq_application, ecf_application))) }
    end
  end

  describe "#orphaned" do
    subject { instance.orphaned }

    context "when there are no orphaned matches" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }

      it { is_expected.to be_empty }
    end

    context "when there are orphaned matches" do
      let!(:ecf_application) { create(:npq_application) }

      it { is_expected.to include(an_object_having_attributes(matches: [ecf_application])) }
    end
  end

  describe "#duplicated" do
    subject { instance.duplicated }

    context "when there are no duplicated matches" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }

      it { is_expected.to be_empty }
    end

    context "when there are duplicated matches" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }
      let!(:duplicate_npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(ecf_application, npq_application, duplicate_npq_application))) }
    end
  end

  describe "#matched" do
    subject { instance.matched }

    context "when there are matches" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }

      it { is_expected.to include(an_object_having_attributes(matches: array_including(ecf_application, npq_application))) }
    end

    context "when there are duplicates" do
      let!(:ecf_application) { create(:npq_application) }
      let!(:npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }
      let!(:duplicate_npq_application) { create(:npq_reg_application, ecf_id: ecf_application.id) }

      it { is_expected.to be_empty }
    end

    context "when there are orphans" do
      let!(:ecf_application) { create(:npq_application) }

      it { is_expected.to be_empty }
    end
  end

  context "#orphaned_matches" do
    subject { instance.orphaned_matches }

    context "when an NPQ/ECF application share a course name and user" do
      let!(:ecf_user) { create(:user) }
      let!(:ecf_course) { create(:npq_course, name: "course-a") }
      let!(:ecf_application) { create(:npq_application, user: ecf_user, npq_course: ecf_course) }

      let!(:npq_user) { create(:npq_reg_user, ecf_id: ecf_user.id) }
      let!(:npq_course) { create(:npq_reg_course, name: "COURSE-A") }
      let!(:npq_application) { create(:npq_reg_application, user: npq_user, course: npq_course) }

      it { is_expected.to include(an_object_having_attributes(orphan: ecf_application, potential_matches: array_including(npq_application))) }
      it { is_expected.to include(an_object_having_attributes(orphan: npq_application, potential_matches: array_including(ecf_application))) }
    end
  end
end
