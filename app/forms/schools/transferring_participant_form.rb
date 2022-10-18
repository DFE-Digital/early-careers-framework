# frozen_string_literal: true

module Schools
  class TransferringParticipantForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serialization

    attr_accessor :full_name, :trn, :date_of_birth, :start_date, :email, :mentor_id, :schools_current_programme_choice, :teachers_current_programme_choice, :same_programme, :current_step, :steps

    validates :full_name, presence: true, on: :full_name
    validates :trn, teacher_reference_number: true, on: :trn
    validates :email, presence: true, notify_email: true, on: :email
    validates :mentor_id, presence: true, on: :choose_mentor
    validate :schools_programme_choice, on: :schools_current_programme
    validate :teachers_programme_choice, on: :teachers_current_programme
    validate :check_mentor, on: :choose_mentor
    validate :dob, on: :dob
    validate :teacher_start_date, on: :teacher_start_date

    def attributes
      {
        full_name:,
        trn:,
        date_of_birth:,
        start_date:,
        email:,
        mentor_id:,
        schools_current_programme_choice:,
        teachers_current_programme_choice:,
        same_programme:,
        steps:,
        current_step:,
      }
    end

    def formatted_trn
      TeacherReferenceNumber.new(trn).formatted_trn
    end

    def schools_current_programme_choices
      [
        OpenStruct.new(id: "yes", name: "Yes"),
        OpenStruct.new(id: "no", name: "No"),
      ]
    end

    def teachers_current_programme_choices
      [
        OpenStruct.new(id: "yes", name: "Yes"),
        OpenStruct.new(id: "no", name: "No"),
      ]
    end

    def using_schools_programme?
      same_programme || switch_to_schools_programme?
    end

    def switch_to_schools_programme?
      schools_current_programme_choice == "yes" && !continue_teachers_programme?
    end

    def continue_teachers_programme?
      teachers_current_programme_choice == "yes"
    end

    def mentor
      User.find(mentor_id) if mentor_id.present?
    end

    def mentor_profile
      mentor&.mentor_profile
    end

    def previous_step
      remove_current_step
      steps.last.to_sym
    end

    def remove_current_step
      return if steps.nil?

      if steps.include?(current_step)
        steps.delete(current_step)
      end
    end

    def update_steps
      if steps.nil?
        @steps = %w[what_we_need]
      end

      steps.push(current_step)
    end

  private

    def teacher_start_date
      @start_date = ActiveRecord::Type::Date.new.cast(start_date)
      if @start_date.blank?
        errors.add(:start_date, I18n.t("errors.start_date.blank"))
      elsif @start_date.year.digits.length != 4
        errors.add(:start_date, I18n.t("errors.start_date.invalid"))
      end
    end

    def dob
      @date_of_birth = ActiveRecord::Type::Date.new.cast(date_of_birth)
      if date_of_birth.blank?
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.blank"))
      elsif date_of_birth > Time.zone.now
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.in_future"))
      elsif !date_of_birth.between?(Date.new(1900, 1, 1), Date.current - 18.years)
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.invalid"))
      elsif date_of_birth.year.digits.length != 4
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.invalid"))
      end
    end

    def schools_programme_choice
      errors.add(:schools_current_programme_choice, :blank) unless schools_current_programme_choices.map(&:id).include?(schools_current_programme_choice)
    end

    def teachers_programme_choice
      errors.add(:teachers_current_programme_choice, :blank) unless teachers_current_programme_choices.map(&:id).include?(teachers_current_programme_choice)
    end

    def check_mentor
      @mentor_id = nil if mentor_id == "later"
    end
  end
end
