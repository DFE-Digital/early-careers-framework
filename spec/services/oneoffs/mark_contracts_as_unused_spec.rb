# frozen_string_literal: true

describe Oneoffs::MarkContractsAsUnused do
  before { allow(Rails.logger).to receive(:info) }

  def create_statement(call_off_contract)
    create(
      :ecf_statement,
      cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider,
      cohort: call_off_contract.cohort,
      contract_version: call_off_contract.version,
      mentor_contract_version: "0.0.1",
    )
  end

  def create_mentor_statement(mentor_call_off_contract)
    create(
      :ecf_statement,
      cpd_lead_provider: mentor_call_off_contract.lead_provider.cpd_lead_provider,
      cohort: mentor_call_off_contract.cohort,
      contract_version: "0.0.1",
      mentor_contract_version: mentor_call_off_contract.version,
    )
  end

  describe "#perform_change" do
    let(:dry_run) { false }
    let(:instance) { described_class.new }

    subject(:perform_change) { instance.perform_change(dry_run:) }

    it { is_expected.to eq(instance.recorded_info) }

    context "when there are call off contracts with associated statements" do
      let(:call_off_contract) { create(:call_off_contract) }

      before { create_statement(call_off_contract) }

      it "does not change the contract" do
        expect { perform_change }.not_to change { call_off_contract.reload.attributes }
      end
    end

    context "when there are call off contracts without associated statements" do
      let!(:call_off_contract_1) { create(:call_off_contract, version: "1.0") }
      let!(:call_off_contract_2) { create(:call_off_contract, version: "2.0") }

      it "prefixes the versions with 'unused_'" do
        expect { perform_change }.to change { call_off_contract_1.reload.version }.from("1.0").to("unused_1.0")
          .and change { call_off_contract_2.reload.version }.from("2.0").to("unused_2.0")
      end

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "Marking 2 contracts as unused (no associated finance statement)",
        ])
      end

      context "when the call off contracts have already been marked as unused" do
        let!(:call_off_contract) { create(:call_off_contract, :unused) }

        it "does not change the contracts" do
          expect { perform_change }.not_to change { call_off_contract.reload.attributes }
        end
      end
    end

    context "when there are duplicate call off contracts" do
      let(:original) { travel_to(1.day.ago) { create(:call_off_contract, :with_minimal_bands, version: "1.0") } }
      let!(:duplicate_1) do
        create(
          :call_off_contract,
          :with_minimal_bands,
          lead_provider: original.lead_provider,
          cohort: original.cohort,
          version: original.version,
        )
      end
      let!(:duplicate_2) do
        create(
          :call_off_contract,
          :with_minimal_bands,
          lead_provider: original.lead_provider,
          cohort: original.cohort,
          version: original.version,
        )
      end

      before { create_statement(original) }

      it "prefixes the duplicate version with 'unused_'" do
        expect { perform_change }.to change { duplicate_1.reload.version }.from("1.0").to("unused_1.0")
          .and change { duplicate_2.reload.version }.from("1.0").to("unused_1.0")
      end

      it "does not modify the original" do
        expect { perform_change }.not_to change { original.reload.attributes }
      end

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "Marking 2 contracts as unused (duplicates)",
        ])
      end

      context "when the duplicates are not a deep-match (contract attributes differ)" do
        before { duplicate_1.update!(set_up_fee: -123) }

        it "does not modify the duplicate" do
          expect { perform_change }.not_to change { duplicate_1.reload.attributes }
        end

        it "logs out information" do
          perform_change

          expect(instance).to have_recorded_info([
            "Marking 1 contracts as unused (duplicates)",
            "Skipping duplicate (#{duplicate_1.id}) due to attributes differing with original (#{original.id})",
          ])
        end
      end

      context "when the duplicates are not a deep-match (participant bands attributes differ)" do
        before { duplicate_2.participant_bands.sample.update!(max: -123) }

        it "does not modify the duplicate" do
          expect { perform_change }.not_to change { duplicate_2.reload.attributes }
        end

        it "logs out information" do
          perform_change

          expect(instance).to have_recorded_info([
            "Marking 1 contracts as unused (duplicates)",
            "Skipping duplicate (#{duplicate_2.id}) due to attributes differing with original (#{original.id})",
          ])
        end
      end

      context "when the duplicates are a deep-match, but the participant bands are in a different order" do
        before do
          # Creating a duplicate of the first band and saving it, then destroying
          # the original first band will cause the bands to be in a different order
          # to the original.
          duplicate_2_first_band = duplicate_2.participant_bands.first
          duplicate_2_first_band.dup.save!
          duplicate_2_first_band.destroy!
        end

        it "prefixes the duplicate version with 'unused_'" do
          expect { perform_change }.to change { duplicate_1.reload.version }.from("1.0").to("unused_1.0")
            .and change { duplicate_2.reload.version }.from("1.0").to("unused_1.0")
        end

        it "logs out information" do
          perform_change

          expect(instance).to have_recorded_info([
            "Marking 2 contracts as unused (duplicates)",
          ])
        end
      end
    end

    context "when there are mentor call off contracts with associated statements" do
      let(:mentor_call_off_contract) { create(:mentor_call_off_contract) }

      before { create_mentor_statement(mentor_call_off_contract) }

      it "does not change the contract" do
        expect { perform_change }.not_to change { mentor_call_off_contract.reload.attributes }
      end
    end

    context "when there are mentor call off contracts without associated statements" do
      let!(:mentor_call_off_contract_1) { create(:mentor_call_off_contract, version: "1.0") }
      let!(:mentor_call_off_contract_2) { create(:mentor_call_off_contract, version: "2.0") }

      it "prefixes the versions with 'unused_'" do
        expect { perform_change }.to change { mentor_call_off_contract_1.reload.version }.from("1.0").to("unused_1.0")
          .and change { mentor_call_off_contract_2.reload.version }.from("2.0").to("unused_2.0")
      end

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "Marking 2 mentor contracts as unused (no associated finance statement)",
        ])
      end

      context "when the mentor call off contracts have already been marked as unused" do
        let!(:mentor_call_off_contract) { create(:mentor_call_off_contract, version: "unused_1.0") }

        it "does not change the contracts" do
          expect { perform_change }.not_to change { mentor_call_off_contract.reload.attributes }
        end
      end
    end

    context "when there are duplicate mentor call off contracts" do
      let(:original) { travel_to(1.day.ago) { create(:mentor_call_off_contract, version: "1.0") } }
      let!(:duplicate_1) do
        create(
          :mentor_call_off_contract,
          lead_provider: original.lead_provider,
          cohort: original.cohort,
          version: original.version,
        )
      end
      let!(:duplicate_2) do
        create(
          :mentor_call_off_contract,
          lead_provider: original.lead_provider,
          cohort: original.cohort,
          version: original.version,
        )
      end

      before { create_mentor_statement(original) }

      it "prefixes the duplicate version with 'unused_'" do
        expect { perform_change }.to change { duplicate_1.reload.version }.from("1.0").to("unused_1.0")
          .and change { duplicate_2.reload.version }.from("1.0").to("unused_1.0")
      end

      it "does not modify the original" do
        expect { perform_change }.not_to change { original.reload.attributes }
      end

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "Marking 2 mentor contracts as unused (duplicates)",
        ])
      end

      context "when the duplicates are not a deep-match (contract attributes differ)" do
        before { duplicate_1.update!(payment_per_participant: -123) }

        it "does not modify the duplicate" do
          expect { perform_change }.not_to change { duplicate_1.reload.attributes }
        end

        it "logs out information" do
          perform_change

          expect(instance).to have_recorded_info([
            "Marking 1 mentor contracts as unused (duplicates)",
            "Skipping mentor duplicate (#{duplicate_1.id}) due to attributes differing with original (#{original.id})",
          ])
        end
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }
      let(:call_off_contract) { create(:call_off_contract) }

      it "does not make any changes, but records the changes it would make" do
        expect { perform_change }.not_to change { call_off_contract.reload.attributes }

        expect(instance).to have_recorded_info([
          "~~~ DRY RUN ~~~",
          "Marking 1 contracts as unused (no associated finance statement)",
        ])
      end
    end
  end
end
