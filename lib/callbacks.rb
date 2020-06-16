# Callbacks for Diff::LCS with insert in left "<" + insert in right ">" instead of replace (!)
module Diff
  module LCS
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
