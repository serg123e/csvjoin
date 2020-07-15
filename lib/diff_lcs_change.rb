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
  end
end
