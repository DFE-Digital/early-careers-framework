#frozen_string_input: true
#
class DummyDeclarations
  class << self
    def call
      LeadProvider.all.each do |lp|
        cpd=lp.cpd_lead_provider
        lp.ecf_participants.each do |p|
          course_identifier = p.early_career_teacher? ? "ecf-induction" : "ecf-mentor"
          RecordParticipantDeclaration.(
            participant_id: p.id,
            declaration_type: "started",
            course_identifier: course_identifier,
            declaration_date: Time.zone.now.rfc3339,
            cpd_lead_provider: cpd
          ) rescue nil
        end
      end
    end
  end
end
