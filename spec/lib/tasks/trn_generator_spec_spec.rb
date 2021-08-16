# frozen_string_literal: true

require "tasks/trn_generator"
require "rails_helper"

RSpec.describe TRNGenerator, type: :helper do
  it 'produces a new unassigned value' do
    expect(::TeacherProfile.pluck(:trn)).not_to include(TRNGenerator.next)
  end

  it "generates 100_000 unallocated TRNs in under a second" do
    benchmark = Benchmark.measure {
      100_000.times do
        TRNGenerator.next
      end
    }
    expect(benchmark.total).to be < 1
  end

  it "moves the new TRN to unavailable" do
    before_counts=[TRNGenerator.send(:available).count, TRNGenerator.send(:taken).count]
    TRNGenerator.next
    TRNGenerator.next
    after_counts=[TRNGenerator.send(:available).count, TRNGenerator.send(:taken).count]
    expect(after_counts[0]-before_counts[0]).to eq -2
    expect(after_counts[1]-before_counts[1]).to eq 2
  end
end
