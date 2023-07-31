# frozen_string_literal: true

require "rails_helper"

class TestQuery
  include Api::V3::Concerns::Orderable

  attr_accessor :params
end

class Test < ApplicationRecord; end

describe Api::V3::Concerns::Orderable, type: :controller do
  before { allow(Test).to receive(:attribute_names).and_return(%w[id full_name]) }

  let(:instance) { TestQuery.new }

  describe "#sort_order" do
    it "returns formatted sort param relative to the model" do
      instance.params = { sort: "-full_name,id,invalid" }
      sort_order = instance.sort_order(model: Test)
      expect(sort_order).to eq("tests.full_name DESC, tests.id ASC")
    end

    it "returns nil when there is no sort param" do
      instance.params = { sort: " " }
      sort_order = instance.sort_order(model: Test)
      expect(sort_order).to be_nil
    end

    it "returns the default sort order when there is no sort param" do
      default = "created_at ASC"
      instance.params = { sort: nil }
      sort_order = instance.sort_order(default:, model: Test)
      expect(sort_order).to eq(default)
    end
  end
end
