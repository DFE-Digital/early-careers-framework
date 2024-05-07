# frozen_string_literal: true

PaperTrail.config.enabled = true
PaperTrail.config.version_limit = nil
PaperTrail.serializer = PaperTrail::Serializers::JSON

# Exclude :touch events to avoid creating unnecessary versions
PaperTrail.config.has_paper_trail_defaults = {
  on: %i[create update destroy],
}
