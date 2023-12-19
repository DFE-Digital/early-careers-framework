# frozen_string_literal: true

class InductionRecordHistory
  class NoRecordsFound < StandardError; end

  attr_reader :size

  def initialize(participant_profile:)
    @head   = nil
    @tail   = nil
    @size = 0

    parse_induction_records(participant_profile)
  end

  def first
    @head && @head.record
  end

  def last
    @tail && @tail.record
  end

  def add(record)
    node = Node.new(record)
    @head ||= node

    if @tail
      @tail.next = node
      node.previous = @tail
    end

    @tail = node

    @size += 1
    self
  end

  def delete(node)
    delete_record(node)
    fix_records_sequence(node)
    unlink_node(node)
    return node.record
  end

  def each
    curr_node = @head

    while(curr_node)
      yield curr_node.record
      curr_node = curr_node.next
    end
  end

  def to_a
    to_enum(:each).to_a
  end

private

  class Node
    attr_accessor :record, :next, :previous

    def initialize(record)
      @record = record
      @next = nil
      @previous = nil
    end
  end

  def parse_induction_records(participant_profile)
    return NoRecordsFound if participant_profile.induction_records.blank?

    participant_profile
      .induction_records
      .order(start_date: :desc, created_at: :desc)
      .each do |induction_record|
        add(induction_record)
      end
  end

  def delete_record(node)
    node.record.destroy
  end

  def fix_records_sequence(node)
    node.previous.record.update(end_date: node.next.record.start_date) if node.previous
  end

  def unlink_node(node)
    @head = node.next if node.previous.nil?
    @tail = node.previous if node.next.nil?

    if node.previous.nil?
      node.next.previous = nil if node.next
    elsif node.next.nil?
      node.previous.next = nil if node.previous
    else
      node.previous.next = node.next
      node.next.previous = node.previous
    end
    @size -= 1
  end
end
