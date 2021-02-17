# frozen_string_literal: true

require "csv"

class SparsityImporter
  attr_reader :logger
  attr_reader :start_year
  attr_reader :source_file

  def initialize(logger, start_year = Time.zone.now.year, source_file = nil)
    @logger = logger
    @start_year = start_year
    @source_file = source_file
  end

  def run
    DistrictSparsity.where(start_year: start_year).destroy_all

    latest_sparse_districts.each do |lad_code|
      update_lad_sparsity(lad_code)
    end

    districts_no_longer_sparse.each do |district_sparsity|
      district_sparsity.update!(end_year: start_year)
    end
  end

private

  def data_file
    source_file || Rails.root.join("data/sparse_lads.csv")
  end

  def update_lad_sparsity(lad_code)
    lad = LocalAuthorityDistrict.find_by(code: lad_code)
    logger.info "Could not find lad with code #{lad_code}" and return unless lad

    district_sparsity = DistrictSparsity.find_or_initialize_by(local_authority_district: lad, end_year: nil)
    district_sparsity.start_year ||= start_year
    district_sparsity.save!
    district_sparsity
  end

  def districts_no_longer_sparse
    DistrictSparsity.latest
                    .joins(:local_authority_district)
                    .where.not(local_authority_district: { code: latest_sparse_districts })
  end

  def latest_sparse_districts
    @csv ||= CSV.read(data_file, headers: true, encoding: "ISO-8859-1:UTF-8")
    @csv["LAD_CODE"]
  end
end
