# frozen_string_literal: true

# source: https://joshfrankel.me/blog/a-journey-into-writing-union-queries-with-active-record

class ActiveRecordUnion
  attr_reader :relations

  def initialize(*relations)
    @relations = relations
  end

  def call
    raise ArgumentError, "wrong number of arguments (given 0, expected 1+)" if relations.empty?

    unless relations.map(&:table_name).uniq.size == 1
      raise ArgumentError, "type mismatch. All relations must be from the same table"
    end

    mapped_sql = valid_relations
      .map(&:to_sql)
      .join(") UNION (")

    unionized_sql = "((#{mapped_sql})) #{table_name}"

    model.where(id: model.from(unionized_sql))
  end

private

  def table_name
    @table_name ||= relations.first.table_name
  end

  def valid_relations
    @valid_relations ||= relations
      .select do |relation|
        relation.to_sql.present?
      end
  end

  def model
    @model ||= relations.first.klass
  end
end
