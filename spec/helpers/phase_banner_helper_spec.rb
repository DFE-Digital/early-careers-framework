# frozen_string_literal: true

require "rails_helper"

RSpec.describe PhaseBannerHelper, type: :helper do
  describe "#phase_banner_tag_text" do
    context "when production" do
      it "returns 'Beta'" do
        expect(phase_banner_tag_text("production")).to eql("Beta")
      end
    end

    context "other environments" do
      %w[development staging review sandbox an_unknown_environment].each do |other_env|
        let(:other_env) { other_env }

        it "for #{other_env} it returns #{other_env}" do
          expect(phase_banner_tag_text(other_env)).to eql(other_env.capitalize)
        end
      end
    end
  end

  describe "#phase_banner_tag_colour" do
    context "when production" do
      it "returns nil (for the default white on blue)" do
        expect(phase_banner_tag_colour("production")).to be_nil
      end
    end

    context "other environments" do
      {
        "development" => "red",
        "review" => "purple",
        "staging" => "turquoise",
        "sandbox" => "yellow",
        "an_unknown_environment" => nil,
      }.each do |other_env, expected_colour|
        let(:other_env) { other_env }

        it "for #{other_env} it returns #{expected_colour || 'nil'}" do
          expect(phase_banner_tag_colour(other_env)).to eql(expected_colour)
        end
      end
    end
  end

  describe "#maintenance_banner_dismissed?" do
    subject { helper }

    context "when the dismissed_until cookie is not set" do
      it { is_expected.not_to be_maintenance_banner_dismissed }
    end

    context "when the dismissed_until cookie is set to a future value" do
      before { helper.request.cookies[:dismiss_maintenance_banner_until] = 1.day.from_now.to_s }

      it { is_expected.to be_maintenance_banner_dismissed }
    end

    context "when the dismissed_until cookie is set to a past value" do
      before { helper.request.cookies[:dismiss_maintenance_banner_until] = 1.day.ago.to_s }

      it { is_expected.not_to be_maintenance_banner_dismissed }
    end

    context "when the dismissed_until cookie does not contain a valid time" do
      before { helper.request.cookies[:dismiss_maintenance_banner_until] = "1 week from now" }

      it { is_expected.not_to be_maintenance_banner_dismissed }
    end
  end
end
