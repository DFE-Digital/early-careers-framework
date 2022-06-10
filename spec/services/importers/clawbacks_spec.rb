# frozen_string_literal: true

require "rails_helper"

RSpec.describe Importers::Clawbacks, :with_default_schedules do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }
  let(:participant_declaration) { create(:ect_participant_declaration) }

  subject { described_class.new(path_to_csv:) }

  describe "#call" do
    let(:mock_service) { instance_double("Finance::ClawbackDeclaration", call: true, errors: []) }

    context "happy path" do
      before do
        csv.write "declaration_id"
        csv.write "\n"
        csv.write participant_declaration.id
        csv.write "\n"
        csv.close
      end

      it "delegates to service class" do
        expect(Finance::ClawbackDeclaration).to receive(:new).with(participant_declaration:).and_return(mock_service)

        subject.call

        expect(mock_service).to have_received(:call)
      end
    end

    context "when incorrect headers" do
      before do
        csv.write "foo"
        csv.write "\n"
        csv.write participant_declaration.id
        csv.write "\n"
        csv.close
      end

      it "throws an error" do
        expect { subject.call }.to raise_error(NameError)
      end
    end

    context "when declaration cannot be found" do
      before do
        csv.write "declaration_id"
        csv.write "\n"
        csv.write "some_random_id"
        csv.write "\n"
        csv.close
      end

      it "populates errors" do
        subject.call

        expect(subject.errors).to eql(["no declaration found with id: some_random_id"])
      end
    end

    context "when error from service" do
      let(:participant_declaration) { create(:ect_participant_declaration, :voided) }

      before do
        csv.write "declaration_id"
        csv.write "\n"
        csv.write participant_declaration.id
        csv.write "\n"
        csv.close
      end

      it "does not add line item" do
        expect { subject.call }.not_to change(Finance::StatementLineItem, :count)
      end

      it "populates errors" do
        subject.call

        expect(subject.errors).to be_present
      end
    end

    context "when exception from within service" do
      let(:service) { instance_double(Finance::ClawbackDeclaration, errors: []) }

      before do
        allow(Finance::ClawbackDeclaration).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_raise(ActiveRecord::RecordNotSaved)

        csv.write "declaration_id"
        csv.write "\n"
        csv.write participant_declaration.id
        csv.write "\n"
        csv.close
      end

      it "does not throw an exception" do
        expect { subject.call }.not_to raise_error
      end

      it "logs the exception as an error" do
        subject.call
        expect(subject.errors).to include("declaration #{participant_declaration.id} has the following errors: ActiveRecord::RecordNotSaved")
      end
    end
  end
end
