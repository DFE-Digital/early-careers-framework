# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityPresenter, type: :model do
  let(:eligibility) { create(:ecf_participant_eligibility) }
  subject(:presenter) { described_class.new(eligibility) }

  describe "#eligibility" do
    it "returns a friendlier status text" do
      ECFParticipantEligibility.statuses.each_key do |status|
        eligibility.status = status
        expect(presenter.eligibility).to eq status.humanize.capitalize
      end
    end
  end

  describe "#reason" do
    it "returns a friendlier reason text" do
      ECFParticipantEligibility.reasons.each_key do |reason|
        eligibility.reason = reason
        expect(presenter.reason).to eq reason.humanize.capitalize
      end
    end
  end

  describe "#active_flags" do
    context "when true" do
      it "returns Yes" do
        eligibility.active_flags = true
        expect(presenter.active_flags).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        eligibility.active_flags = false
        expect(presenter.active_flags).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        eligibility.active_flags = nil
        expect(presenter.active_flags).to eq "No"
      end
    end
  end

  describe "#previous_induction" do
    context "when true" do
      it "returns Yes" do
        eligibility.previous_induction = true
        expect(presenter.previous_induction).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        eligibility.previous_induction = false
        expect(presenter.previous_induction).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        eligibility.previous_induction = nil
        expect(presenter.previous_induction).to eq "No"
      end
    end
  end
  describe "#qts" do
    context "when true" do
      it "returns Yes" do
        eligibility.qts = true
        expect(presenter.qts).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        eligibility.qts = false
        expect(presenter.qts).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        eligibility.qts = nil
        expect(presenter.qts).to eq "No"
      end
    end
  end
  describe "#different_trn" do
    context "when true" do
      it "returns Yes" do
        eligibility.different_trn = true
        expect(presenter.different_trn).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        eligibility.different_trn = false
        expect(presenter.different_trn).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        eligibility.different_trn = nil
        expect(presenter.different_trn).to eq "No"
      end
    end
  end
  describe "#registered_induction" do
    context "when no_induction is true" do
      it "returns No" do
        eligibility.no_induction = true
        expect(presenter.registered_induction).to eq "No"
      end
    end
    context "when no_induction is false" do
      it "returns Yes" do
        eligibility.no_induction = false
        expect(presenter.registered_induction).to eq "Yes"
      end
    end
    context "when no_induction is blank" do
      it "returns Yes" do
        eligibility.no_induction = nil
        expect(presenter.registered_induction).to eq "Yes"
      end
    end
  end
  describe "#exempt_from_induction" do
    context "when true" do
      it "returns Yes" do
        eligibility.exempt_from_induction = true
        expect(presenter.exempt_from_induction).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        eligibility.exempt_from_induction = false
        expect(presenter.exempt_from_induction).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        eligibility.exempt_from_induction = nil
        expect(presenter.exempt_from_induction).to eq "No"
      end
    end
  end
  describe "#duplicate_profile" do
    context "when true" do
      it "returns Yes" do
        allow(eligibility).to receive(:duplicate_profile?).and_return(true)
        expect(presenter.duplicate_profile).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        allow(eligibility).to receive(:duplicate_profile?).and_return(false)
        expect(presenter.duplicate_profile).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        allow(eligibility).to receive(:duplicate_profile?).and_return(nil)
        expect(presenter.duplicate_profile).to eq "No"
      end
    end
  end
  describe "#previous_participation" do
    context "when true" do
      it "returns Yes" do
        eligibility.previous_participation = true
        expect(presenter.previous_participation).to eq "Yes"
      end
    end
    context "when false" do
      it "returns No" do
        eligibility.previous_participation = false
        expect(presenter.previous_participation).to eq "No"
      end
    end
    context "when blank" do
      it "returns No" do
        eligibility.previous_participation = nil
        expect(presenter.previous_participation).to eq "No"
      end
    end
  end
end
