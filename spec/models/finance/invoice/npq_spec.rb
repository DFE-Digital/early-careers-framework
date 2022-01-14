# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Invoice::NPQ do
  before do
    ecf_schedule = create(:ecf_schedule)
    npq_schedule = create(:npq_specialist_schedule)
    Finance::Milestone.destroy_all
    create(:milestone, start_date: 10.days.ago, milestone_date: 3.days.ago, name: "ECF pre-start", schedule: ecf_schedule)
    create(:milestone, start_date: 10.days.ago, milestone_date: 3.days.ago, name: "NPQ pre-start", schedule: npq_schedule)
    create(:milestone, start_date: 2.days.ago, milestone_date: 1.day.ago, name: "ECF start", schedule: ecf_schedule)
    create(:milestone, start_date: 2.days.ago, milestone_date: 1.day.ago, name: "NPQ start", schedule: npq_schedule)
    create(:milestone, start_date: Time.zone.today, milestone_date: 3.days.from_now, name: "ECF ret-1", schedule: ecf_schedule)
    create(:milestone, start_date: Time.zone.today, milestone_date: 3.days.from_now, name: "NPQ ret-1", schedule: npq_schedule)
    create(:milestone, start_date: 4.days.from_now, milestone_date: 10.days.from_now, name: "ECF ret-2", schedule: ecf_schedule)
    create(:milestone, start_date: 4.days.from_now, milestone_date: 10.days.from_now, name: "NPQ ret-2", schedule: npq_schedule)
  end

  describe "#current" do
    it "returns the milestone including 'NPQ' where the interval range includes today" do
      expect(Finance::Invoice::NPQ.find_current_milestone.name).to eq "NPQ ret-1"
    end
  end

  describe "#payable" do
    it "returns the milestone including 'NPQ' where the interval range is most recent" do
      expect(Finance::Invoice::NPQ.find_payable_milestone.name).to eq "NPQ start"
    end
  end
end
