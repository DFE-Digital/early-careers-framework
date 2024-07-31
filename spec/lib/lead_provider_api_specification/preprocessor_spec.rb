# frozen_string_literal: true

RSpec.describe LeadProviderApiSpecification::Preprocessor do
  let(:swagger_path) { "spec/fixtures/files/api_reference/api_spec.json" }
  let(:instance) { described_class.new(swagger_path) }

  describe "#preprocess!" do
    let(:environment) { "separation" }

    before { allow(Rails).to receive(:env) { environment.inquiry } }

    context "when the swagger doc contains NPQ references" do
      it "removes the NPQ references" do
        expect(File.read(swagger_path)).to include("npq")

        file_double = instance_double("File")
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open).with(swagger_path, "w").and_yield(file_double)

        expect(file_double).to receive(:write) do |contents|
          swagger_without_npq = File.read("spec/fixtures/files/api_reference/api_spec_no_npq.json").strip
          expect(contents).to eq(swagger_without_npq)
        end

        instance.preprocess!
      end

      context "when references still exist after preprocessing the file" do
        before { stub_const("#{described_class}::MAX_ITERATIONS", 1) }

        it { expect { instance.preprocess! }.to raise_error(RuntimeError, /NPQ references still present/) }
      end

      context "when an unrecognised description that matches 'npq' is present" do
        before do
          allow(File).to receive(:read)
            .with(swagger_path)
            .and_return(%(
              {
                  "paths": {
                      "/path": {
                          "get": {
                              "description": "an unexpected reference to npq!"
                          }
                      }
                  }
              }
            ))
        end

        it { expect { instance.preprocess! }.to raise_error(RuntimeError, /Unexpected description structure/) }
      end

      context "when an unrecognised key that matches 'npq' is present" do
        before do
          allow(File).to receive(:read)
            .with(swagger_path)
            .and_return(%(
              {
                  "paths": {
                      "/path": {
                          "get": {
                              "unknown-key": "with an NPQ value"
                          }
                      }
                  }
              }
            ))
        end

        it { expect { instance.preprocess! }.to raise_error(RuntimeError, /Unhandled key/) }
      end
    end

    context "when the swagger doc contains no NPQ references" do
      let(:swagger_path) { "spec/fixtures/files/api_reference/api_spec_no_npq.json" }

      it "does not modify the file" do
        expect(File).not_to receive(:write)

        instance.preprocess!
      end
    end

    context "when not removing NPQ references" do
      let(:environment) { "production" }

      it "does not read or write any files" do
        expect(File).not_to receive(:read)
        expect(File).not_to receive(:write)

        instance.preprocess!
      end
    end
  end
end
