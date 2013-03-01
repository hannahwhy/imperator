module Imperator
  module Visitation
    def visit(root, level = 0, prev = nil, &block)
      yield root, level, prev, :enter
      root.children.each { |c| visit(c, level + 1, root, &block) }
      yield root, level, prev, :exit
    end
  end
end
