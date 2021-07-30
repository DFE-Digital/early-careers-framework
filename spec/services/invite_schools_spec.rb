# frozen_string_literal: true

require "rails_helper"

RSpec.describe InviteSchools do
  subject(:invite_schools) { described_class.new }
  let(:primary_contact_email) { Faker::Internet.email }
  let(:secondary_contact_email) { Faker::Internet.email }
  let!(:cohort) { create(:cohort, :current) }

  let(:school) do
    create(
      :school,
      primary_contact_email: primary_contact_email,
      secondary_contact_email: secondary_contact_email,
    )
  end

  before(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = false
  end

  before(:each) do
    allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { "notify_id" }
  end

  after(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end

  describe "#run" do
    let(:nomination_email) { school.nomination_emails.last }

    it "creates a record for the nomination email" do
      expect {
        invite_schools.run [school.urn]
      }.to change { school.nomination_emails.count }.by 1
    end

    it "creates a nomination email with the correct fields" do
      invite_schools.run [school.urn]
      expect(nomination_email.sent_to).to eq school.primary_contact_email
      expect(nomination_email.sent_at).to be_present
      expect(nomination_email.token).to be_present
    end

    it "sends the nomination email" do
      travel_to Time.utc("2000-1-1")
      expect(SchoolMailer).to receive(:nomination_email).with(
        hash_including(
          school_name: String,
          nomination_url: String,
          recipient: school.primary_contact_email,
          expiry_date: "22/01/2000",
        ),
      ).and_call_original

      invite_schools.run [school.urn]
    end

    it "sets the notify id on the nomination email record" do
      invite_schools.run [school.urn]
      expect(nomination_email.notify_id).to eq "notify_id"
    end

    context "when school primary contact email is empty" do
      let(:primary_contact_email) { "" }

      it "sends the nomination email to the secondary contact" do
        expect(SchoolMailer).to receive(:nomination_email).with(
          hash_including(
            school_name: String,
            nomination_url: String,
            recipient: school.secondary_contact_email,
          ),
        ).and_call_original

        invite_schools.run [school.urn]
      end
    end

    context "when there is an error creating the nomination email" do
      let(:primary_contact_email) { nil }
      let(:secondary_contact_email) { nil }
      let(:another_school) { create(:school) }

      it "skips to the next school_id" do
        invite_schools.run [school.urn, another_school.urn]
        expect(school.nomination_emails).to be_empty
        expect(another_school.nomination_emails).not_to be_empty
      end
    end
  end

  describe "#reached_limit" do
    subject { invite_schools.reached_limit(school) }

    context "when the school has not been emailed yet" do
      it { is_expected.to be_nil }
    end

    context "when the school has been emailed more than 5 minutes ago" do
      before do
        create(:nomination_email, school: school, sent_at: 6.minutes.ago)
      end

      it { is_expected.to be nil }
    end

    context "when the school has been emailed within the last 5 minutes" do
      before do
        create(:nomination_email, school: school, sent_at: 4.minutes.ago)
      end

      it { is_expected.to eq(max: 1, within: 5.minutes) }
    end

    context "when the school has been emailed four times in the last 24 hours" do
      before do
        create_list(:nomination_email, 4, school: school, sent_at: 22.hours.ago)
      end

      it { is_expected.to be nil }
    end

    context "when the school has been emailed five times in the last 24 hours" do
      before do
        create_list(:nomination_email, 4, school: school, sent_at: 22.hours.ago)
        create(:nomination_email, school: school, sent_at: 3.minutes.ago)
      end

      it { is_expected.to eq(max: 5, within: 24.hours) }
    end
  end

  describe "#send_chasers" do
    let!(:cohort) { create(:cohort, :current) }
    it "does not send emails to schools who have nominated tutors" do
      # Given there is a school with an induction coordinator
      create(:user, :induction_coordinator)
      expect(School.count).to eq 1
      expect(School.without_induction_coordinator.count).to eq 0

      expect(an_instance_of(InviteSchools)).not_to delay_execution_of(:create_and_send_nomination_email)
    end

    it "sends emails to all available addresses" do
      school = create(:school, primary_contact_email: "primary@example.com", secondary_contact_email: "secondary@example.com")
      AdditionalSchoolEmail.create!(school: school, email_address: "additional1@example.com")
      AdditionalSchoolEmail.create!(school: school, email_address: "additional2@example.com")

      invite_schools.send_chasers
      expect(an_instance_of(InviteSchools)).to delay_execution_of(:create_and_send_nomination_email).with("primary@example.com", school)
      expect(an_instance_of(InviteSchools)).to delay_execution_of(:create_and_send_nomination_email).with("secondary@example.com", school)
      expect(an_instance_of(InviteSchools)).to delay_execution_of(:create_and_send_nomination_email).with("additional1@example.com", school)
      expect(an_instance_of(InviteSchools)).to delay_execution_of(:create_and_send_nomination_email).with("additional2@example.com", school)
    end

    it "does not send emails to schools that are not eligible" do
      # Given an ineligible school
      create(:school, school_type_code: 56)
      expect(School.count).to eql 1
      expect(School.eligible.count).to eql 0

      expect(an_instance_of(InviteSchools)).not_to delay_execution_of(:create_and_send_nomination_email)
    end
  end

  describe "#invite_to_beta" do
    let!(:cohort) { create(:cohort, :current) }
    let(:induction_coordinator) { create(:user, :induction_coordinator) }
    let(:school) { induction_coordinator.schools.first }

    it "enables the feature flag for the school" do
      expect(FeatureFlag.active?(:induction_tutor_manage_participants, for: school)).to be false

      InviteSchools.new.invite_to_beta([school.urn])
      expect(FeatureFlag.active?(:induction_tutor_manage_participants, for: school)).to be true
    end

    it "emails the induction coordinator" do
      InviteSchools.new.invite_to_beta([school.urn])
      expect(SchoolMailer).to delay_email_delivery_of(:beta_invite_email)
                                .with(hash_including(
                                        recipient: induction_coordinator.email,
                                        name: induction_coordinator.full_name,
                                        school_name: school.name,
                                      ))
    end

    it "does not email the induction coordinator when the school has already been added" do
      FeatureFlag.activate(:induction_tutor_manage_participants, for: school)

      InviteSchools.new.invite_to_beta([school.urn])
      expect(SchoolMailer).not_to delay_email_delivery_of(:beta_invite_email)
    end

    it "does not enable the feature flag when there is no induction coordinator" do
      school = create(:school)
      InviteSchools.new.invite_to_beta([school.urn])
      expect(FeatureFlag.active?(:induction_tutor_manage_participants, for: school)).to be false
    end
  end

  describe "#send_beta_chasers" do
    let(:beta_school_without_participants) { create(:school) }
    let!(:expected_induction_coordinator) { create(:user, :induction_coordinator, school_ids: [beta_school_without_participants.id]) }
    let(:beta_school_with_ect) { create(:school_cohort) }
    let(:beta_school_with_mentor) { create(:school_cohort) }
    let(:non_beta_school) { create(:school_cohort) }
    let!(:unexpected_induction_coordinator) { create(:user, :induction_coordinator, school_ids: [beta_school_with_ect.school.id, beta_school_with_mentor.school.id, non_beta_school.school.id]) }

    before do
      create(:participant_profile, :ect, school_cohort: beta_school_with_ect)
      create(:participant_profile, :mentor, school_cohort: beta_school_with_mentor)
      FeatureFlag.activate(:induction_tutor_manage_participants, for: beta_school_with_ect)
      FeatureFlag.activate(:induction_tutor_manage_participants, for: beta_school_with_mentor)
      FeatureFlag.activate(:induction_tutor_manage_participants, for: beta_school_without_participants)
      create(:participant_profile, :ect, school_cohort: non_beta_school)
    end

    it "sends emails to beta schools without participants" do
      InviteSchools.new.send_beta_chasers
      expect(SchoolMailer).to delay_email_delivery_of(:beta_invite_email)
                                .with(hash_including(
                                        recipient: expected_induction_coordinator.email,
                                        name: expected_induction_coordinator.full_name,
                                        school_name: beta_school_without_participants.name,
                                      ))
    end

    it "does not send emails to other types of school" do
      InviteSchools.new.send_beta_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:beta_invite_email)
                                    .with(hash_including(
                                            recipient: unexpected_induction_coordinator.email,
                                            name: unexpected_induction_coordinator.full_name,
                                          ))
    end
  end

  describe "#invite_mats" do
    context "when the is an induction coordinator" do
      let(:induction_coordinator) { create(:user, :induction_coordinator) }
      let(:school) { induction_coordinator.schools.first }

      it "sends the email to the induction coordinator" do
        expect { InviteSchools.new.invite_mats([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_mat_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: induction_coordinator.email,
            school: school,
          ),
        )
      end
    end

    context "when the school has a primary contact email" do
      let(:primary_email) { "primary@example.com" }
      let(:school) { create(:school, primary_contact_email: primary_email) }

      it "sends an email to the primary contact" do
        expect { InviteSchools.new.invite_mats([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_mat_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: primary_email,
            school: school,
          ),
        )
      end
    end

    context "when the school has a secondary contact email" do
      let(:secondary_email) { "secondary@example.com" }
      let(:school) { create(:school, primary_contact_email: nil, secondary_contact_email: secondary_email) }

      it "sends an email to the secondary contact" do
        expect { InviteSchools.new.invite_mats([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_mat_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: secondary_email,
            school: school,
          ),
        )
      end
    end
  end

  describe "#invite_federations" do
    context "when the is an induction coordinator" do
      let(:induction_coordinator) { create(:user, :induction_coordinator) }
      let(:school) { induction_coordinator.schools.first }

      it "sends the email to the induction coordinator" do
        expect { InviteSchools.new.invite_federations([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_federation_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: induction_coordinator.email,
            school: school,
          ),
        )
      end
    end

    context "when the school has a primary contact email" do
      let(:primary_email) { "primary@example.com" }
      let(:school) { create(:school, primary_contact_email: primary_email) }

      it "sends an email to the primary contact" do
        expect { InviteSchools.new.invite_federations([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_federation_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: primary_email,
            school: school,
          ),
        )
      end
    end

    context "when the school has a secondary contact email" do
      let(:secondary_email) { "secondary@example.com" }
      let(:school) { create(:school, primary_contact_email: nil, secondary_contact_email: secondary_email) }

      it "sends an email to the secondary contact" do
        expect { InviteSchools.new.invite_federations([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_federation_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: secondary_email,
            school: school,
          ),
        )
      end
    end
  end

  describe "#send_induction_coordinator_sign_in_chasers" do
    it "emails induction coordinators yet to sign in" do
      induction_coordinator = create(:user, :induction_coordinator, created_at: 5.days.ago)
      InviteSchools.new.send_induction_coordinator_sign_in_chasers
      expect_sign_in_chaser_email(induction_coordinator)
    end

    it "does not email induction coordinators who were created within the last 2 days" do
      create(:user, :induction_coordinator, created_at: 1.day.ago)
      InviteSchools.new.send_induction_coordinator_sign_in_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_sign_in_chaser_email)
    end

    it "does not email induction coordinators who have signed in" do
      create_signed_in_induction_tutor
      InviteSchools.new.send_induction_coordinator_sign_in_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_sign_in_chaser_email)
    end
  end

  describe "#send_induction_coordinator_choose_route_chasers" do
    it "emails coordinators with a school who has not chosen a route" do
      induction_coordinator = create_signed_in_induction_tutor
      InviteSchools.new.send_induction_coordinator_choose_route_chasers
      expect_choose_route_email(induction_coordinator, induction_coordinator.schools.first)
    end

    it "does not email coordinators who have not signed in" do
      create(:user, :induction_coordinator)
      InviteSchools.new.send_induction_coordinator_choose_route_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_route_email)
    end

    it "does not email coordinators who have chosen routes for all their schools" do
      induction_coordinator = create_signed_in_induction_tutor
      create(:school_cohort, school: induction_coordinator.schools.first, cohort: cohort)
      InviteSchools.new.send_induction_coordinator_choose_route_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_route_email)
    end

    it "uses the name of a school without a route chosen" do
      cip_schools = create_list(:school_cohort, 10).map(&:school)
      target_school = create(:school)
      induction_coordinator = create(:user, :induction_coordinator, school_ids: [target_school.id, *cip_schools.map(&:id)], last_sign_in_at: Time.zone.now, current_sign_in_at: Time.zone.now)
      InviteSchools.new.send_induction_coordinator_choose_route_chasers
      expect_choose_route_email(induction_coordinator, target_school)
    end

    it "sends one email per tutor" do
      schools = create_list(:school, 10)
      create(:user, :induction_coordinator, school_ids: schools.map(&:id), last_sign_in_at: Time.zone.now, current_sign_in_at: Time.zone.now)
      expect { InviteSchools.new.send_induction_coordinator_choose_route_chasers }.to change { Delayed::Job.count }.by(1)
    end
  end

  describe "#send_induction_coordinator_choose_provider_chasers" do
    it "emails coordinators with a school who has not chosen a provider" do
      induction_coordinator = create_signed_in_induction_tutor
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "full_induction_programme", cohort: cohort)
      InviteSchools.new.send_induction_coordinator_choose_provider_chasers
      expect_choose_provider_email(induction_coordinator, induction_coordinator.schools.first)
    end

    it "does not email coordinators who have chosen providers for all their schools" do
      induction_coordinator = create_signed_in_induction_tutor
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "full_induction_programme", cohort: cohort)
      create(:partnership, school: induction_coordinator.schools.first, cohort: cohort)
      InviteSchools.new.send_induction_coordinator_choose_provider_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_provider_email)
    end

    it "does not email coordinators who only have CIP schools" do
      induction_coordinator = create_signed_in_induction_tutor
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "core_induction_programme", cohort: cohort)
      InviteSchools.new.send_induction_coordinator_choose_provider_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_provider_email)
    end

    it "uses the name of a school without a provider chosen" do
      partnered_schools = create_list(
        :school_cohort,
        10,
        induction_programme_choice: "full_induction_programme",
        cohort: cohort,
      ).map(&:school)
      partnered_schools.each { |school| create(:partnership, school: school, cohort: cohort) }
      target_school = create(:school_cohort, induction_programme_choice: "full_induction_programme", cohort: cohort).school
      induction_coordinator = create(:user, :induction_coordinator, school_ids: [target_school.id, *partnered_schools.map(&:id)])
      InviteSchools.new.send_induction_coordinator_choose_provider_chasers
      expect_choose_provider_email(induction_coordinator, target_school)
    end

    it "sends one email per tutor" do
      schools = create_list(:school_cohort,
                            10,
                            induction_programme_choice: "full_induction_programme",
                            cohort: cohort).map(&:school)
      create(:user, :induction_coordinator, school_ids: schools.map(&:id), last_sign_in_at: Time.zone.now, current_sign_in_at: Time.zone.now)
      expect { InviteSchools.new.send_induction_coordinator_choose_provider_chasers }.to change { Delayed::Job.count }.by(1)
    end
  end

  describe "#send_induction_coordinator_choose_materials_chasers" do
    it "emails coordinators with a school who has not chosen materials" do
      induction_coordinator = create(:user, :induction_coordinator)
      create(:school_cohort,
             school: induction_coordinator.schools.first,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil)
      InviteSchools.new.send_induction_coordinator_choose_materials_chasers
      expect_choose_materials_email(induction_coordinator, induction_coordinator.schools.first)
    end

    it "does not email coordinators who have chosen materials for all their schools" do
      induction_coordinator = create(:user, :induction_coordinator)
      create(:school_cohort,
             school: induction_coordinator.schools.first,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: create(:core_induction_programme))
      InviteSchools.new.send_induction_coordinator_choose_materials_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_materials_email)
    end

    it "does not email coordinators who only have FIP schools" do
      induction_coordinator = create_signed_in_induction_tutor
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "full_induction_programme", cohort: cohort)
      InviteSchools.new.send_induction_coordinator_choose_materials_chasers
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_materials_email)
    end

    it "uses the name of a school without materials chosen" do
      chosen_cip_schools = create_list(
        :school_cohort,
        10,
        induction_programme_choice: "core_induction_programme",
        core_induction_programme: create(:core_induction_programme),
        cohort: cohort,
      ).map(&:school)
      target_school = create(:school_cohort, induction_programme_choice: "core_induction_programme", cohort: cohort).school
      induction_coordinator = create(:user, :induction_coordinator, school_ids: [target_school.id, *chosen_cip_schools.map(&:id)])
      InviteSchools.new.send_induction_coordinator_choose_materials_chasers
      expect_choose_materials_email(induction_coordinator, target_school)
    end

    it "sends one email per tutor" do
      schools = create_list(:school_cohort,
                            10,
                            induction_programme_choice: "core_induction_programme",
                            cohort: cohort,
                            core_induction_programme: nil).map(&:school)
      create(:user, :induction_coordinator, school_ids: schools.map(&:id))
      expect { InviteSchools.new.send_induction_coordinator_choose_materials_chasers }.to change { Delayed::Job.count }.by(1)
    end
  end

  describe "#send_induction_coordinator_add_participants_email" do
    it "sends emails to tutors with CIP schools" do
      induction_coordinator = create(:user, :induction_coordinator)
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "core_induction_programme")

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect_send_participants_email(induction_coordinator)
    end

    it "sends emails to tutors with FIP schools" do
      induction_coordinator = create(:user, :induction_coordinator)
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "full_induction_programme")

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect_send_participants_email(induction_coordinator)
    end

    it "does not send emails to tutors who have not chosen routes for their schools" do
      create(:user, :induction_coordinator)

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_add_participants_email)
    end

    it "does not send emails to tutors who have no ECTs" do
      induction_coordinator = create(:user, :induction_coordinator)
      create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "no_early_career_teachers")

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_add_participants_email)
    end

    it "does not send emails to tutors who have opted out in all their schools" do
      induction_coordinator = create(:user, :induction_coordinator)
      create(:school_cohort, school: induction_coordinator.schools.first, opt_out_of_updates: true)

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_add_participants_email)
    end

    it "sends emails to tutors who have not opted out in one of their schools" do
      opted_out_schools = create_list(:school, 10)
      opted_out_schools.each do |school|
        create(:school_cohort, school: school, opt_out_of_updates: true)
      end
      cip_school = create(:school)
      create(:school_cohort, school: cip_school, induction_programme_choice: "core_induction_programme")
      induction_coordinator = create(:user, :induction_coordinator, school_ids: [cip_school.id, *opted_out_schools.map(&:id)])

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect_send_participants_email(induction_coordinator)
    end

    it "does not send emails to tutors who have participants at all of their schools" do
      induction_coordinator = create(:user, :induction_coordinator)
      school_cohort = create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "core_induction_programme")
      create(:participant_profile, :ect, school_cohort: school_cohort)

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect(SchoolMailer).not_to delay_email_delivery_of(:induction_coordinator_add_participants_email)
    end

    it "sends emails to tutors with schools without participants" do
      schools_with_participants = create_list(:school, 10)
      schools_with_participants.each do |school|
        school_cohort = create(:school_cohort, school: school, induction_programme_choice: "core_induction_programme")
        create(:participant_profile, :ect, school_cohort: school_cohort)
      end
      school_without_participants = create(:school)
      create(:school_cohort, school: school_without_participants, induction_programme_choice: "core_induction_programme")
      induction_coordinator = create(:user, :induction_coordinator, school_ids: [school_without_participants.id, *schools_with_participants.map(&:id)])

      InviteSchools.new.send_induction_coordinator_add_participants_email
      expect_send_participants_email(induction_coordinator)
    end

    it "sends one email per tutor" do
      schools = create_list(:school_cohort, 10, induction_programme_choice: "core_induction_programme").map(&:school)
      create(:user, :induction_coordinator, school_ids: schools.map(&:id))

      expect { InviteSchools.new.send_induction_coordinator_add_participants_email }.to change { Delayed::Job.count }.by(1)
    end
  end

  describe "#send_year2020_invite_email" do
    let!(:cohort) { create(:cohort, :current) }
    let!(:induction_coordinator) { create(:user, :induction_coordinator) }
    let!(:school) { induction_coordinator.schools.first }

    it "does not send any email if year_2020_data_entry feature flag is inactive" do
      expect(FeatureFlag.active?(:year_2020_data_entry)).to be false

      InviteSchools.new.send_year2020_invite_email
      expect(SchoolMailer).not_to delay_email_delivery_of(:year2020_invite_email)
    end

    it "emails the induction coordinator" do
      FeatureFlag.activate(:year_2020_data_entry)

      expected_url = "http://www.example.com/schools/#{school.friendly_id}/year-2020/start?utm_campaign=year2020-nqt-invite&utm_medium=email&utm_source=year2020-nqt-invite"
      InviteSchools.new.send_year2020_invite_email
      expect(SchoolMailer).to delay_email_delivery_of(:year2020_invite_email)
                                  .with(hash_including(
                                          recipient: induction_coordinator.email,
                                          start_url: expected_url,
                                        ))
    end
  end

private

  def create_signed_in_induction_tutor
    create(:user, :induction_coordinator, last_sign_in_at: Time.zone.now, current_sign_in_at: Time.zone.now)
  end

  def expect_send_participants_email(induction_coordinator)
    expect_email(:induction_coordinator_add_participants_email, induction_coordinator, sign_in_url: String)
  end

  def expect_choose_materials_email(induction_coordinator, target_school)
    expect_email(
      :induction_coordinator_reminder_to_choose_materials_email,
      induction_coordinator,
      sign_in_url: String,
      school_name: target_school.name,
    )
  end

  def expect_choose_provider_email(induction_coordinator, target_school)
    expect_email(
      :induction_coordinator_reminder_to_choose_provider_email,
      induction_coordinator,
      sign_in_url: String,
      school_name: target_school.name,
    )
  end

  def expect_choose_route_email(induction_coordinator, target_school)
    expect_email(
      :induction_coordinator_reminder_to_choose_route_email,
      induction_coordinator,
      sign_in_url: String,
      school_name: target_school.name,
    )
  end

  def expect_sign_in_chaser_email(induction_coordinator)
    expect_email(:induction_coordinator_sign_in_chaser_email, induction_coordinator, sign_in_url: String)
  end

  def expect_email(method, induction_coordinator, **params)
    expect(SchoolMailer).to delay_email_delivery_of(method)
                              .with(hash_including(
                                      recipient: induction_coordinator.email,
                                      name: induction_coordinator.full_name,
                                      **params,
                                    ))
  end
end
