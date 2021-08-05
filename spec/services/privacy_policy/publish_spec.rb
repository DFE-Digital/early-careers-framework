# frozen_string_literal: true

RSpec.describe PrivacyPolicy::Publish do
  let!(:previous_version) { create :privacy_policy, major_version: rand(1..3), minor_version: rand(0..5) }
  let(:new_policy_text) { Faker::Lorem.paragraph }

  before do
    allow(described_class::SOURCE).to receive(:read).and_return new_policy_text
  end

  context "when publishing minor update" do
    subject(:new_version) { described_class.call }

    it "creates a new policy record" do
      expect { new_version }.to change(PrivacyPolicy, :count)
    end

    it "sets the correct version" do
      expect(new_version).to have_attributes(
        major_version: previous_version.major_version,
        minor_version: previous_version.minor_version + 1,
      )
    end

    it "writes the source file content into the new record" do
      expect(new_version.html).to eq new_policy_text
    end

    context "when there are no policy changes" do
      let(:new_policy_text) { previous_version.html }

      it "does not create a new policy record" do
        expect { new_version }.not_to change(PrivacyPolicy, :count)
      end
    end
  end

  context "when publishing major update" do
    subject(:new_version) { described_class.call }

    it "creates a new policy record" do
      expect { new_version }.to change(PrivacyPolicy, :count)
    end

    it "sets the correct version" do
      expect(new_version).to have_attributes(
        major_version: previous_version.major_version,
        minor_version: previous_version.minor_version + 1,
      )
    end

    it "writes the source file content into the new record" do
      expect(new_version.html).to eq new_policy_text
    end
  end

  context "when publishing minor update" do
    subject(:new_version) { described_class.call(major: true) }

    it "creates a new policy record" do
      expect { new_version }.to change(PrivacyPolicy, :count)
    end

    it "sets the correct version" do
      expect(new_version).to have_attributes(
        major_version: previous_version.major_version + 1,
        minor_version: 0,
      )
    end

    it "writes the source file content into the new record" do
      expect(new_version.html).to eq new_policy_text
    end

    context "when there are no policy changes" do
      let(:new_policy_text) { previous_version.html }

      context "when previous version is a minor update" do
        let!(:previous_version) { create :privacy_policy, major_version: rand(1..3), minor_version: rand(1..5) }

        it "creates a new policy record" do
          expect { new_version }.to change(PrivacyPolicy, :count)
        end
      end

      context "when previous version is a major update" do
        let!(:previous_version) { create :privacy_policy, major_version: rand(1..3), minor_version: 0 }

        it "does not create a new policy record" do
          expect { new_version }.not_to change(PrivacyPolicy, :count)
        end
      end
    end
  end
end
