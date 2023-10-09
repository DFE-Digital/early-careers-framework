module Archive
  class ParticipantDeclarationPresenter < RelicPresenter
    def schedule
      @schedule ||= Finance::Schedule.find(attribute(:schedule_id))
    end

    def declaration_date
      DateTime.parse(attribute(:declaration_date))
    end

    def cpd_lead_provider
      @cpd_lead_provider ||= CpdLeadProvider.find(attribute(:cpd_lead_provider_id))
    end

    def created_at
      DateTime.parse(attribute(:created_at))
    end
  end
end
