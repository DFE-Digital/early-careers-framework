# frozen_string_literal: true

RSpec.describe "Schools::Participants", type: :request, js: true, with_feature_flags: { eligibility_notifications: "active" }, early_in_cohort: true do
  let(:user) { create(:user, :induction_coordinator, school_ids: [school.id]) }
  let!(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Lead Provider").lead_provider }

  let(:school) { school_cohort.school }
  let(:cohort) { Cohort.current }

  let!(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, cohort:, lead_provider:) }
  let!(:another_cohort) { create(:school_cohort) }

  let(:mentor_profile) { create(:mentor, school_cohort:, lead_provider:) }
  let!(:mentor_user) { mentor_profile.user }

  let!(:mentor_profile_2) { create(:mentor, school_cohort:, lead_provider:) }
  let!(:mentor_user_2) { mentor_profile_2.user }

  let(:ect_profile) { create(:ect, mentor_profile_id: mentor_profile.id, school_cohort:, lead_provider:) }
  let!(:ect_user) { ect_profile.user }
  let!(:withdrawn_ect) { create(:ect, :withdrawn_record, school_cohort:, lead_provider:).user }

  let!(:unrelated_mentor_profile) { create(:mentor, school_cohort: another_cohort, lead_provider:) }
  let!(:unrelated_mentor) { unrelated_mentor_profile.user }

  let!(:unrelated_ect) { create(:ect, school_cohort: another_cohort, lead_provider:).user }
  let!(:delivery_partner) { create(:delivery_partner, name: "Delivery Partner") }
  let(:deliver_partner) { school.deliver_partner_for(cohort.start_year) }

  before do
    sign_in user
  end

  describe "GET /schools/:school_id/participants/:id/new-ect" do
    let!(:new_ect) { create(:ect, school_cohort:, lead_provider:) }

    it "renders new ect template" do
      get "/schools/#{school.slug}/participants/#{mentor_profile.id}/new-ect"

      expect(response).to render_template("schools/participants/new_ect")
    end

    it "renders the correct ects" do
      get "/schools/#{school.slug}/participants/#{mentor_profile.id}/new-ect"

      expect(response.body).to include(CGI.escapeHTML(new_ect.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(withdrawn_ect.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(ect_profile.full_name))
    end
  end

  describe "PUT /schools/:school_id/participants/:id/add-ect" do
    let!(:new_ect) { create(:ect, school_cohort:, lead_provider:) }

    it "adds the ect to the mentor" do
      params = { induction_record_id: new_ect.latest_induction_record.id }

      put("/schools/#{school.slug}/participants/#{mentor_profile.id}/add-ect", params:)

      expect(response).to redirect_to school_mentor_path(id: mentor_profile.id, school_id: school.slug)
      expect(new_ect.reload.mentor).to eq(mentor_user)
    end

    it "back to choose ect when no one is submitted" do
      put "/schools/#{school.slug}/participants/#{mentor_profile.id}/add-ect"

      expect(response).to render_template("schools/participants/new_ect")
    end

    it "updates analytics" do
      params = { induction_record_id: new_ect.latest_induction_record.id }

      expect {
        put "/schools/#{school.slug}/participants/#{mentor_profile.id}/add-ect", params:
      }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob).with(participant_profile_id: new_ect.id)
    end
  end

  describe "GET /schools/:school_id/participants/:id/edit-mentor" do
    it "renders edit mentor template" do
      get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-mentor"

      expect(response).to render_template("schools/participants/edit_mentor")
    end

    it "renders correct mentors" do
      get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-mentor"

      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
    end
  end

  describe "PUT /schools/:school_id/participants/:id/update-mentor" do
    it "updates mentor" do
      params = { participant_mentor_form: { mentor_id: mentor_user_2.id } }
      put("/schools/#{school.slug}/participants/#{ect_profile.id}/update-mentor", params:)

      expect(response).to redirect_to school_early_career_teacher_path(id: ect_profile.id, school_id: school.slug)
      expect(ect_user.reload.early_career_teacher_profile.mentor).to eq(mentor_user_2)
    end

    it "shows error when a blank form is submitted" do
      ect_profile = create(:ect, school_cohort:)
      put "/schools/#{school.slug}/participants/#{ect_profile.id}/update-mentor"
      expect(response).to render_template("schools/participants/edit_mentor")
      expect(response.body).to include "Choose a mentor"
    end

    it "updates analytics" do
      params = { participant_mentor_form: { mentor_id: mentor_user_2.id } }
      expect {
        put "/schools/#{school.slug}/participants/#{ect_profile.id}/update-mentor", params:
      }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob).with(participant_profile_id: ect_profile.id)
    end
  end

  describe "GET /schools/:school_id/participants/:id/edit-name" do
    context "when the participant is in contacted for info status" do
      it "don't allow the edition of the name of an ECT" do
        expect {
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-name"
        }.to raise_exception(Pundit::NotAuthorizedError)
      end

      it "don't allow the edition of the name of a mentor" do
        expect {
          get "/schools/#{school.slug}/participants/#{mentor_profile.id}/edit-name"
        }.to raise_exception(Pundit::NotAuthorizedError)
      end
    end

    context "when the participant is not in contacted for info status" do
      before do
        create(:ecf_participant_validation_data, participant_profile: ect_profile)
        create(:ecf_participant_validation_data, participant_profile: mentor_profile)
      end

      context "when no reason to change the name is included in the request" do
        it "renders the reason_to_edit_name template to ask for a reason to edit the participant's name" do
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-name"

          expect(response).to render_template("schools/participants/reason_to_edit_name")
          expect(response.body).to include(CGI.escapeHTML(ect_profile.full_name))
        end
      end

      context "when unknown reason to change the name is included in the request" do
        it "renders the reason_to_edit_name template to ask for a reason to edit the participant's name" do
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-name",
              params: { reason: "any_unknown_reason" }

          expect(response).to render_template("schools/participants/reason_to_edit_name")
          expect(response.body).to include(CGI.escapeHTML(ect_profile.full_name))
        end
      end

      context "when the participant's name has changed in real life for any reason" do
        it "renders the edit name template with the current name of the participant" do
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-name",
              params: { reason: "name_has_changed" }

          expect(response).to render_template("schools/participants/edit_name")
          expect(response.body).to include(CGI.escapeHTML(ect_profile.full_name))
        end
      end

      context "when the current participant's name is incorrect" do
        it "renders the edit name template with the current name of the participant" do
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-name",
              params: { reason: "name_is_incorrect" }

          expect(response).to render_template("schools/participants/edit_name")
          expect(response.body).to include(CGI.escapeHTML(ect_profile.full_name))
        end
      end

      context "when a participant should not have been registered" do
        it "renders the should not have been registered template with the current name of the participant" do
          get "/schools/#{school.slug}/participants/#{mentor_profile.id}/edit-name",
              params: { reason: "should_not_have_been_registered" }

          expect(response).to render_template("schools/participants/should_not_have_been_registered")
          expect(response.body).to include(CGI.escapeHTML(mentor_profile.full_name))
        end
      end

      context "when an ect needs to be replaced with a different person" do
        it "renders the replace with a different person template with the current name of the ect" do
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-name",
              params: { reason: "replace_with_a_different_person" }

          expect(response).to render_template("schools/participants/replace_with_a_different_person")
          expect(response.body).to include(CGI.escapeHTML(ect_profile.full_name))
          expect(response.body).to include(CGI.escapeHTML("Add the other ECT to this service"))
        end
      end

      context "when a mentor needs to be replaced with a different person" do
        it "renders the replace with a different person template with the current name of the mentor" do
          get "/schools/#{school.slug}/participants/#{mentor_profile.id}/edit-name",
              params: { reason: "replace_with_a_different_person" }

          expect(response).to render_template("schools/participants/replace_with_a_different_person")
          expect(response.body).to include(CGI.escapeHTML(mentor_profile.full_name))
          expect(response.body).to include(CGI.escapeHTML("Add the other mentor to this service"))
        end
      end
    end
  end

  describe "PUT /schools/:school_id/participants/:id/update-name" do
    context "when the participant is not in contacted for info status" do
      before do
        create(:ecf_participant_validation_data, participant_profile: ect_profile)
        create(:ecf_participant_validation_data, participant_profile: mentor_profile)
      end

      it "renders the update name template with the new name of an ect" do
        put "/schools/#{school.slug}/participants/#{ect_profile.id}/update-name",
            params: { full_name: "Joe Bloggs" }

        expect(response).to render_template("schools/participants/update_name")
        expect(response.body).to include(CGI.escapeHTML("#{ect_profile.full_name}’s name has been edited to Joe Bloggs"))
        expect(ect_profile.reload.full_name).to eq("Joe Bloggs")
      end

      it "renders the update name template with the new name of a mentor" do
        put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-name",
            params: { full_name: "Sally Mentor" }

        expect(response).to render_template("schools/participants/update_name")
        expect(response.body).to include(CGI.escapeHTML("#{mentor_profile.full_name}’s name has been edited to Sally Mentor"))
        expect(mentor_profile.reload.full_name).to eq("Sally Mentor")
      end

      it "rejects a blank name" do
        expect {
          put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-name",
              params: { full_name: "" }
        }.not_to change { mentor_user.reload.full_name }

        expect(response).to render_template("schools/participants/edit_name")
      end
    end

    context "when the participant is in contacted for info status" do
      it "don't allow a SIT to update the name of an ect" do
        expect {
          put "/schools/#{school.slug}/participants/#{ect_profile.id}/update-name",
              params: { full_name: "Joe Bloggs" }
        }.to raise_exception(Pundit::NotAuthorizedError)
      end

      it "don't allow a SIT to update the name of a mentor" do
        expect {
          put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-name",
              params: { full_name: "Sally Mentor" }
        }.to raise_exception(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /schools/:school_id/participants/:id/edit-email" do
    context "when the participant is not in contacted for info status" do
      it "renders the edit email template with the correct name for an ECT" do
        create(:ecf_participant_validation_data, participant_profile: ect_profile)

        get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-email"

        expect(response).to render_template("schools/participants/edit_email")
        expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      end

      it "renders the edit email template with the correct name for a mentor" do
        create(:ecf_participant_validation_data, participant_profile: mentor_profile)

        get "/schools/#{school.slug}/participants/#{mentor_profile.id}/edit-email"

        expect(response).to render_template("schools/participants/edit_email")
        expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      end
    end

    context "when the participant is in contacted for info status" do
      it "don't allow the edition of the email of an ECT" do
        expect {
          get "/schools/#{school.slug}/participants/#{ect_profile.id}/edit-email"
        }.to raise_exception(Pundit::NotAuthorizedError)
      end

      it "don't allow the edition of the email of a mentor" do
        expect {
          get "/schools/#{school.slug}/participants/#{mentor_profile.id}/edit-email"
        }.to raise_exception(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PUT /schools/:school_id/participants/:id/update-email" do
    context "when the participant is not in contacted for info status" do
      before do
        create(:ecf_participant_validation_data, participant_profile: ect_profile)
        create(:ecf_participant_validation_data, participant_profile: mentor_profile)
      end

      it "updates the email of an ECT" do
        put "/schools/#{school.slug}/participants/#{ect_profile.id}/update-email",
            params: { email: "new@email.com" }

        expect(response).to render_template("schools/participants/update_email")
        expect(response.body).to include(CGI.escapeHTML("#{ect_profile.full_name}’s email address has been updated"))
        expect(ect_profile.current_induction_record.preferred_identity.email).to eq("new@email.com")
      end

      it "updates the email of a mentor" do
        put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-email",
            params: { email: "new@email.com" }

        expect(response).to render_template("schools/participants/update_email")
        expect(response.body).to include(CGI.escapeHTML("#{mentor_profile.full_name}’s email address has been updated"))
        expect(mentor_profile.current_induction_record.preferred_identity.email).to eq("new@email.com")
      end

      it "rejects a blank email" do
        expect {
          put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-email",
              params: { email: "" }
        }.not_to change { mentor_profile.current_induction_record.preferred_identity.email }

        expect(response).to render_template("schools/participants/edit_email")
      end

      it "rejects a malformed email" do
        expect {
          put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-email",
              params: { email: "nonsense" }
        }.not_to change { mentor_profile.current_induction_record.preferred_identity.email }

        expect(response).to render_template("schools/participants/edit_email")
      end

      it "rejects an email in use by another user" do
        other_user = create(:user)
        expect {
          put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-email",
              params: { email: other_user.email }
        }.not_to change { mentor_profile.current_induction_record.preferred_identity.email }

        expect(response).to redirect_to("/schools/#{school.slug}/participants/#{mentor_profile.id}/email-used")
      end
    end

    context "when the participant is in contacted for info status" do
      it "don't allow a SIT to update the email of an ect" do
        expect {
          put "/schools/#{school.slug}/participants/#{ect_profile.id}/update-email",
              params: { email: "new@email.com" }
        }.to raise_exception(Pundit::NotAuthorizedError)
      end

      it "don't allow a SIT to update the email of a mentor" do
        expect {
          put "/schools/#{school.slug}/participants/#{mentor_profile.id}/update-email",
              params: { email: "new@email.com" }
        }.to raise_exception(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /schools/:school_id/participants/:id/email-used" do
    it "renders the email used in same school template" do
      get "/schools/#{school.slug}/participants/#{ect_profile.id}/email-used"

      expect(response).to render_template("schools/participants/email_used")
    end
  end

  describe "DELETE /schools/:school_id/participants/:id" do
    it "marks the participant as withdrawn" do
      expect { delete "/schools/#{school.slug}/participants/#{ect_profile.id}" }
        .to change { ect_profile.reload.withdrawn_record? }.from(false).to true
    end

    context "when the SIT's name is provided" do
      it "queues 'participant deleted' email" do
        expect {
          delete "/schools/#{school.slug}/participants/#{ect_profile.id}"
        }.to have_enqueued_mail(ParticipantMailer, :participant_removed_by_sit)
          .with(
            params: {
              participant_profile: ect_profile,
              sit_name: user.full_name,
            },
            args: [],
          )
      end
    end
  end
end
