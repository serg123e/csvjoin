# frozen_string_literal: true

module Diff
  module LCS
    # Callbacks for Diff::LCS with insert in left "<" + insert in right ">" instead of replace (!)
    class NoReplaceDiffCallbacks
      # Returns the difference set collected during the diff process.
      attr_reader :diffs

      # :yields self:
      def initialize
        @diffs = []
        yield self if block_given?
      end

      def match(event)
        @diffs << Diff::LCS::ContextChange.simplify(event)
      end
      alias discard_a match
      alias discard_b match

      def change(event)
        match(Diff::LCS::ContextChange.new("<", event.old_position, event.old_element, nil, nil))
        match(Diff::LCS::ContextChange.new(">", nil, nil, event.new_position, event.new_element))
      end
    end
  end
end
