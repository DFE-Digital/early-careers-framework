# frozen_string_literal: true

require "rails_helper"

RSpec.describe FutureDateValidator do
  with_model :declaration do
    table do |t|
      t.datetime :statement_date
    end

    model do
      validates :statement_date, future_date: true
    end
  end

  context "when date in the future" do
    it "is not valid" do
      declaration = Declaration.new(statement_date: Time.zone.tomorrow)
      expect(declaration).not_to be_valid
      expect(declaration.errors[:statement_date]).to include("The property '#/statement_date' can not declare a future date")
    end
  end

  context "when date in the past" do
    it "is valid" do
      expect(Declaration.new(statement_date: Time.zone.yesterday)).to be_valid
    end
  end

  context "when date is nil" do
    it "is valid" do
      expect(Declaration.new(statement_date: nil)).to be_valid
    end
  end
end
