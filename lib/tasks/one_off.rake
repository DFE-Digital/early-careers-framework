# frozen_string_literal: true

namespace :one_off do
  desc "Seed data to verify bucketing per bands works as expected"
  task seed_declarations_for_band: :environment do
    require "factory_bot"
    include Importers::SeedBPNDeclarations
    # Nov 30th 23:59 milestone cutoff  eligible -> payable

    ParticipantDeclaration.destroy_all
    ActiveRecord::Base.transaction do
      lead_provider                             = LeadProvider.find_by!(name: "Best Practice Network")
      november_statement                        = lead_provider.statements.find_by!(name: "November 2021")
      january_statement                         = lead_provider.statements.find_by!(name: "January 2022")
      september_standard_schedule               = Finance::Schedule::ECF.find_by!(name: "ECF Standard September")
      january_standard_schedule                 = Finance::Schedule::ECF.find_by!(name: "ECF Standard January")
      september_standard_started_milestone      = september_standard_schedule.milestones.find_by!(declaration_type: "started")

      january_standard_started_milestone        = january_standard_schedule.milestones.find_by!(declaration_type: "started")
      september_standard_school_cohorts         = SchoolCohort.joins(
        school: { active_partnerships: :lead_provider },
        cohort: { schedules: :milestones },
      ).where(
        school: { partnerships: { lead_provider: lead_provider } },
        cohort: { schedules: september_standard_schedule },
      ).distinct(:school)
      january_standard_school_cohorts = SchoolCohort.joins(
        school: { active_partnerships: :lead_provider },
        cohort: { schedules: :milestones },
      ).where(
        school: { partnerships: { lead_provider: lead_provider } },
        cohort: { schedules: january_standard_schedule },
      ).distinct(:school)

      september_started_mentor_count = 4_199 / 2
      september_started_ect_count    = 4_199 - september_started_mentor_count

      # September starts
      declaration_start_interval = (september_standard_started_milestone.start_date + 1.day)..november_statement.deadline_date
      september_mentors = FactoryBot.create_list(:user, september_started_mentor_count)
        .map { |user| create_participant(Mentors::Create, user, september_standard_school_cohorts.first) }
        .map { |participant_profile| record_started_declaration(participant_profile, declaration_start_interval, lead_provider) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }
      puts "Generated : #{september_started_mentor_count} Mentor started declaration in #{september_standard_started_milestone.inspect}"

      september_ects = FactoryBot.create_list(:user, september_started_ect_count.to_i)
        .map { |user| create_participant(EarlyCareerTeachers::Create, user, september_standard_school_cohorts.first) }
        .map { |participant_profile| record_started_declaration(participant_profile, declaration_start_interval, lead_provider) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }
      puts "Generated : #{september_started_ect_count.to_i} ECF started declaration in #{september_standard_started_milestone.inspect}"

      RecordDeclarations::Actions::MakeDeclarationsPayable.call(declaration_class: ParticipantDeclaration::ECF, cutoff_date: declaration_start_interval.end)

      # BNP submits 1000 started declaration in January
      january_started_mentor_count   = 500
      january_started_ect_count      = 500
      january_declaration_start_interval = (january_standard_started_milestone.start_date + 1.day)..january_statement.deadline_date
      FactoryBot.create_list(:user, january_started_mentor_count)
        .map { |user| create_participant(Mentors::Create, user, january_standard_school_cohorts.first) }
        .map { |participant_profile| change_participant_schedule(participant_profile, january_standard_schedule, lead_provider) }
        .map { |participant_profile| record_started_declaration(participant_profile, january_declaration_start_interval, lead_provider) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }
      puts "Generated : #{september_started_mentor_count} Mentor started declaration in #{september_standard_started_milestone.inspect}"

      FactoryBot.create_list(:user, january_started_ect_count.to_i)
        .map { |user| create_participant(EarlyCareerTeachers::Create, user, january_standard_school_cohorts.first) }
        .map { |participant_profile| change_participant_schedule(participant_profile, january_standard_schedule, lead_provider) }
        .map { |participant_profile| record_started_declaration(participant_profile, january_declaration_start_interval, lead_provider) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }

      # Started recieving retained-1 declarations for September standart retained one milestone
      (september_ects + september_mentors)
        .map { |participant_profile| create_retained_one_declaration(participant_profile, lead_provider, january_declaration_start_interval) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }

      # 200 backdated declarations with mix of ect/mentor
      #
      backdated_declaration_mentor = 100
      backdated_declaration_ect    = 100
      FactoryBot.create_list(:user, backdated_declaration_mentor)
        .map { |user| create_participant(Mentors::Create, user, january_standard_school_cohorts.first) }
        .map { |participant_profile| change_participant_schedule(participant_profile, september_standard_schedule, lead_provider) }
        .map { |participant_profile| record_backdated_started_declaration(participant_profile, january_declaration_start_interval, lead_provider, declaration_start_interval) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }

      FactoryBot.create_list(:user, backdated_declaration_ect)
        .map { |user| create_participant(EarlyCareerTeachers::Create, user, january_standard_school_cohorts.first) }
        .map { |participant_profile| change_participant_schedule(participant_profile, september_standard_schedule, lead_provider) }
        .map { |participant_profile| record_backdated_started_declaration(participant_profile, january_declaration_start_interval, lead_provider, declaration_start_interval) }
        .map { |participant_profile| make_declaration_eligible(participant_profile) }

      RecordDeclarations::Actions::MakeDeclarationsPaid.call
      RecordDeclarations::Actions::MakeDeclarationsPayable.call(declaration_class: ParticipantDeclaration::ECF, cutoff_date: january_statement.deadline_date)
    end
  end
end
