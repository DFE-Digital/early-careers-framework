# frozen_string_literal: true

class BackfillMentorUserId
  attr_reader :dry_run

  def initialize(dry_run: true)
    @dry_run = dry_run
  end

  def run
    log_start
    process_declarations
    log_finish
  end

private

  def log_start
    logger.info("~~DRY RUN~~") if dry_run
    logger.info("Backfilling #{total_declarations} declarations")
  end

  def process_declarations
    declarations.find_each.with_index do |declaration, index|
      throttle_backfill
      log_progress(index + 1)

      induction_record = find_induction_record(declaration)
      mentor_user_id = extract_mentor_user_id(induction_record)

      if mentor_user_id.present? && !dry_run
        declaration.update!(mentor_user_id:)
      end
    end
  end

  def log_progress(count)
    logger.info("#{count}/#{total_declarations}") if (count % 10).zero?
  end

  def log_finish
    logger.info("Finished backfilling declarations")
  end

  def throttle_backfill
    sleep(0.0025)
  end

  def total_declarations
    @total_declarations ||= declarations.count
  end

  def find_induction_record(declaration)
    Induction::FindBy.call(
      participant_profile: declaration.participant_profile,
      lead_provider: declaration.cpd_lead_provider.lead_provider,
      date_range: (..declaration.declaration_date),
    )
  end

  def extract_mentor_user_id(induction_record)
    induction_record&.mentor_profile&.participant_identity&.user_id
  end

  def declarations
    @declarations ||=
      ParticipantDeclaration::ECF
        .includes(:participant_profile, cpd_lead_provider: :lead_provider)
        .where(mentor_user_id: nil)
  end

  def logger
    Logger.new($stdout)
  end
end
