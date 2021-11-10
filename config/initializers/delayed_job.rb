# frozen_string_literal: true

Delayed::Worker.queue_attributes = {
  mailers: { priority: 1 },
  priority_mailers: { priority: -10 },
}
