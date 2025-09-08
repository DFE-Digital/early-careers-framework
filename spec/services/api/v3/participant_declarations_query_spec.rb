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

  let(:delivery_partner1) { create(:delivery_partner) }
  let(:delivery_partner2) { create(:delivery_partner) }
  let(:params) { {} }

  subject { described_class.new(cpd_lead_provider: cpd_lead_provider1, params:) }

  shared_context "declarations transferred to the provider" do
    context "when declarations have been transferred to the provider" do
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

      described_class::RELEVANT_INDUCTION_STATUS.each do |induction_status|
        it "is included in the response when the participant was #{induction_status} for the previous provider" do
          transfer_induction_record.update!(induction_status:)
          expect(subject.participant_declarations_for_pagination.to_a).to include(transferred_declaration)
        end
      end

      (InductionRecord.induction_statuses.keys.excluding("leaving") - described_class::RELEVANT_INDUCTION_STATUS).each do |induction_status|
        it "is not included in the response when the participant was #{induction_status} for the previous provider" do
          transfer_induction_record.update!(induction_status:)
          expect(subject.participant_declarations_for_pagination.to_a).not_to include(transferred_declaration)
        end
      end

      context "when the participant was leaving for the previous provider" do
        it "is included in the response when `end_date` is empty" do
          transfer_induction_record.update!(induction_status: :leaving)
          expect(subject.participant_declarations_for_pagination.to_a).to include(transferred_declaration)
        end

        it "is included in the response when `end_date` is ahead of the declaration date" do
          transfer_induction_record.update!(induction_status: :leaving, end_date: Time.zone.now)
          expect(subject.participant_declarations_for_pagination.to_a).to include(transferred_declaration)
        end

        it "is not included in the response when `end_date` is behind of the declaration date" do
          transfer_induction_record.update!(induction_status: :leaving, end_date: 4.years.ago)
          expect(subject.participant_declarations_for_pagination.to_a).not_to include(transferred_declaration)
        end
      end
    end
  end

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

      include_context "declarations transferred to the provider"
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
  end

  describe "#participant_declaration" do
    let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider, :with_lead_provider) }
    let!(:ect_participant_declaration) do
      create(
        :ect_participant_declaration,
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

    context "declaration does not exist" do
      it "returns not found error" do
        expect { subject.participant_declaration("XXXX") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    include_context "declarations transferred to the provider"
  end
end
