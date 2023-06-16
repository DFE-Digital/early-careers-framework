# frozen_string_literal: true

RSpec.describe Partnerships::Report do
  let(:school) { create :school }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:lead_provider) { create :lead_provider }
  let(:delivery_partner) { create :delivery_partner }

  subject(:service_instance) do
    described_class.new(
      school_id: school.id,
      cohort_id: cohort.id,
      lead_provider_id: lead_provider.id,
      delivery_partner_id: delivery_partner.id,
    )
  end

  subject(:result) { service_instance.call }

  before { freeze_time }

  it "creates a new partnership with expected attributes" do
    expect { result }.to change(Partnership, :count).by 1
    expect(result).to be_an_instance_of(Partnership)

    expect(result).to have_attributes(
      school_id: school.id,
      cohort_id: cohort.id,
      lead_provider_id: lead_provider.id,
      delivery_partner_id: delivery_partner.id,
      pending: false,
      challenge_deadline: described_class::DEFAULT_CHALLENGE_WINDOW.from_now,
    )
  end

  it "schedules partnership notifications" do
    expect { result }.to have_enqueued_job(
      PartnershipNotificationJob,
    ).with(partnership: instance_of(Partnership))
  end

  it "schedules partnership reminder" do
    expect { result }.to have_enqueued_job(
      PartnershipReminderJob,
    ).with(partnership: instance_of(Partnership), report_id: instance_of(String))
      .at(described_class::REMINDER_EMAIL_DELAY.from_now)
  end

  it "produces correct event log" do
    expect(result.event_logs.map(&:event)).to eq %w[reported]
  end

  context "when a FIP induction_programme exists" do
    let(:school_cohort) { create(:school_cohort, :fip, school:, cohort:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership: nil, school_cohort:) }

    before do
      school_cohort.update!(default_induction_programme: induction_programme)
    end

    it "adds the partnership to the induction programme" do
      expect(result).to eq induction_programme.reload.partnership
    end

    context "when the induction_programme already has a partnership" do
      # this partnership will presumably be challenged
      let(:old_partnership) { create(:partnership, :challenged) }
      let(:induction_programme) { create(:induction_programme, :fip, partnership: old_partnership, school_cohort:) }

      before do
        school_cohort.update!(default_induction_programme: induction_programme)
      end

      it "does not change the partnership on the induction programme" do
        expect(induction_programme.reload.partnership).to eq old_partnership
      end
    end
  end

  context "when a non-FIP induction_programme exists" do
    let(:school_cohort) { create(:school_cohort, :cip, school:, cohort:) }
    let(:induction_programme) { create(:induction_programme, :cip, partnership: nil, school_cohort:) }

    before do
      school_cohort.update!(default_induction_programme: induction_programme)
    end

    it "adds a new induction programme" do
      expect { result }.to change { school_cohort.induction_programmes.count }.by(1)
    end

    it "sets the school cohort choice to FIP" do
      result
      expect(school_cohort.reload).to be_full_induction_programme
    end

    it "sets the new induction programme as the default" do
      result
      expect(school_cohort.reload.default_induction_programme).to be_full_induction_programme
    end

    it "adds the partnership to the new induction programme" do
      expect(result).to eq school_cohort.reload.default_induction_programme.partnership
    end
  end

  context "with previous, challenged partnership between school and provider for the same cohort" do
    let!(:partnership) do
      create :partnership, :challenged, lead_provider:, school:, cohort:
    end

    it "does not create new partnership" do
      expect { result }.not_to change(Partnership, :count)
    end

    it "returns the original partnership record" do
      expect(result).to eq partnership
    end

    it "updates the existing partnership" do
      result

      expect(partnership.reload).to have_attributes(
        school_id: school.id,
        cohort_id: cohort.id,
        lead_provider_id: lead_provider.id,
        delivery_partner_id: delivery_partner.id,
        pending: false,
        challenge_deadline: described_class::DEFAULT_CHALLENGE_WINDOW.from_now,
      )
    end

    it "updates partnership's report_id" do
      expect { result }.to change { partnership.reload.report_id }
    end
  end

  context "when given school has no matching school cohort record" do
    it "creates that cohort" do
      expect { result }.to change { school.school_cohorts.count }.by 1
    end
  end

  context "when given school already has a matching school cohort record" do
    before do
      create :school_cohort, school:, cohort:
    end

    it "does not create a school cohort" do
      expect { result }.not_to change { school.school_cohorts.count }
    end
  end

  context "challenge deadline to 31st October from 2023" do
    let(:cohort) { create(:cohort, start_year: 2023) }

    it "sets the challenge deadline to 31st October when the partnership is created before the 17th October", travel_to: Date.new(2023, 5, 1) do
      expect(result.challenge_deadline).to eq(Date.new(2023, 10, 31))
    end

    it "sets the challenge deadline to two weeks when the partnership is created from the 17th October", travel_to: Date.new(2023, 10, 25) do
      expect(result.challenge_deadline).to eq(Date.new(2023, 11, 8))
    end
  end

  context "challenge deadline to 31st October until 2022" do
    let(:cohort) { create(:cohort, start_year: 2022) }

    it "sets the challenge deadline to two weeks when the partnership is created from the 17th October", travel_to: Date.new(2023, 5, 1) do
      expect(result.challenge_deadline).to eq(Date.new(2023, 5, 15))
    end
  end
end
