# frozen_string_literal: true

SchoolDataImporterJob.perform_later
ActiveRecord::Base.transaction do
  User.find_or_create_by!(email: "admin@example.com") do |user|
    user.update!(full_name: "Admin User")
    AdminProfile.find_or_create_by!(user:)
  end

  User.find_or_create_by!(email: "finance@example.com") do |user|
    user.update!(full_name: "Finance User")
    FinanceProfile.find_or_create_by!(user:)
  end

  User.find_or_create_by!(email: "delivery-partner@example.com") do |user|
    user.update!(full_name: "Delivery Partner User")
    DeliveryPartner.first(2).each do |dp|
      DeliveryPartnerProfile.find_or_create_by!(user:, delivery_partner: dp)
    end
  end

  User.find_or_create_by!(email: "appropriate-body@example.com") do |user|
    user.update!(full_name: "Appropriate Body User")

    2.times do |n|
      appropriate_body = AppropriateBody.create!(name: "Local Authority #{n + 1}", body_type: "local_authority")
      AppropriateBodyProfile.find_or_create_by!(user:, appropriate_body:)
    end
  end

  User.find_or_create_by!(email: "lead-provider@example.com") do |user|
    user.update!(full_name: "LeadProvider User")
    LeadProviderProfile.find_or_create_by!(user:, lead_provider: LeadProvider.first)
  end

  school = School.find_or_create_by!(urn: "999999") do |created_school|
    created_school.name = "Example school"
    created_school.postcode = "BB1 1BB"
    created_school.address_line1 = "3 Madeup Street"
    created_school.primary_contact_email = "school-info@example.com"
    created_school.school_status_code = 1
    created_school.school_type_code = 1
    created_school.administrative_district_code = "E123"
  end

  school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school:, induction_programme_choice: "core_induction_programme")

  school_two = School.find_or_create_by!(urn: "111111") do |created_school|
    created_school.name = "Example school two"
    created_school.postcode = "ZZ1 1ZZ"
    created_school.address_line1 = "99 Madeup Road"
    created_school.primary_contact_email = "school-2-info@example.com"
    created_school.school_status_code = 1
    created_school.school_type_code = 1
    created_school.administrative_district_code = "WA4 1AA"
  end

  school_two_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school_two, induction_programme_choice: "core_induction_programme")

  school_three = School.find_or_create_by!(urn: "5555555") do |created_school|
    created_school.name = "Example school three"
    created_school.postcode = "WA1 1AA"
    created_school.address_line1 = "100 Warrington Road"
    created_school.primary_contact_email = "school-3-info@example.com"
    created_school.school_status_code = 1
    created_school.school_type_code = 1
    created_school.administrative_district_code = "W123"
  end

  school_three_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school_three, induction_programme_choice: "full_induction_programme")

  LeadProvider.find_each do |lead_provider|
    Partnership.find_or_create_by!(
      cohort: school_cohort.cohort,
      delivery_partner: lead_provider.delivery_partners.first,
      school: school_cohort.school,
      lead_provider:,
    )
    Partnership.find_or_create_by!(
      cohort: school_two_cohort.cohort,
      delivery_partner: lead_provider.delivery_partners.first,
      school: school_two_cohort.school,
      lead_provider:,
    )
    Partnership.find_or_create_by!(
      cohort: school_three_cohort.cohort,
      delivery_partner: lead_provider.delivery_partners.first,
      school: school_three_cohort.school,
      lead_provider:,
    )
  end

  User.find_or_create_by!(email: "school-leader@example.com") do |user|
    user.update!(full_name: "InductionTutor User")
    InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
      profile.update!(schools: [school])
    end
  end

  user = User.find_or_create_by!(email: "npq-registrant@example.com") do |npq_user|
    npq_user.full_name = "NPQ registrant"
  end

  teacher_profile = user.teacher_profile || user.create_teacher_profile

  profile = ParticipantProfile::NPQ.find_or_create_by!(teacher_profile:) do |npq_profile|
    npq_profile.schedule = Finance::Schedule::NPQSpecialist.default
    npq_profile.participant_identity = Identity::Create.call(user:, origin: :npq)
  end

  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  user = User.find_or_create_by!(email: "rp-mentor-ambition@example.com") do |mentor_user|
    mentor_user.full_name = "Sally Mentor"
  end

  teacher_profile = user.teacher_profile || user.create_teacher_profile

  partnership = Partnership.find_or_create_by!(
    cohort: school_cohort.cohort,
    delivery_partner: school_cohort.school.delivery_partner_for(school_cohort.cohort.start_year),
    school: school_cohort.school,
    lead_provider: school_cohort.lead_provider,
  )
  induction_programme = InductionProgramme.find_or_create_by!(
    school_cohort:,
    partnership:,
    training_programme: "full_induction_programme",
  )

  profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
    mentor_profile.school_cohort = school_cohort
    mentor_profile.core_induction_programme = CoreInductionProgramme.find_by(name: "Ambition Institute")
    mentor_profile.schedule = Finance::Schedule::ECF.default
    mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end
  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  user = User.find_or_create_by!(email: "rp-mentor-edt@example.com") do |mentor_user|
    mentor_user.full_name = "Jane Doe"
  end

  teacher_profile = user.teacher_profile || user.create_teacher_profile

  profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
    mentor_profile.school_cohort = school_two_cohort
    mentor_profile.core_induction_programme = CoreInductionProgramme.find_by(name: "Education Development Trust")
    mentor_profile.schedule = Finance::Schedule::ECF.default
    mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end
  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  user = User.find_or_create_by!(email: "rp-mentor-ucl@example.com") do |mentor_user|
    mentor_user.full_name = "Abdul Mentor"
  end
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
    mentor_profile.school_cohort = school_three_cohort
    mentor_profile.core_induction_programme = CoreInductionProgramme.find_by(name: "UCL Institute of Education")
    mentor_profile.schedule = Finance::Schedule::ECF.default
    mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end
  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  user = User.find_or_create_by!(email: "rp-ect-ambition@example.com") do |ect_user|
    ect_user.full_name = "Joe Bloggs"
  end
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
    ect_profile.school_cohort = school_cohort
    ect_profile.core_induction_programme = CoreInductionProgramme.find_by(name: "Ambition Institute")
    ect_profile.mentor_profile = user.mentor_profile
    ect_profile.schedule = Finance::Schedule::ECF.default
    ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end
  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  user = User.find_or_create_by!(email: "rp-ect-edt@example.com") do |ect_user|
    ect_user.full_name = "John Doe"
  end
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
    ect_profile.school_cohort = school_two_cohort
    ect_profile.core_induction_programme = CoreInductionProgramme.find_by(name: "Education Development Trust")
    ect_profile.mentor_profile = user.mentor_profile
    ect_profile.schedule = Finance::Schedule::ECF.default
    ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end
  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  user = User.find_or_create_by!(email: "rp-ect-ucl@example.com") do |ect_user|
    ect_user.full_name = "Dan Smith"
  end
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
    ect_profile.school_cohort = school_three_cohort
    ect_profile.core_induction_programme = CoreInductionProgramme.find_by(name: "UCL Institute of Education")
    ect_profile.mentor_profile = user.mentor_profile
    ect_profile.schedule = Finance::Schedule::ECF.default
    ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end
  ParticipantProfileState.find_or_create_by!(participant_profile: profile)

  # populate change of circumstances
  SchoolCohort.where(induction_programme_choice: InductionProgramme.training_programmes.keys).where(default_induction_programme: nil).find_each do |sc|
    choice = sc.induction_programme_choice
    programme = InductionProgramme.find_or_initialize_by(school_cohort: sc,
                                                         training_programme: sc.induction_programme_choice)
    case choice
    when "full_induction_programme"
      programme.partnership = sc.school.active_partnerships.where(cohort: sc.cohort).first
    when "core_induction_programme"
      programme.core_induction_programme = sc.core_induction_programme
    end
    programme.save!

    sc.ecf_participant_profiles.each do |ecf_profile|
      if ecf_profile.current_induction_programme != programme
        induction = Induction::Enrol.call(participant_profile: ecf_profile, induction_programme: programme)
        induction.update!(induction_status: ecf_profile.status, training_status: ecf_profile.training_status, mentor_profile_id: ecf_profile.mentor_profile_id)
      end
    end
    sc.update!(default_induction_programme: programme)
  end

  # We clear the database on a regular basis, but we want a stable token that E&L can use in its dev environments
  # Hashed token with the same unhashed version will be different between dev and deployed dev
  # The tokens below have different unhashed version to avoid worrying about clever cryptographic attacks
  if Rails.env.deployed_development?
    EngageAndLearnApiToken.find_or_create_by!(hashed_token: "dfce9a34c6f982e8adb4b903f8b6064682e6ad1f7858c41ed8a0a7468abc8896")
    NPQRegistrationApiToken.find_or_create_by!(hashed_token: "1dae3836ed90df4b796eff1f4a4713247ac5bc8a00352ea46eee621d74cd4fcf")
    DataStudioApiToken.find_or_create_by!(hashed_token: "c7123fb0e2aecb17e1089e01849d71665983e200e891fe726341a08f176c1d64")
  elsif Rails.env.development?
    EngageAndLearnApiToken.find_or_create_by!(hashed_token: "f4a16cd7fc10918fbc7d869d7a83df36059bb98fac7c82502d797b1f1dd73e86")
  end
end
if Rails.env.sandbox?
  NPQRegistrationApiToken.find_or_create_by!(hashed_token: "166eaa39950ad15f2f36041cb9062cc8fa9f109945fe9b8378bf904fe35369bc")
end

unless Rails.env.sandbox?
  [
    { name: "Ambition Institute", token: "ambition-token" },
    { name: "Best Practice Network", token: "best-practice-token" },
    { name: "Capita", token: "capita-token" },
    { name: "Education Development Trust", token: "edt-token" },
    { name: "Teach First", token: "teach-first-token" },
    { name: "UCL Institute of Education", token: "ucl-token" },
  ].each do |hash|
    cpd_lead_provider = CpdLeadProvider.find_by(name: hash[:name])
    LeadProviderApiToken.create_with_known_token!(hash[:token], cpd_lead_provider:)
  end
end
