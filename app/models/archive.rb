# frozen_string_literal: true

module Archive
  def self.table_name_prefix
    "archive_"
  end

  class ArchiveError < StandardError; end
end
