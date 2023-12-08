# frozen_string_literal: true

module Archive
  class RelicPresenter
    attr_reader :relic

    def self.wrap(collection)
      collection.map do |relic|
        presenter_for relic
      end
    end

    def self.presenter_for(relic_data)
      relic_type = relic_data["type"]

      case relic_type
      when "user"
        ::Archive::UserPresenter.new(relic_data)
      when "participant_identity"
        ::Archive::ParticipantIdentityPresenter.new(relic_data)
      when "participant_profile"
        case relic_data.dig("attributes", "type")
        when "ParticipantProfile::ECT"
          ::Archive::ParticipantProfilePresenter.new(relic_data)
        when "ParticipantProfile::Mentor"
          ::Archive::ParticipantProfilePresenter.new(relic_data)
        end
      when "participant_declaration"
        ::Archive::ParticipantDeclarationPresenter.new(relic_data)
      when "induction_record"
        ::Archive::InductionRecordPresenter.new(relic_data)
      else
        raise "Do not know how to present #{relic_type}"
      end
    end

    def id
      relic["id"]
    end

    def type
      relic["type"]
    end

    def method_missing(method_name, *args, &block)
      if relic["attributes"].key?(method_name.to_s)
        attribute(method_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      relic["attributes"].key?(method_name.to_s) || super
    end

    # meta attributes
    def user_id
      @user_id ||= meta("id")
    end

    def full_name
      @full_name ||= meta("full_name")
    end

    def email
      @email ||= meta("email")
    end

    def trn
      @trn ||= meta("trn") || "Not recorded"
    end

    def roles
      @roles ||= if meta("roles").blank?
                   "None"
                 else
                   meta("roles").map(&:humanize).join(", ")
                 end
    end

  private

    def initialize(relic)
      @relic = relic
    end

    def meta(name)
      relic.dig("meta", name.to_s)
    end

    def attribute(name)
      relic.dig("attributes", name.to_s)
    end
  end
end
