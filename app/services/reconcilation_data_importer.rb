# frozen_string_literal: true

require "csv"

class ReconcilationDataImporter
  attr_reader :source_file

  def initialize(source_file = nil)
    @source_file = source_file
  end

  def run
    CSV.foreach(data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
      transfer_identity(row)
    end
  end

private

  def data_file
    source_file || Rails.root.join("data/reconcile.csv")
  end

  def transfer_identity(row)
    from_user_id = row.fetch("from_user")
    to_user_id = row.fetch("to_user")
    from_user = User.find_by(id: from_user_id)
    to_user = User.find_or_create_by!(id: to_user_id)
    if from_user.present? && to_user.present?
      Identity::Transfer.call(from_user: from_user, to_user: to_user)
      Rails.logger.info("Data is successfully moved from #{from_user.email} to #{to_user.email}")
    else
      Rails.logger.info("Data is not updated because from_user is not present")
    end
  end
end
