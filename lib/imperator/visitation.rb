module Imperator
  module Visitation
    def visit(root, only_enter = false, level = 0, prev = nil, &block)
      yield root, level, prev, :enter
      root.children.each { |c| visit(c, only_enter, level + 1, root, &block) }

      unless only_enter
        yield root, level, prev, :exit
      end
    end
  end
end
