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
      expect { invite_schools.run [school.urn] }
        .to change { school.nomination_emails.count }.by 1
    end

    it "creates a nomination email with the correct fields" do
      invite_schools.run [school.urn]
      expect(nomination_email.sent_to).to eq school.primary_contact_email
      expect(nomination_email.sent_at).to be_present
      expect(nomination_email.token).to be_present
    end

    it "sends the nomination email" do
      travel_to(Time.utc("2000-1-1")) do
        expect(SchoolMailer).to receive(:nomination_email).with(
          hash_including(
            recipient: school.primary_contact_email,
            school: school,
            nomination_url: String,
            expiry_date: "22/01/2000",
          ),
        ).and_call_original

        invite_schools.run [school.urn]
      end
    end

    it "sets the notify id on the nomination email record" do
      invite_schools.run [school.urn]
      expect(nomination_email.notify_id).to eq "notify_id"
    end

    context "when the school is cip only" do
      let(:school) { create(:school, :cip_only, primary_contact_email: primary_contact_email) }

      it "still sends the nomination email" do
        travel_to(Time.utc("2000-1-1")) do
          expect(SchoolMailer).to receive(:nomination_email).with(
            hash_including(
              school: school,
              nomination_url: String,
              recipient: school.primary_contact_email,
              expiry_date: "22/01/2000",
            ),
          ).and_call_original

          invite_schools.run [school.urn]
        end
      end
    end

    context "when school primary contact email is empty" do
      let(:primary_contact_email) { "" }

      it "sends the nomination email to the secondary contact" do
        expect(SchoolMailer).to receive(:nomination_email).with(
          hash_including(
            school: school,
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

  describe "#invite_section_41" do
    context "when the is an induction coordinator" do
      let(:induction_coordinator) { create(:user, :induction_coordinator) }
      let(:school) { induction_coordinator.schools.first }

      it "sends the email to the induction coordinator" do
        expect { InviteSchools.new.invite_section_41([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_section_41_invite_email).with(
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
        expect { InviteSchools.new.invite_section_41([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_section_41_invite_email).with(
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
        expect { InviteSchools.new.invite_section_41([school.urn]) }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_section_41_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: secondary_email,
            school: school,
          ),
        )
      end
    end
  end

  describe "#invite_cip_only_schools" do
    context "when the school has a primary contact email" do
      let!(:cip_only_school) { create(:school, :cip_only, school_type_code: 10) }
      let!(:welsh_cip_only_school) { create(:school, :cip_only, school_type_code: 30) }
      let!(:section_41_school) { create(:school, :cip_only, school_type_code: 10, section_41_approved: true) }
      let!(:fip_school) { create(:school, :open) }

      it "sends invites to non-welsh cip-only schools" do
        expect { InviteSchools.new.invite_cip_only_schools }.to change { NominationEmail.count }.by(1)
        expect(an_instance_of(InviteSchools)).to delay_execution_of(:send_cip_only_invite_email).with(
          an_object_having_attributes(
            class: NominationEmail,
            sent_to: cip_only_school.contact_email,
            school: cip_only_school,
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

    it "sends emails to tutors who have withdrawn all of their participants" do
      induction_coordinator = create(:user, :induction_coordinator)
      school_cohort = create(:school_cohort, school: induction_coordinator.schools.first, induction_programme_choice: "full_induction_programme")
      create(:participant_profile, :withdrawn_record, :ect, school_cohort: school_cohort)

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

  describe "#invite_sitless_opted_out_schools_for_nqt_plus_one" do
    it "sends an email to eligible opted out schools with no induction coordindators" do
      school = create(:school)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      expected_url = "http://www.example.com/schools/#{school.friendly_id}/year-2020/support-materials-for-NQTs?utm_campaign=year2020-nqt-invite-school&utm_medium=email&utm_source=year2020-nqt-invite-school"
      InviteSchools.new.invite_sitless_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to delay_email_delivery_of(:nqt_plus_one_sitless_invite)
                                .with(hash_including(
                                        recipient: school.contact_email,
                                        start_url: expected_url,
                                      ))
    end

    it "doesn't email ineligible schools" do
      school = create(:school, :cip_only)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      InviteSchools.new.invite_sitless_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sitless_invite)
    end

    it "doesn't email non-opted-out schools" do
      school = create(:school)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: false)

      InviteSchools.new.invite_sitless_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sitless_invite)
    end

    it "doesn't email schools with induction coordinators" do
      school = create(:school)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      InviteSchools.new.invite_sitless_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sitless_invite)
    end
  end

  describe "#invite_opted_out_sits_for_nqt_plus_one" do
    it "sends an email to eligible opted out schools with induction coordindators" do
      school = create(:school)
      sit = create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      expected_url = "http://www.example.com/schools/#{school.friendly_id}/year-2020/support-materials-for-NQTs?utm_campaign=year2020-nqt-invite-sit&utm_medium=email&utm_source=year2020-nqt-invite-sit"

      InviteSchools.new.invite_opted_out_sits_for_nqt_plus_one
      expect(SchoolMailer).to delay_email_delivery_of(:nqt_plus_one_sit_invite)
                                .with(hash_including(
                                        recipient: sit.email,
                                        start_url: expected_url,
                                      ))
    end

    it "doesn't email ineligible schools" do
      school = create(:school, :cip_only)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      InviteSchools.new.invite_opted_out_sits_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't email non-opted-out schools" do
      school = create(:school)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: false)

      InviteSchools.new.invite_opted_out_sits_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't email schools without induction coordinators" do
      school = create(:school)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      InviteSchools.new.invite_opted_out_sits_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end
  end

  describe "#invite_sitless_not_opted_out_schools_for_nqt_plus_one" do
    it "sends an email to eligible non-opted out schools with induction coordindators" do
      school = create(:school)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             opt_out_of_updates: false)

      expected_url = "http://www.example.com/schools/#{school.friendly_id}/year-2020/support-materials-for-NQTs?utm_campaign=year2020-nqt-invite-school-not-opted-out&utm_medium=email&utm_source=year2020-nqt-invite-school-not-opted-out"

      InviteSchools.new.invite_sitless_not_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to delay_email_delivery_of(:nqt_plus_one_sitless_invite)
                                .with(hash_including(
                                        recipient: school.contact_email,
                                        start_url: expected_url,
                                      )).once
    end

    it "doesn't email ineligible schools" do
      school = create(:school, :cip_only)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: false)

      InviteSchools.new.invite_sitless_not_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sitless_invite)
    end

    it "doesn't email opted-out schools" do
      school = create(:school)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: true)

      InviteSchools.new.invite_sitless_not_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sitless_invite)
    end

    it "doesn't email schools with induction coordinators" do
      school = create(:school)
      ic_profile = build(:induction_coordinator_profile, schools: [school])
      create(:user, induction_coordinator_profile: ic_profile)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             cohort: cohort,
             core_induction_programme: nil,
             opt_out_of_updates: false)

      InviteSchools.new.invite_sitless_not_opted_out_schools_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sitless_invite)
    end
  end

  describe "#invite_not_opted_out_sits_with_all_validated_participants_for_nqt_plus_one" do
    it "sends an email to eligible not-opted-out schools with induction coordinators and all participants validated" do
      school = create(:school)
      sit = create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             core_induction_programme: nil,
             opt_out_of_updates: false)
      create(:participant_profile, :ect, :ecf_participant_eligibility, school_cohort: school.school_cohorts.first)

      expected_url = "http://www.example.com/schools/#{school.friendly_id}/year-2020/support-materials-for-NQTs?utm_campaign=year2020-nqt-invite-sit-validated&utm_medium=email&utm_source=year2020-nqt-invite-sit-validated"
      InviteSchools.new.invite_not_opted_out_sits_with_all_validated_participants_for_nqt_plus_one
      expect(SchoolMailer).to delay_email_delivery_of(:nqt_plus_one_sit_invite)
                                .with(hash_including(
                                        recipient: sit.email,
                                        start_url: expected_url,
                                      )).once
    end

    it "doesn't email schools with unvalidated participants" do
      school = create(:school)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             core_induction_programme: nil,
             opt_out_of_updates: false)
      create(:participant_profile, :ect, :ecf_participant_eligibility, school_cohort: school.school_cohorts.first)
      create(:participant_profile, :ect, school_cohort: school.school_cohorts.first)

      InviteSchools.new.invite_not_opted_out_sits_with_all_validated_participants_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't email ineligible schools" do
      school = create(:school, :cip_only)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             core_induction_programme: nil,
             opt_out_of_updates: false)
      create(:participant_profile, :ect, :ecf_participant_eligibility, school_cohort: school.school_cohorts.first)

      InviteSchools.new.invite_not_opted_out_sits_with_all_validated_participants_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't email opted out schools" do
      school = create(:school)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             core_induction_programme: nil,
             opt_out_of_updates: true)
      create(:participant_profile, :ect, :ecf_participant_eligibility, school_cohort: school.school_cohorts.first)

      InviteSchools.new.invite_not_opted_out_sits_with_all_validated_participants_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't email schools without an induction coordinator" do
      school = create(:school)
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme",
             core_induction_programme: nil,
             opt_out_of_updates: false)
      create(:participant_profile, :ect, :ecf_participant_eligibility, school_cohort: school.school_cohorts.first)

      InviteSchools.new.invite_not_opted_out_sits_with_all_validated_participants_for_nqt_plus_one
      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end
  end

  describe "#invite_unpartnered_cip_sits_to_add_ects_and_mentors" do
    it "invites unpartnered cip schools with no participants" do
      school = create(:school)
      sit = create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme")

      expected_url = "http://www.example.com/users/sign_in?utm_campaign=add-participants-unpartnered-cip&utm_medium=email&utm_source=add-participants-unpartnered-cip"
      InviteSchools.new.invite_unpartnered_cip_sits_to_add_ects_and_mentors
      expect(SchoolMailer).to delay_email_delivery_of(:unpartnered_cip_sit_add_participants_email)
                                .with(hash_including(
                                        recipient: sit.email,
                                        sign_in_url: expected_url,
                                        induction_coordinator: sit,
                                        school_name: school.name,
                                      )).once
    end

    it "doesn't invite schools with participants" do
      school = create(:school)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "core_induction_programme")
      create(:participant_profile, :ect, school_cohort: school.school_cohorts.first)
      InviteSchools.new.invite_unpartnered_cip_sits_to_add_ects_and_mentors

      expect(SchoolMailer).to_not delay_email_delivery_of(:unpartnered_cip_sit_add_participants_email)
    end

    it "doesn't invite non-cip schools" do
      school = create(:school)
      create(:user, :induction_coordinator, schools: [school])
      create(:school_cohort,
             school: school,
             induction_programme_choice: "full_induction_programme")

      InviteSchools.new.invite_unpartnered_cip_sits_to_add_ects_and_mentors

      expect(SchoolMailer).to_not delay_email_delivery_of(:unpartnered_cip_sit_add_participants_email)
    end

    it "doesn't invite schools in a partnership" do
      school = create(:school)
      create(:induction_coordinator_profile, schools: [school])
      school_cohort = create(
        :school_cohort,
        school: school,
        induction_programme_choice: "core_induction_programme",
      )
      create(:partnership, school: school, cohort: school_cohort.cohort)

      InviteSchools.new.invite_unpartnered_cip_sits_to_add_ects_and_mentors

      expect(SchoolMailer).to_not delay_email_delivery_of(:unpartnered_cip_sit_add_participants_email)
    end
  end

  describe "#catch_all_invite_sits_for_nqt_plus_one" do
    it "sends an invite to eligible schools without a 2020 cohort" do
      school = create(:school)
      sit = create(:induction_coordinator_profile, schools: [school])
      create(
        :school_cohort,
        school: school,
        induction_programme_choice: "core_induction_programme",
      )

      expected_url = "http://www.example.com/schools/#{school.friendly_id}/year-2020/support-materials-for-NQTs?utm_campaign=year2020-nqt-invite-sit-catchall&utm_medium=email&utm_source=year2020-nqt-invite-sit-catchall"
      InviteSchools.new.catch_all_invite_sits_for_nqt_plus_one

      expect(SchoolMailer).to delay_email_delivery_of(:nqt_plus_one_sit_invite)
                                .with(hash_including(
                                        recipient: sit.user.email,
                                        start_url: expected_url,
                                      )).once
    end

    it "doesn't send an invite to ineligible schools" do
      school = create(:school, :cip_only)
      create(:induction_coordinator_profile, schools: [school])
      create(
        :school_cohort,
        school: school,
        induction_programme_choice: "core_induction_programme",
      )

      InviteSchools.new.catch_all_invite_sits_for_nqt_plus_one

      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't send an invite to schools without a SIT" do
      school = create(:school)
      create(
        :school_cohort,
        school: school,
        induction_programme_choice: "core_induction_programme",
      )

      InviteSchools.new.catch_all_invite_sits_for_nqt_plus_one

      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end

    it "doesn't send an invite to schools who have a 2020 cohort" do
      school = create(:school)
      create(:induction_coordinator_profile, schools: [school])
      create(
        :school_cohort,
        school: school,
        cohort: create(:cohort, start_year: 2020),
        induction_programme_choice: "core_induction_programme",
      )

      InviteSchools.new.catch_all_invite_sits_for_nqt_plus_one

      expect(SchoolMailer).to_not delay_email_delivery_of(:nqt_plus_one_sit_invite)
    end
  end

  describe "#invite_unengaged_schools" do
    it "sends an invite to unpartnered schools without a sit" do
      school = create(:school)

      expect(SchoolMailer).to receive(:unengaged_schools_email).with(
        hash_including(
          recipient: school.contact_email,
          school: school,
          nomination_url: a_string_including("utm_campaign=unengaged-schools&utm_medium=email&utm_source=unengaged-schools"),
        ),
      ).and_call_original

      InviteSchools.new.invite_unengaged_schools
    end

    it "doesn't invite partnered schools" do
      school = create(:school)
      create(:partnership, school: school, cohort: Cohort.current)

      expect(SchoolMailer).to_not receive(:unengaged_schools_email)
      InviteSchools.new.invite_unengaged_schools
    end

    it "doesn't invite opted out schools" do
      school = create(:school)
      create(:school_cohort, school: school, opt_out_of_updates: true, cohort: Cohort.current)

      expect(SchoolMailer).to_not receive(:unengaged_schools_email)
      InviteSchools.new.invite_unengaged_schools
    end

    it "doesn't invite schools with a sit" do
      school = create(:school)
      create(:induction_coordinator_profile, schools: [school])

      expect(SchoolMailer).to_not receive(:unengaged_schools_email)
      InviteSchools.new.invite_unengaged_schools
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

  def expect_choose_provider_email(induction_coordinator)
    expect(SchoolMailer).to delay_email_delivery_of(:induction_coordinator_reminder_to_choose_provider_email)
                              .with(hash_including(
                                      recipient: induction_coordinator.email,
                                    ))
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
