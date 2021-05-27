# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConfirmSchoolsForm, type: :model do
  describe "save!" do
    let(:lead_provider) { create(:lead_provider) }
    let(:delivery_partner) { create(:delivery_partner) }
    let(:cohort) { create(:cohort, :current) }
    let(:form) do
      ConfirmSchoolsForm.new(
        lead_provider_id: lead_provider.id,
        delivery_partner_id: delivery_partner.id,
        school_ids: schools.map(&:id),
        cohort_id: cohort.id,
      )
    end

    context "when the school has not chosen provision" do
      let(:schools) { [create(:school)] }

      it "creates a partnership for the school" do
        expect(PartnershipNotificationService).to receive(:schedule_notifications)
                                                    .with(an_object_having_attributes(
                                                            class: Partnership,
                                                            cohort_id: cohort.id,
                                                            school_id: schools.first.id,
                                                            lead_provider_id: lead_provider.id,
                                                            delivery_partner_id: delivery_partner.id,
                                                          ))
        expect { form.save! }.to change { Partnership.count }.by(1)
        created_partnership = Partnership.order(:created_at).last
        expect(created_partnership.school).to eql schools.first
      end

      it "creates a school cohort with FIP" do
        expect { form.save! }.to change { SchoolCohort.count }.by(1)
        created_school_cohort = SchoolCohort.order(:created_at).last
        expect(created_school_cohort.school).to eql schools.first
        expect(created_school_cohort.induction_programme_choice).to eql "full_induction_programme"
      end
    end

    context "when the school has chosen FIP" do
      let!(:school_cohort) { create(:school_cohort, cohort: cohort, induction_programme_choice: "full_induction_programme") }
      let(:schools) { [school_cohort.school] }

      it "creates a (not pending) partnership for the school" do
        expect(PartnershipNotificationService).to receive(:schedule_notifications)
                                                    .with(an_object_having_attributes(
                                                            class: Partnership,
                                                            cohort_id: cohort.id,
                                                            school_id: schools.first.id,
                                                            lead_provider_id: lead_provider.id,
                                                            delivery_partner_id: delivery_partner.id,
                                                          ))
        expect { form.save! }.to change { Partnership.count }.by(1)
        created_partnership = Partnership.order(:created_at).last
        expect(created_partnership.school).to eql schools.first
        expect(created_partnership.pending).to eql false
      end

      it "does not create a school cohort" do
        expect { form.save! }.not_to(change { SchoolCohort.count })
      end
    end

    context "when the school has chosen CIP" do
      let!(:school_cohort) { create(:school_cohort, cohort: cohort, induction_programme_choice: "core_induction_programme") }
      let(:schools) { [school_cohort.school] }

      it "creates a pending partnership for the school" do
        expect(PartnershipNotificationService).to receive(:schedule_notifications)
                                                    .with(an_object_having_attributes(
                                                            class: Partnership,
                                                            cohort_id: cohort.id,
                                                            school_id: schools.first.id,
                                                            lead_provider_id: lead_provider.id,
                                                            delivery_partner_id: delivery_partner.id,
                                                          ))
        expect { form.save! }.to change { Partnership.count }.by(1)
        created_partnership_request = Partnership.order(:created_at).last
        expect(created_partnership_request.school).to eql schools.first
        expect(created_partnership_request.pending).to eql true
      end

      it "does not create a school cohort" do
        expect { form.save! }.not_to(change { SchoolCohort.count })
      end
    end
  end
end
