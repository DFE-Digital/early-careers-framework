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
          expect(phase_banner_tag_text(other_env)).to eql(other_env)
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
        "deployed_development" => "grey",
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
end
