# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipationRecord, type: :model do
  before :each do
    @participation_record = create(:participation_record)
  end
  let(:ect_profile) { create(:early_career_teacher_profile) }

  describe "state transitions" do
    it "should have an initial state of assigned" do
      expect(@participation_record).to have_state(:assigned)
    end

    it "should only have expected transitions from the initial state" do
      expect(@participation_record).to allow_event(:join)
      expect(@participation_record).not_to allow_event(:defer, :resume, :withdraw, :complete)
      expect(@participation_record).to transition_from(:assigned).to(:active).on_event(:join)
    end

    it "should only have expected transitions from the active state" do
      @participation_record.join
      expect(@participation_record).to have_state(:active)
      expect(@participation_record).to allow_event(:defer, :withdraw, :complete)
      expect(@participation_record).not_to allow_event(:resume, :join)
      expect(@participation_record).to transition_from(:active).to(:deferred).on_event(:defer)
      expect(@participation_record).to transition_from(:active).to(:withdrawn).on_event(:withdraw)
      expect(@participation_record).to transition_from(:active).to(:completed).on_event(:complete)
    end

    it "should only have expected transitions from the deferred state" do
      @participation_record.join
      @participation_record.defer
      expect(@participation_record).to have_state(:deferred)
      expect(@participation_record).to allow_event(:resume, :withdraw)
      expect(@participation_record).not_to allow_event(:join, :defer, :complete)
      expect(@participation_record).to transition_from(:deferred).to(:active).on_event(:resume)
      expect(@participation_record).to transition_from(:deferred).to(:withdrawn).on_event(:withdraw)
    end

    it "should only have expected transitions from the withdrawn state" do
      @participation_record.join
      @participation_record.withdraw
      expect(@participation_record).to have_state(:withdrawn)
      expect(@participation_record).not_to allow_event(:join, :defer, :resume, :complete)
      expect(@participation_record).to transition_from(:active, :deferred).to(:withdrawn).on_event(:withdraw)
    end

    it "should have no allowed transitions from the completed state" do
      @participation_record.join
      @participation_record.complete
      expect(@participation_record).to have_state(:completed)
      expect(@participation_record).not_to allow_event(:join, :defer, :resume, :complete, :withdraw)
    end
  end
end
