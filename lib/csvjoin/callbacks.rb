# frozen_string_literal: true

# Callbacks for Diff::LCS with insert in left "<" + insert in right ">" instead of replace (!)
module Diff
  module LCS
    # monkey patching Change for additional behaviour
    class Change
      TRANSLATE_ACTION = { "!": "!==", "-": "==>", "+": "<==", "=": "===" }.freeze
      def joined_row(left, right)
        left_row = old_element.nil? ? left.empty_row : old_element.fields
        right_row = new_element.nil? ? right.empty_row : new_element.fields

        [*left_row, TRANSLATE_ACTION[action.to_sym], *right_row]
      end
    end

    class NoReplaceDiffCallbacks
      # Returns the difference set collected during the diff process.
      attr_reader :diffs

      #:yields self:
      def initialize
        @diffs = []
        yield self if block_given?
      end

      def match(event)
        @diffs << Diff::LCS::ContextChange.simplify(event)
      end

      def discard_a(event)
        @diffs << Diff::LCS::ContextChange.simplify(event)
      end

      def discard_b(event)
        @diffs << Diff::LCS::ContextChange.simplify(event)
      end

      def change(event)
        discard_a(Diff::LCS::ContextChange.new("<", event.old_position, event.old_element, nil, nil))
        discard_b(Diff::LCS::ContextChange.new(">", nil, nil, event.new_position, event.new_element))
        # @diffs << Diff::LCS::ContextChange.simplify(event)
      end
    end
  end
end
