# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminHelper, type: :helper do
  let(:user) { profile.user }

  describe "#admin_edit_user_path" do
    context "when the user is a lead provider" do
      let(:profile) { create(:lead_provider_profile) }
      let(:result) { "/admin/suppliers/lead-providers/users/#{user.id}/edit" }

      it "returns the admin edit url for the user" do
        expect(helper.admin_edit_user_path(user)).to eq(result)
      end
    end

    context "when the user is an induction coordinator" do
      let(:profile) { create(:induction_coordinator_profile) }
      let(:result) { "/admin/induction-coordinators/#{user.id}/edit" }

      it "returns the admin edit url for the user" do
        expect(helper.admin_edit_user_path(user)).to eq(result)
      end
    end
  end

  context "using the induction record for ects and mentors" do
    let(:profile) { create(:ect) }
    let!(:induction_programme) { profile.current_induction_record.induction_programme }

    before do
      profile.current_induction_record.withdrawing!
      Induction::Enrol.call(participant_profile: profile, induction_programme:, preferred_email: "login2@example.com")
    end

    describe "#all_emails_associated_with_a_user" do
      it "returns all emails associated with a user" do
        user = profile.user
        users_emails = helper.all_emails_associated_with_a_user(user)
        expect(users_emails).to include(user.email)
        expect(users_emails).to include("login2@example.com")
      end
    end
  end

  describe "#html_list" do
    let(:values) { %w[aaa bbb ccc ddd] }
    subject { html_list(values) }

    it "formats the provided values in a ul.govuk-list" do
      expect(subject).to have_css("ul.govuk-list > li", count: values.size)
      expect(values).to all(be_in(subject))
    end

    context "when nothing is passed in" do
      let(:values) { [] }

      it("renders nothing") { is_expected.to be_nil }
    end

    context "when bullets: true" do
      subject { html_list(values, bullets: true) }

      it "it adds the govuk-list--bullet class to the list" do
        expect(subject).to have_css("ul.govuk-list.govuk-list--bullet > li", count: values.size)
      end
    end
  end

  describe "#induction_programme_friendly_name" do
    context("when short: false") do
      it "returns human readable names for induction programmes" do
        expect(induction_programme_friendly_name("full_induction_programme")).to eql("Full induction programme")
        expect(induction_programme_friendly_name("school_funded_fip")).to eql("School funded full induction programme")
      end
    end

    context("when short: false") do
      it "returns shortened readable names for induction programmes" do
        expect(induction_programme_friendly_name("full_induction_programme", short: true)).to eql("FIP")
        expect(induction_programme_friendly_name("school_funded_fip", short: true)).to eql("School funded FIP")
      end
    end
  end

  describe "#format_address" do
    it "returns nil when nothing is passed in" do
      expect(format_address).to be_nil
    end

    it "joins the elements with <br> when multiple are passed in" do
      expect(format_address("a")).to eql("a")
      expect(format_address("a", "b")).to eql("a<br>b")
      expect(format_address("a", "b", "c")).to eql("a<br>b<br>c")
    end
  end

  describe "#admin_participant_header_and_title" do
    let(:participant_profile) do
      create(
        :mentor_participant_profile,
        user: create(:user, full_name: "Joey"),
      )
    end

    let(:presenter) { Admin::ParticipantPresenter.new(participant_profile) }

    subject do
      admin_participant_header_and_title(
        presenter:,
        section: "ABC",
      )
    end

    it "returns a h1 tag the section that has a caption containing the user name" do
      expect(subject).to have_css("h1", text: /Joey - ABC/)
    end

    it "returns a caption containing the user role" do
      expect(subject).to have_css(".govuk-caption-l", text: "Mentor")
    end

    it "returns the TRN" do
      expect(subject).to have_content(/TRN: \d+/)
    end

    it "returns the cohort" do
      expect(subject).to have_content(/Cohort: \d+/)
    end
  end

  describe "#admin_participant_role_name" do
    {
      "ParticipantProfile::Mentor" => "Mentor",
      "ParticipantProfile::ECT" => "ECT",
      "ParticipantProfile::NPQ" => "NPQ",
    }.each do |input, expected_output|
      it "returns #{expected_output} when passed #{input}" do
        expect(admin_participant_role_name(input)).to eql(expected_output)
      end
    end
  end
end
