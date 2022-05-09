# frozen_string_literal: true

RSpec.describe "Schools::Participants", type: :request, js: true, with_feature_flags: { eligibility_notifications: "active" } do
  let(:user) { create(:user, :induction_coordinator, school_ids: [school.id]) }
  let(:school) { school_cohort.school }
  let(:cohort) { create(:cohort) }

  let!(:school_cohort) { create(:school_cohort, cohort: cohort, induction_programme_choice: "full_induction_programme") }
  let!(:another_cohort) { create(:school_cohort) }
  let(:mentor_profile) { create(:mentor_participant_profile, school_cohort: school_cohort) }
  let!(:mentor_user) { mentor_profile.user }
  let!(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort: school_cohort) }
  let!(:mentor_user_2) { mentor_profile_2.user }
  let(:ect_profile) { create(:ect_participant_profile, mentor_profile: mentor_user.mentor_profile, school_cohort: school_cohort) }
  let!(:ect_user) { ect_profile.user }
  let!(:withdrawn_ect) { create(:ect_participant_profile, :withdrawn_record, school_cohort: school_cohort).user }
  let!(:unrelated_mentor_profile) { create(:mentor_participant_profile, school_cohort: another_cohort) }
  let!(:unrelated_mentor) { unrelated_mentor_profile.user }
  let!(:unrelated_ect) { create(:ect_participant_profile, school_cohort: another_cohort).user }
  let!(:delivery_partner) { create(:delivery_partner, name: "Delivery Partner") }
  let!(:lead_provider) { create(:lead_provider, name: "Lead Provider", cohorts: [cohort]) }
  let!(:partnership) { create(:partnership, school: school, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: cohort) }

  before do
    Induction::SetCohortInductionProgramme.call(school_cohort: school_cohort,
                                                programme_choice: "full_induction_programme")
    programme = school_cohort.default_induction_programme
    [mentor_profile, ect_profile, mentor_profile_2].each do |profile|
      Induction::Enrol.call(participant_profile: profile, induction_programme: programme)
    end

    ect_profile.current_induction_record.update!(mentor_profile: mentor_profile)
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants" do
    context "when feature flag is turned off" do
      it "shouldn't be available" do
        expect {
          get "/schools/cohorts/#{cohort.start_year}/participants"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    it "renders participants template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response).to render_template("schools/participants/index")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_ect.full_name))
    end

    it "renders participant details when they have been withdrawn by the provider" do
      ect_profile.training_status_withdrawn!
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response).to render_template("schools/participants/index")
      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
      expect(response.body).to include(CGI.escapeHTML(lead_provider.name))
    end

    it "does not list participants with withdrawn profile records" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response.body).not_to include(CGI.escapeHTML(withdrawn_ect.full_name))
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id" do
    it "renders participant template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"

      expect(response).to render_template("schools/participants/show")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end

    context "when the participant is an ECT" do
      before do
        ect_profile.current_induction_record.update!(mentor_profile: mentor_profile_2)
      end

      it "uses the mentor from the induction record" do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"
        expect(assigns(:mentor)).to eq mentor_user_2
      end

      context "when multiple cohorts are active", with_feature_flags: { multiple_cohorts: "active" } do
        context "when there are mentors in the pool" do
          let!(:school_mentors) { [mentor_profile, mentor_profile_2, unrelated_mentor_profile] }
          before do
            school_mentors.each do |profile|
              Mentors::AddToSchool.call(school: school, mentor_profile: profile)
            end
          end

          it "mentors_added is true" do
            get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"
            expect(assigns(:mentors_added)).to be true
          end
        end

        context "when there are no mentors in the pool" do
          it "mentors_added is false" do
            get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"
            expect(assigns(:mentors_added)).to be false
          end
        end
      end
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-mentor" do
    it "renders edit mentor template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-mentor"

      expect(response).to render_template("schools/participants/edit_mentor")
    end

    it "renders correct mentors" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-mentor"

      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-mentor" do
    it "updates mentor" do
      params = { participant_mentor_form: { mentor_id: mentor_user_2.id } }
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-mentor", params: params

      expect(response).to redirect_to(schools_participant_path(id: ect_profile))
      expect(flash[:success][:title]).to eq("Success")
      expect(ect_user.reload.early_career_teacher_profile.mentor).to eq(mentor_user_2)
    end

    it "shows error when a blank form is submitted" do
      ect_profile = create(:ect_participant_profile, school_cohort: school_cohort)
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-mentor"
      expect(response).to render_template("schools/participants/edit_mentor")
      expect(response.body).to include "Choose a mentor"
    end

    it "updates analytics" do
      params = { participant_mentor_form: { mentor_id: mentor_user_2.id } }
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-mentor", params: params
      }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob).with(participant_profile: ect_profile)
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-name" do
    it "renders the edit name template with the correct name for an ECT" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-name"

      expect(response).to render_template("schools/participants/edit_name")
      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
    end

    it "renders the edit name template with the correct name for a mentor" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/edit-name"

      expect(response).to render_template("schools/participants/edit_name")
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-name" do
    it "updates the name of an ECT" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-name", params: {
          user: { full_name: "Joe Bloggs" },
        }
      }.to change { ect_user.reload.full_name }.to("Joe Bloggs")
    end

    it "updates the name of a mentor" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-name", params: {
          user: { full_name: "Sally Mentor" },
        }
      }.to change { mentor_user.reload.full_name }.to("Sally Mentor")
    end

    it "rejects a blank name" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-name", params: {
          user: { full_name: "" },
        }
      }.not_to change { mentor_user.reload.full_name }

      expect(response).to render_template("schools/participants/edit_name")
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-email" do
    it "renders the edit email template with the correct name for an ECT" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-email"

      expect(response).to render_template("schools/participants/edit_email")
      expect(response.body).to include(CGI.escapeHTML(ect_user.email))
    end

    it "renders the edit email template with the correct name for a mentor" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/edit-email"

      expect(response).to render_template("schools/participants/edit_email")
      expect(response.body).to include(CGI.escapeHTML(mentor_user.email))
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-email" do
    it "updates the email of an ECT" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-email", params: {
          user: { email: "new@email.com" },
        }
      }.to change { ect_user.reload.email }.to("new@email.com")
    end

    it "updates the email of a mentor" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: "new@email.com" },
        }
      }.to change { mentor_user.reload.email }.to("new@email.com")
    end

    it "rejects a blank email" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: "" },
        }
      }.not_to change { mentor_user.reload.email }
      expect(response).to render_template("schools/participants/edit_email")
    end

    it "rejects a malformed email" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: "nonsense" },
        }
      }.not_to change { mentor_user.reload.email }
      expect(response).to render_template("schools/participants/edit_email")
    end

    it "rejects an email in use by another user" do
      other_user = create(:user)
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: other_user.email },
        }
      }.not_to change { mentor_user.reload.email }
      expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/email-used")
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/email-used" do
    it "renders the email used in same school template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/email-used"

      expect(response).to render_template("schools/participants/email_used")
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-term" do
    it "renders the edit term template with the correct term for an ECT" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-start-term"

      expect(response).to render_template("schools/participants/edit_start_term")
      cohort.start_term_options.each do |option|
        expect(response.body).to include(CGI.escapeHTML(option.humanize))
      end
    end

    it "updates the term of a participant" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-start-term", params: {
          participant_start_term_form: { start_term: "summer_2022" },
        }
      }.to change { ect_profile.reload.start_term.humanize }.to("Summer 2022")
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-name" do
    it "updates the name of an ECT" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-name", params: {
          user: { full_name: "Joe Bloggs" },
        }
      }.to change { ect_user.reload.full_name }.to("Joe Bloggs")
    end

    it "updates the name of a mentor" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-name", params: {
          user: { full_name: "Sally Mentor" },
        }
      }.to change { mentor_user.reload.full_name }.to("Sally Mentor")
    end
  end

  describe "DELETE /schools/:school_id/cohorts/:start_year/participants/:id" do
    it "marks the participant as withdrawn" do
      expect { delete "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}" }
        .to change { ect_profile.reload.withdrawn_record? }.from(false).to true
    end

    context "when participant has already received request for details email" do
      before do
        ect_profile.update_column(:request_for_details_sent_at, rand(0..100).days.ago)
      end

      it "queues 'participant deleted' email" do
        expect {
          delete "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"
        }.to have_enqueued_mail(ParticipantMailer, :participant_removed_by_sti)
          .with(
            participant_profile: ect_profile,
            sti_profile: user.induction_coordinator_profile,
          )
      end
    end

    context "when participant has not yet received request for details email" do
      it "does not queue 'participant deleted' email" do
        expect {
          delete "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"
        }.to_not have_enqueued_mail(ParticipantMailer, :participant_removed_by_sti)
      end
    end
  end
end
