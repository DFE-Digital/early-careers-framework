# frozen_string_literal: true

require "rails_helper"

RSpec.describe DqtRecordCheck do
  shared_context "build fake DQT response" do
    before do
      allow_any_instance_of(FullDQT::Client).to(receive(:get_record).and_return(fake_api_response || default_api_response))
    end
  end

  let(:trn) { "1234567" }
  let(:nino) { "QQ123456A" }
  let(:date_of_birth) { 25.years.ago.to_date }
  let(:full_name) { "Mr Nelson Muntz" }
  let(:kwargs) { { full_name:, trn:, date_of_birth:, nino: } }
  let(:default_api_response) do
    {
      "state_name" => "Active",
      "trn" => trn,
      "name" => full_name,
      "ni_number" => nino,
      "dob" => 25.years.ago.to_date,
    }
  end
  let(:fake_api_response) { nil }

  subject { DqtRecordCheck.new(**kwargs) }

  context "when trn and national insurance number are blank" do
    let(:trn) { "" }
    let(:nino) { "" }
    include_context "build fake DQT response"

    it { expect(subject.call.failure_reason).to be(:trn_and_nino_blank) }
  end

  context "when inactive" do
    include_context "build fake DQT response" do
      let(:fake_api_response) { { "state_name" => "Inactive" } }
    end

    it { expect(subject.call.failure_reason).to be(:found_but_not_active) }
  end

  context "when active" do
    describe "matching on TRN" do
      context "when exact" do
        include_context "build fake DQT response"

        it("#trn_matches is true") { expect(subject.call.trn_matches).to be(true) }
      end

      context "when different" do
        include_context "build fake DQT response" do
          let(:fake_api_response) { default_api_response.merge("trn" => "9988776") }
        end

        it("#trn_matches is false") { expect(subject.call.trn_matches).to be(false) }
      end
    end

    describe "matching on name" do
      context "when check_first_name_only: true" do
        context "when exact" do
          include_context "build fake DQT response"

          it("#name_matches is true") { expect(subject.call.name_matches).to be(true) }
        end

        context "when there is whitespace around the supplied name" do
          let(:full_name) { " Mr Nelson Muntz  " }
          include_context "build fake DQT response"

          it("#name_matches is true") { expect(subject.call.name_matches).to be(true) }
        end

        context "when there is whitespace around the name in the API response" do
          include_context "build fake DQT response" do
            let(:fake_api_response) { default_api_response.merge("name" => " #{full_name} ") }
          end

          it("#name_matches is true") { expect(subject.call.name_matches).to be(true) }
        end

        context "when first names are different but surnames are the same" do
          include_context "build fake DQT response" do
            let(:fake_api_response) { default_api_response.merge("name" => "Mr Eddie Muntz") }
          end

          it("#name_matches is false") { expect(subject.call.name_matches).to be(false) }
        end
      end

      context "when check_first_name_only: false" do
        let(:kwargs) { { full_name:, trn:, date_of_birth:, nino:, check_first_name_only: false } }

        context "when exact" do
          include_context "build fake DQT response"

          it("#name_matches is true") { expect(subject.call.name_matches).to be(true) }
        end

        context "when first names match but surnames are different" do
          include_context "build fake DQT response" do
            let(:fake_api_response) { default_api_response.merge("name" => "Mr Nelson Piquet") }
          end

          it("#name_matches is false") { expect(subject.call.name_matches).to be(false) }
        end
      end
    end

    describe "matching on date of birth" do
      context "when exact" do
        include_context "build fake DQT response"

        it("#dob_matches is true") { expect(subject.call.dob_matches).to be(true) }
      end

      context "when different" do
        include_context "build fake DQT response" do
          let(:fake_api_response) { default_api_response.merge("dob" => 27.years.ago.to_date) }
        end

        it("#dob_matches is false") { expect(subject.call.dob_matches).to be(false) }
      end
    end

    describe "matching on national insurance number" do
      context "when exact" do
        include_context "build fake DQT response"

        it("#nino_matches is true") { expect(subject.call.nino_matches).to be(true) }
      end

      context "when different" do
        include_context "build fake DQT response" do
          let(:fake_api_response) { default_api_response.merge("ni_number" => "ZZ123456X") }
        end

        it("#nino_matches is false") { expect(subject.call.nino_matches).to be(false) }
      end
    end

    describe "overall match status" do
      include_context "build fake DQT response"

      context "when everything matches" do
        it("#total_matches is 4") { expect(subject.call.total_matched).to eq(4) }
        it("#failure_reason is nil") { expect(subject.call.failure_reason).to be_nil }
      end
    end

    context "when there are less than three matches excluding TRN" do
      include_context "build fake DQT response" do
        let(:fake_api_response) { default_api_response.except("dob").merge("name" => "Jimbo Jones") }
      end

      before do
        allow_any_instance_of(DqtRecordCheck).to receive(:check_record).and_call_original
      end

      it "sets trn to 0000001 and calls check_record again" do
        expect(subject.send(:trn)).to eql(trn)

        subject.call

        expect(subject.send(:trn)).to eql("0000001")
        expect(subject).to have_received(:check_record).twice
      end
    end
  end

  describe "private methods" do
    names = {
      "Miss Allison Taylor"         => { without_title_prefix: "Allison Taylor", first_name: "Allison" },
      "Mr Dolph Starbeam"           => { without_title_prefix: "Dolph Starbeam", first_name: "Dolph" },
      "Rev Tim Lovejoy"             => { without_title_prefix: "Tim Lovejoy", first_name: "Tim" },
      "Prof. Jonathan Frink"        => { without_title_prefix: "Jonathan Frink", first_name: "Jonathan" },
      "Ms. Edna Krabapel"           => { without_title_prefix: "Edna Krabapel", first_name: "Edna" },
      "Milhouse Van Houten"         => { without_title_prefix: "Milhouse Van Houten", first_name: "Milhouse" },
      "Mr Charles Montgomery Burns" => { without_title_prefix: "Charles Montgomery Burns", first_name: "Charles" },
    }

    describe "#strip_title_prefix" do
      names.each do |input, output|
        specify "#{input} => #{output.fetch(:without_title_prefix)}" do
          expect(subject.send(:strip_title_prefix, input)).to eql(output.fetch(:without_title_prefix))
        end
      end
    end

    describe "#extract_first_name" do
      names.each do |input, output|
        specify "#{input} => #{output.fetch(:first_name)}" do
          expect(subject.send(:extract_first_name, input)).to eql(output.fetch(:first_name))
        end
      end
    end
  end
end
