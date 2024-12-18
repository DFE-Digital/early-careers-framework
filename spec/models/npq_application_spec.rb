# frozen_string_literal: true

RSpec.describe NPQApplication, type: :model do
  it {
    is_expected.to define_enum_for(:headteacher_status).with_values(
      no: "no",
      yes_when_course_starts: "yes_when_course_starts",
      yes_in_first_two_years: "yes_in_first_two_years",
      yes_over_two_years: "yes_over_two_years",
      yes_in_first_five_years: "yes_in_first_five_years",
      yes_over_five_years: "yes_over_five_years",
    ).backed_by_column_of_type(:text)
  }

  describe "#latest_completed_participant_declaration" do
    context "when participant_declaration not exist" do
      let(:npq_application) { create(:npq_application) }

      it "returns nil" do
        result = npq_application.latest_completed_participant_declaration
        expect(result).to eq(nil)
      end
    end
  end

  describe "Change logs for NPQ applications" do
    before do
      PaperTrail.config.enabled = true
    end

    after do
      PaperTrail.config.enabled = false
    end

    describe "#change_log" do
      subject do
        create :npq_application, eligible_for_funding: false, funding_eligiblity_status_code: "marked_ineligible_by_policy", works_in_school: true
      end

      it "returns a list of changes for `eligible_for_funding`" do
        expect { subject.update!(eligible_for_funding: true) }
          .to change { subject.change_logs.count }.by(1)
      end

      it "returns a list of changes for `funding_eligiblity_status_code`" do
        expect { subject.update!(funding_eligiblity_status_code: "re_register") }
          .to change { subject.change_logs.count }.by(1)
      end

      it "returns an empty list if any of the attributes is changed" do
        expect { subject.update!(works_in_school: false) }
          .to change { subject.change_logs.count }.by(0)
      end

      it "returns a list of changes grouped" do
        expect { subject.update!(eligible_for_funding: true, funding_eligiblity_status_code: "re_register") }
          .to change { subject.change_logs.count }.by(1)
      end

      it "sorts the changes by created_at" do
        subject.update!(eligible_for_funding: true, funding_eligiblity_status_code: "re_register")
        subject.update!(eligible_for_funding: false, funding_eligiblity_status_code: "marked_ineligible_by_policy")
        subject.update!(eligible_for_funding: true)
        subject.update!(eligible_for_funding: false)

        change_logs = subject.change_logs
        created_ats = change_logs.map(&:created_at)

        expect(created_ats).to eq(created_ats.sort.reverse)
      end

      it "return a list of Version objects" do
        subject.update!(eligible_for_funding: true, funding_eligiblity_status_code: "re_register")

        expect(subject.change_logs).to all(satisfy { |change_log| change_log.is_a?(PaperTrail::Version) })
      end
    end

    describe "changelog configuration via Papertrail" do
      subject do
        create(:npq_application, works_in_school: true)
      end

      it "does not create an entry if attribute is not changed" do
        expect { subject.update!(works_in_school: false) }
          .to_not change { subject.versions.where_attribute_changes("eligible_for_funding").count }
      end

      context "with changes on eligible_for_funding" do
        before do
          subject.update! eligible_for_funding: true
        end

        it "creates an entry if attribute is changed" do
          expect { subject.update!(eligible_for_funding: false) }
            .to change { subject.versions.where_attribute_changes("eligible_for_funding").count }.by(1)
        end

        it "does not create an entry if attribute is the same" do
          expect { subject.update!(eligible_for_funding: true) }
            .to_not change { subject.versions.where_attribute_changes("eligible_for_funding").count }
        end
      end

      context "with changes on funding_eligiblity_status_code" do
        before do
          subject.update! funding_eligiblity_status_code: "marked_ineligible_by_policy"
        end

        it "creates an entry if attribute is changed" do
          expect { subject.update!(funding_eligiblity_status_code: "re_register") }
            .to change { subject.versions.where_attribute_changes("funding_eligiblity_status_code").count }.by(1)
        end

        it "does not create an entry if attribute is the same" do
          expect { subject.update!(funding_eligiblity_status_code: "marked_ineligible_by_policy") }
            .to_not change { subject.versions.where_attribute_changes("funding_eligiblity_status_code").count }
        end
      end
    end
  end
end
