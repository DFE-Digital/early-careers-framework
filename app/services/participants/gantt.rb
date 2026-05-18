# frozen_string_literal: true

module Participants
  class Gantt
    attr_reader :id, :induction_records, :declarations, :participant_profile

    def initialize(induction_records, declarations, participant_profile)
      @induction_records = induction_records
      @declarations = declarations
      @participant_profile = participant_profile
    end

    def build
      <<~PLANTUML
        @startgantt

        hide footbox
        printscale monthly
        project starts on #{earliest_start.to_date}

        #{academic_year_boundaries.join("\n")}
        #{induction_record_descriptions.join("\n")}
        #{declaration_descriptions.join("\n")}
        #{completions.join("\n")}
        #{legend(present_lead_provider_names)}

        @endgantt
      PLANTUML
    end

    def to_png
      IO.popen("plantuml -p", "r+") do |pipe|
        pipe.puts(build)
        pipe.close_write
        pipe.read
      end
    end

  private

    def earliest_start
      induction_records.first.start_date.to_s
    end

    def induction_record_descriptions
      induction_records.group_by(&:school_urn).flat_map do |urn, records|
        chunk = [%(-- #{urn} --)]

        records.sort_by(&:start_date).each do |ir|
          identifier = ir.id[0..7]

          chunk << <<~LINE
            [#{identifier}] starts on #{ir.start_date.to_date} and ends on #{ir.end_date&.to_date || Date.current}
            [#{identifier}] is colored in #{colour(ir.lead_provider_name)}
          LINE

          chunk << withdrawn_note(identifier) if ir.training_status == "withdrawn"
        end

        chunk.join("\n")
      end
    end

    def academic_year_boundaries
      2020.upto(2026).map { |y| %(#{y}/09/01 is colored in salmon) }
    end

    def present_lead_provider_names
      induction_records.map(&:lead_provider_name).uniq
    end

    def withdrawn_note(identifier)
      <<~NOTE
        note bottom
          note for #{identifier}
          withdrawn: true
        end note
      NOTE
    end

    def declaration_descriptions
      declarations.map { |d| %([#{d.declaration_type} (#{d.cpd_lead_provider.name})] happens at #{d.declaration_date.to_date}) }
    end

    def completions
      markers = []

      return markers unless participant_profile

      if participant_profile.induction_completion_date
        markers << %([Induction completed] happens at #{participant_profile.induction_completion_date})
        markers << %([Induction completed] is deleted)
      end

      if participant_profile.mentor_completion_date
        markers << %([Mentor training completed] happens at #{participant_profile.mentor_completion_date})
        markers << %([Mentor training completed] is deleted)
      end

      markers
    end

    def colour(lead_provider)
      {
        "Ambition Institute" => "gold",
        "Best Practice Network" => "deeppink",
        "Capita" => "cyan",
        "Education Development Trust" => "slateblue",
        "National Institute of Teaching" => "cadetblue",
        "Teach First" => "royalblue",
        "UCL Institute of Education" => "lightslategrey",
      }.fetch(lead_provider, "bisque")
    end

    def legend(present_lead_provider_names, extras: {})
      entries = present_lead_provider_names.map do |lead_provider_name|
        %(| <##{colour(lead_provider_name)}> | #{lead_provider_name || 'Expression of interest'} |)
      end

      entries << extras.map { |state, colour| %(| <##{colour}> | #{state} |) }

      <<~LEGEND
        legend
        |= |= Lead provider |
        #{entries.compact.uniq.join("\n")}
        end legend
      LEGEND
    end
  end
end
