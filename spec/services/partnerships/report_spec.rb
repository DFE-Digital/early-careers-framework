# frozen_string_literal: true

RSpec.describe Partnerships::Report do
  let(:school) { create :school }
  let(:cohort) { create :cohort }
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
      challenge_deadline: described_class::CHALLENGE_WINDOW.from_now,
    )
  end

  it "schedules partnership notifications" do
    result

    expect(an_instance_of(PartnershipNotificationService))
      .to delay_execution_of(:notify).with(result)
  end

  it "schedules partnership reminder" do
    freeze_time
    result

    expect(PartnershipReminderJob)
      .to be_enqueued.with(partnership: result, report_id: result.report_id)
      .at(described_class::REMINDER_EMAIL_DELAY.from_now)
  end

  it "does not schedule activation job" do
    expect(an_instance_of(PartnershipActivationJob)).not_to delay_execution_of(:perform)
  end

  it "produces correct event log" do
    expect(result.event_logs.map(&:event)).to eq %w[reported]
  end

  context "with previous, challanged partnership between school and provider for the same cohort" do
    let!(:partnership) do
      create :partnership, :challenged, lead_provider: lead_provider, school: school, cohort: cohort
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
        challenge_deadline: described_class::CHALLENGE_WINDOW.from_now,
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
      create :school_cohort, school: school, cohort: cohort
    end

    it "creates that cohort" do
      expect { result }.not_to change { school.school_cohorts.count }
    end
  end

  context "when the school has already signed up for CIP" do
    before do
      create(:school_cohort,
             school: school,
             cohort: cohort,
             induction_programme_choice: "core_induction_programme")
    end

    it "marks partnership as pending" do
      expect(result).to be_pending
    end

    it "schedules an activation job" do
      result

      expect(an_instance_of(PartnershipActivationJob)).to delay_execution_of(:perform)
        .with(partnership: result, report_id: result.report_id)
    end
  end
end
