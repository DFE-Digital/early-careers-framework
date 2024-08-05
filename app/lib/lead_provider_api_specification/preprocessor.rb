# frozen_string_literal: true

class Hash
  # Opposite of dig; will set a value at a nested key.
  def bury(*keys, value)
    if keys.length > 1
      self[keys.shift].bury(*keys, value)
    else
      self[keys.first] = value
    end
  end

  # Deep search for a term in a hash of hashes. When
  # a non-hash is found, a string search is performed
  # (by calling to_s on the value and comparing it).
  def deep_search(term:, path: [])
    each do |key, value|
      if value.is_a?(Hash)
        # Check for matching key.
        return path + [key] if key.to_s.downcase.include?(term)

        # Deep search value.
        match = value.deep_search(term:, path: path + [key])
        return match if match
      # Check for matching value.
      elsif value.to_s.downcase.include?(term)
        return path + [key]
      end
    end

    nil
  end
end

class LeadProviderApiSpecification::Preprocessor
  MAX_ITERATIONS = 1_000
  SEARCH_TERM = "npq"

  attr_reader :swagger_path

  def initialize(swagger_path)
    @swagger_path = swagger_path
  end

  def preprocess!
    remove_npq_references! if remove_npq_references?
  end

private

  def remove_npq_references?
    Rails.env.separation?
  end

  def swagger_string
    @swagger_string ||= File.read(swagger_path)
  end

  def swagger_doc
    @swagger_doc ||= JSON.parse(swagger_string, symbolize_names: true)
  end

  def remove_npq_references!
    return unless npq?(swagger_string)

    # To make the subsequent logic simpler we pefrorm a fresh search each time,
    # rather than finding all the keys up front. To avoid a potential infinite
    # loop we are capping the number of searches/iterations.
    MAX_ITERATIONS.times do
      # Retrieve a key that matches NPQ (by key or value).
      key = swagger_doc.deep_search(term: SEARCH_TERM)
      break if key.blank?

      # Retrieve the value at the matched key.
      value = swagger_doc.dig(*key)

      # If the deepest key is NPQ, remove it from the swagger doc.
      if npq?(key.last)
        purge_key(key)
      # Otherwise handle the key/value based on its type
      else
        update_key(key, value)
      end
    end

    raise_if_npq_references_still_exist!
    write_swagger_doc!
  end

  def purge_key(key)
    swagger_doc.dig(*(key[0...-1])).delete(key.last)
  end

  def update_key(key, value)
    # Delete any NPQ-specific values.
    case key.last
    when :oneOf, :anyOf
      # Remove $ref values that contain NPQ.
      swagger_doc.bury(*key, value.reject { |v| npq?(v[:$ref]) })
    when :enum
      # Remove enum values that contain NPQ.
      swagger_doc.bury(*key, value.reject { |v| npq?(v) })
    when :description
      # Remove schemas where the description contains NPQ (e.g. ChangeFundedPlaceDataRequest).
      if key[1] == :schemas
        swagger_doc.dig(*key.first(2)).delete(key[2])
      # Change references of "ECF or NPQ" to just "ECF".
      elsif value.include?("ecf or npq")
        swagger_doc.bury(*key, value.gsub(/ecf or npq/i, "ECF"))
      else
        raise "Unexpected description structure: #{key}"
      end
    else
      raise "Unhandled key: #{key}"
    end
  end

  def npq?(value)
    value.to_s.downcase.include?(SEARCH_TERM)
  end

  def raise_if_npq_references_still_exist!
    raise "NPQ references still present in #{swagger_path}" if swagger_doc.to_s.include?("npq")
  end

  def write_swagger_doc!
    File.open(swagger_path, "w") { |f| f.write(JSON.pretty_generate(swagger_doc)) }
  end
end
