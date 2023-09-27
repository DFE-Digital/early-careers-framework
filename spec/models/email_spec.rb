# frozen_string_literal: true

require "rails_helper"

RSpec.describe Email, type: :model do
  subject(:email) { described_class.create! }

  describe "associations" do
    it { is_expected.to have_many(:associations) }
  end

  describe "status fields" do
    context "when status is submitted" do
      subject(:email) { described_class.create!(status: "submitted") }

      it { is_expected.to be_submitted }
      it { is_expected.not_to be_delivered }
      it { is_expected.not_to be_failed }
    end

    context "when status is delivered" do
      subject(:email) { described_class.create!(status: "delivered") }

      it { is_expected.to be_delivered }
      it { is_expected.not_to be_submitted }
      it { is_expected.not_to be_failed }
    end

    Email::FAILED_STATUSES.each do |status|
      context "when status is #{status}" do
        subject(:email) { described_class.create!(status:) }

        it { is_expected.to be_failed }
        it { is_expected.not_to be_submitted }
        it { is_expected.not_to be_delivered }
      end
    end
  end

  describe "#create_association_with" do
    let(:school) { create(:seed_school, urn: "123123", name: "Imaginary High School") }

    it "adds an Association record" do
      expect {
        email.create_association_with(school, as: :school)
      }.to change { Email::Association.count }.by(1)
    end

    context "when the object is nil" do
      let(:school) { nil }

      it "does not raise an error" do
        expect {
          email.create_association_with(school)
        }.not_to raise_error
      end

      it "does not create an Association record" do
        expect {
          email.create_association_with(school)
        }.not_to change { Email::Association.count }
      end
    end
  end
end
