# frozen_string_literal: true

module Schools
  class Year2020Form
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :school_id, :core_induction_programme_id, :full_name, :email, :participants
    validates :core_induction_programme_id, presence: true, on: :choose_cip

    validates :full_name, presence: true, on: %i[create_teacher update_teacher]
    validates :email,
              presence: true,
              notify_email: { allow_blank: true },
              on: %i[create_teacher update_teacher]
    validate :email_is_not_in_use

    def attributes
      { school_id: nil, core_induction_programme_id: nil, participants: nil }
    end

    def school
      School.friendly.find(school_id) || School.find_by(urn: school_id)
    end

    def core_induction_programme
      CoreInductionProgramme.find(core_induction_programme_id)
    end

    def cohort
      Cohort.find_by(start_year: 2020)
    end

    def email_already_taken?
      ParticipantProfile.active_record.ects.joins(:user).where(user: { email: email }).any?
    end

    def store_new_participant
      self.participants = get_participants << { full_name: full_name, email: email, index: new_participant_index }
      self.full_name = nil
      self.email = nil
    end

    def get_participants
      participants&.filter { |participant| participant } || []
    end

    def new_participant_index
      max_index = 0
      get_participants.each { |participant| max_index = [max_index, participant[:index]].max }
      max_index + 1
    end

    def get_participant(index)
      get_participants.find { |participant| participant[:index] == index }
    end

    def update_participant(index)
      new_participants = get_participants.map do |participant|
        if participant[:index] == index
          participant[:full_name] = full_name
          participant[:email] = email
        end
        participant
      end
      self.participants = new_participants
      self.full_name = nil
      self.email = nil
    end

    def remove_participant(index)
      self.participants = get_participants.filter { |participant| participant[:index] != index }
    end

    def save!
      ActiveRecord::Base.transaction do
        school_cohort = SchoolCohort.find_or_initialize_by(school: school, cohort: cohort)
        school_cohort.induction_programme_choice = "core_induction_programme"
        school_cohort.core_induction_programme = core_induction_programme
        school_cohort.save!

        participants = get_participants.each do |participant|
          EarlyCareerTeachers::Create.call(
            full_name: participant[:full_name],
            email: participant[:email],
            school_cohort: school_cohort,
            mentor_profile_id: nil,
          )
        end

        SchoolMailer.year2020_add_participants_confirmation(
          school: school,
          participants: participants,
        ).deliver_now
      end
    end

  private

    def email_is_not_in_use
      errors.add(:email, :taken) if email_already_taken?
    end
  end
end
