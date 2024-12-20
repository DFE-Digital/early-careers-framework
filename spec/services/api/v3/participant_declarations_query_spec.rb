# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ParticipantDeclarationsQuery do
  let(:cohort1) { Cohort.current || create(:cohort, :current) }
  let(:cohort2) { Cohort.previous || create(:cohort, :previous) }

  let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider1) { cpd_lead_provider1.lead_provider }
  let(:school_cohort1) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider1, cohort: cohort1) }
  let(:school_cohort2) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider1, cohort: cohort2) }
  let(:participant_profile1) { create(:ect, :eligible_for_funding, school_cohort: school_cohort1, lead_provider: lead_provider1) }
  let(:participant_profile2) { create(:ect, :eligible_for_funding, school_cohort: school_cohort1, lead_provider: lead_provider1) }
  let(:participant_profile3) { create(:ect, :eligible_for_funding, school_cohort: school_cohort2, lead_provider: lead_provider1) }

  let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider2) { cpd_lead_provider2.lead_provider }
  let(:school_cohort3) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider2, cohort: cohort2) }
  let(:participant_profile4) { create(:ect, :eligible_for_funding, school_cohort: school_cohort3, lead_provider: lead_provider1) }

  let(:npq_only_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { npq_only_lead_provider.npq_lead_provider }
  let!(:npq_application) { create(:npq_application, :accepted, :with_started_declaration, npq_lead_provider:, cohort: cohort1) }

  let(:delivery_partner1) { create(:delivery_partner) }
  let(:delivery_partner2) { create(:delivery_partner) }
  let(:params) { {} }

  subject { described_class.new(cpd_lead_provider: cpd_lead_provider1, params:) }

  describe "#participant_declarations_for_pagination" do
    let!(:participant_declaration1) do
      travel_to(3.days.ago) do
        declaration = create(
          :ect_participant_declaration,
          :paid,
          uplifts: [:sparsity_uplift],
          declaration_type: "started",
          evidence_held: "training-event-attended",
          cpd_lead_provider: cpd_lead_provider1,
          participant_profile: participant_profile1,
          delivery_partner: delivery_partner1,
          cohort: participant_profile1.schedule.cohort,
        )

        ParticipantDeclaration::ECF.where(id: declaration.id).select(:id, :created_at).first
      end
    end
    let!(:participant_declaration2) do
      travel_to(1.day.ago) do
        declaration = create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider1,
          participant_profile: participant_profile2,
          delivery_partner: delivery_partner2,
          cohort: participant_profile2.schedule.cohort,
        )

        ParticipantDeclaration::ECF.where(id: declaration.id).select(:id, :created_at).first
      end
    end
    let!(:participant_declaration3) do
      travel_to(5.days.ago) do
        declaration = create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider1,
          participant_profile: participant_profile3,
          delivery_partner: delivery_partner2,
          cohort: participant_profile3.schedule.cohort,
        )

        ParticipantDeclaration::ECF.where(id: declaration.id).select(:id, :created_at).first
      end
    end
    let!(:participant_declaration4) do
      travel_to(5.days.ago) do
        declaration = create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider2,
          participant_profile: participant_profile4,
          delivery_partner: delivery_partner1,
          cohort: participant_profile4.schedule.cohort,
        )

        ParticipantDeclaration::ECF.where(id: declaration.id).select(:id, :created_at).first
      end
    end

    context "empty params" do
      it "returns all participant declarations for cpd_lead_provider1" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration3, participant_declaration1, participant_declaration2])
      end

      context "when declarations have been transferred to to the provider" do
        let(:transfer_induction_record) do
          NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
            .new(lead_provider_from: lead_provider2, lead_provider_to: lead_provider1)
            .build
        end
        let!(:transferred_declaration) do
          travel_to(5.days.ago) do
            declaration = create(
              :ect_participant_declaration,
              :eligible,
              declaration_type: "started",
              cpd_lead_provider: cpd_lead_provider2,
              participant_profile: transfer_induction_record.participant_profile,
              delivery_partner: delivery_partner1,
              cohort: transfer_induction_record.participant_profile.schedule.cohort,
            )

            ParticipantDeclaration::ECF.where(id: declaration.id).select(:id, :created_at).first
          end
        end

        it "is included in the response" do
          expect(subject.participant_declarations_for_pagination.to_a).to include(transferred_declaration)
        end
      end
    end

    context "with cohort filter" do
      let(:params) { { filter: { cohort: cohort2.start_year.to_s } } }

      it "returns all participant declarations for the specific cohort" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration3])
      end
    end

    context "with multiple cohort filter" do
      let(:params) { { filter: { cohort: [cohort1.start_year, cohort2.start_year].join(",") } } }

      it "returns all participant declarations for the specific cohort" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration3, participant_declaration1, participant_declaration2])
      end
    end

    context "with incorrect cohort filter" do
      let(:params) { { filter: { cohort: "2017" } } }

      it "returns no participant declarations" do
        expect(subject.participant_declarations_for_pagination.to_a).to be_empty
      end
    end

    context "with participant_id filter" do
      let(:params) { { filter: { participant_id: participant_profile1.user_id } } }

      it "returns participant declarations for the specific participant_id" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration1])
      end
    end

    context "with multiple participant_id filter" do
      let(:params) { { filter: { participant_id: [participant_profile1.user_id, participant_profile2.user_id].join(",") } } }

      it "returns participant declarations for the specific participant_id" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration1, participant_declaration2])
      end
    end

    context "with incorrect participant_id filter" do
      let(:params) { { filter: { participant_id: "madeup" } } }

      it "returns no participant declarations" do
        expect(subject.participant_declarations_for_pagination.to_a).to be_empty
      end
    end

    context "with updated_since filter" do
      let(:params) { { filter: { updated_since: 2.days.ago.iso8601 } } }

      before do
        ParticipantDeclaration.find(participant_declaration1.id).update!(updated_at: 3.days.ago)
        ParticipantDeclaration.find(participant_declaration2.id).update!(updated_at: 1.day.ago)
        ParticipantDeclaration.find(participant_declaration3.id).update!(updated_at: 5.days.ago)
        ParticipantDeclaration.find(participant_declaration4.id).update!(updated_at: 6.days.ago)
      end

      it "returns participant declarations for the specific updated time" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration2])
      end
    end

    context "with delivery_partner_id filter" do
      let(:params) { { filter: { delivery_partner_id: delivery_partner2.id } } }

      it "returns participant declarations for the specific delivery_partner_id" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration3, participant_declaration2])
      end
    end

    context "with multiple delivery_partner_id filter" do
      let(:params) { { filter: { delivery_partner_id: [delivery_partner1.id, delivery_partner2.id].join(",") } } }

      it "returns participant declarations for the specific delivery_partner_id" do
        expect(subject.participant_declarations_for_pagination.to_a).to eq([participant_declaration3, participant_declaration1, participant_declaration2])
      end
    end

    context "with incorrect delivery_partner_id filter" do
      let(:params) { { filter: { delivery_partner_id: "madeup" } } }

      it "returns no participant declarations" do
        expect(subject.participant_declarations_for_pagination.to_a).to be_empty
      end
    end

    context "with NPQ only lead provider" do
      subject { described_class.new(cpd_lead_provider: npq_only_lead_provider, params:) }

      it "returns no participant declarations" do
        expect(subject.participant_declarations_for_pagination.to_a).to be_empty
      end

      context "when ECF declarations with nil partnership exist that do not belong to the NPQ only lead provider" do
        let(:cpd_lead_provider3) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:lead_provider3) { cpd_lead_provider3.lead_provider }
        let(:school_cohort4) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider3, cohort: cohort2) }
        let(:participant_profile5) { create(:ect, :eligible_for_funding, school_cohort: school_cohort4, lead_provider: lead_provider3) }
        let!(:participant_declaration5) do
          travel_to(5.days.ago) do
            declaration = create(
              :ect_participant_declaration,
              :eligible,
              declaration_type: "started",
              cpd_lead_provider: cpd_lead_provider3,
              participant_profile: participant_profile5,
              cohort: participant_profile5.schedule.cohort,
            )

            ParticipantDeclaration.where(id: declaration.id).select(:id, :created_at).first
          end
        end
        let(:induction_programme_cip) { create(:induction_programme, :cip) }
        let!(:induction_record) { create(:induction_record, participant_profile: participant_profile5, induction_programme: induction_programme_cip) }

        it "returns only NPQ declarations for the provider" do
          expect(subject.participant_declarations_for_pagination.pluck(:id)).to be_empty
        end
      end
    end

    context "with an NPQ and ECF lead provider" do
      let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
      let(:npq_lead_provider) { cpd_lead_provider1.npq_lead_provider }
      let(:ecf_declarations) { [participant_declaration3, participant_declaration1, participant_declaration2] }
      let!(:npq_application) { create(:npq_application, :accepted, :with_started_declaration, npq_lead_provider: cpd_lead_provider1.npq_lead_provider, cohort: cohort2) }

      it "returns all participant declarations for that provider" do
        expect(subject.participant_declarations_for_pagination.pluck(:id)).to match_array(ecf_declarations.map(&:id))
      end

      context "with cohort filter" do
        let(:cohort) { cohort2.start_year.to_s }
        let(:params) { { filter: { cohort: } } }

        it "returns all participant declarations for the specific cohort" do
          expect(subject.participant_declarations_for_pagination.pluck(:id)).to match_array([participant_declaration3.id])
        end
      end

      context "with multiple cohort filter" do
        let(:params) { { filter: { cohort: [cohort1.start_year, cohort2.start_year].join(",") } } }

        it "returns all participant declarations for the specific cohort" do
          expect(subject.participant_declarations_for_pagination.pluck(:id)).to match_array(ecf_declarations.map(&:id))
        end
      end

      context "with incorrect cohort filter" do
        let(:params) { { filter: { cohort: "2017" } } }

        it "returns no participant declarations" do
          expect(subject.participant_declarations_for_pagination.to_a).to be_empty
        end
      end
    end
  end

  describe "#participant_declarations_from" do
    let!(:participant_declaration1) do
      travel_to(3.days.ago) do
        create(
          :ect_participant_declaration,
          :paid,
          uplifts: [:sparsity_uplift],
          declaration_type: "started",
          evidence_held: "training-event-attended",
          cpd_lead_provider: cpd_lead_provider1,
          participant_profile: participant_profile1,
          delivery_partner: delivery_partner1,
          cohort: participant_profile1.schedule.cohort,
        )
      end
    end
    let!(:participant_declaration2) do
      travel_to(1.day.ago) do
        create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider1,
          participant_profile: participant_profile2,
          delivery_partner: delivery_partner2,
          cohort: participant_profile2.schedule.cohort,
        )
      end
    end
    let!(:participant_declaration3) do
      travel_to(5.days.ago) do
        create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider1,
          participant_profile: participant_profile3,
          delivery_partner: delivery_partner2,
          cohort: participant_profile3.schedule.cohort,
        )
      end
    end
    let!(:participant_declaration4) do
      travel_to(5.days.ago) do
        create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider2,
          participant_profile: participant_profile4,
          delivery_partner: delivery_partner1,
          cohort: participant_profile4.schedule.cohort,
        )
      end
    end

    it "returns all declarations passed in from query in the correct order" do
      paginated_query = ParticipantDeclaration.where(cpd_lead_provider: cpd_lead_provider1)
      expect(subject.participant_declarations_from(paginated_query).to_a).to eq([participant_declaration3, participant_declaration1, participant_declaration2])
    end

    context "with a subset of declarations" do
      it "returns only the declarations that have been paginated" do
        paginated_query = ParticipantDeclaration.where(id: participant_declaration1.id)
        expect(subject.participant_declarations_from(paginated_query).to_a).to eq([participant_declaration1])
      end
    end

    context "when NPQ application exists for same lead provider" do
      let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
      let!(:npq_declaration) do
        create(
          :npq_participant_declaration,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider1,
        )
      end
      let(:paginated_query) { ParticipantDeclaration.where(cpd_lead_provider: cpd_lead_provider1) }

      it "returns only ecf declarations" do
        expect(subject.participant_declarations_from(paginated_query).to_a).to eq([participant_declaration3, participant_declaration1, participant_declaration2])
      end
    end
  end

  describe "#participant_declaration" do
    let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
    let!(:npq_participant_declaration) do
      create(
        :npq_participant_declaration,
        declaration_type: "started",
        cpd_lead_provider: cpd_lead_provider1,
      )
    end
    let!(:participant_declaration) do
      create(
        :ect_participant_declaration,
        :paid,
        uplifts: [:sparsity_uplift],
        declaration_type: "started",
        evidence_held: "training-event-attended",
        cpd_lead_provider: cpd_lead_provider1,
        participant_profile: participant_profile1,
        delivery_partner: delivery_partner1,
        cohort: participant_profile1.schedule.cohort,
      )
    end

    context "find participant declaration" do
      it "return one participant declarationsfor" do
        expect(subject.participant_declaration(participant_declaration.id)).to eql(participant_declaration)
      end
    end

    it "does not return npq declaration" do
      expect { subject.participant_declaration(npq_participant_declaration.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "declaration does not exist" do
      it "returns not found error" do
        expect { subject.participant_declaration("XXXX") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when declaration have been transferred to new provider" do
      let(:transfer_induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
          .new(lead_provider_from: lead_provider2, lead_provider_to: lead_provider1)
          .build
      end
      let!(:transferred_declaration) do
        create(
          :ect_participant_declaration,
          :eligible,
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider2,
          participant_profile: transfer_induction_record.participant_profile,
          delivery_partner: delivery_partner1,
          cohort: transfer_induction_record.participant_profile.schedule.cohort,
        )
      end

      it "is included in the response" do
        expect(subject.participant_declaration(transferred_declaration.id)).to eql(transferred_declaration)
      end
    end
  end
end
