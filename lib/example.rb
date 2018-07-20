require "ripper"

# _dunno, root = Ripper.sexp(File.read("sample.rb"))

class FactoryCallFinder
  def self.find(root)
    new.find(root)
  end

  def find(node)
    found?(node)
  end

  private

  def found?(node)
    Node.new(node).of_type?(:method_add_arg) &&
      node[1][0] == :fcall &&
      node[1][1][0] == :@ident &&
      node[1][1][1] == "create"
  end
end

class Node
  def initialize(node)
    @type = node[0]
    @meta_data = node[1]
    @children = node[2]
  end

  def of_type?(expected_type)
    type == expected_type
  end

  private

  attr_accessor :type, :meta_data, :children
end

should_match =[:method_add_arg,
   [:fcall, [:@ident, "create", [14, 13]]],
   [:arg_paren,
    [:args_add_block,
     [[:symbol_literal, [:symbol, [:@ident, "subscriber", [14, 21]]]],
      [:symbol_literal, [:symbol, [:@ident, "with_full_subscription", [14, 34]]]],
      [:symbol_literal, [:symbol, [:@ident, "needs_onboarding", [14, 59]]]]],
     false]]]


should_not_match = [:command,
  [:@ident, "sign_in_as", [15, 6]],
  [:args_add_block, [[:var_ref, [:@ident, "user", [15, 17]]]], false]]

tricky_should_not_match = [:method_add_arg,
     [:fcall, [:@ident, "expect", [8, 6]]],
     [:arg_paren, [:args_add_block, [[:vcall, [:@ident, "page", [8, 13]]]], false]]]

[
  [:should_match, should_match, true],
  [:should_not_match, should_not_match, false],
  [:tricky_should_not_match, tricky_should_not_match, false],
].each do |test_name, test_case, expected_result|
  if FactoryCallFinder.find(test_case) == expected_result # - node
    puts "#{test_name} passed!"
  else
    puts "#{test_name} failed! Expected #{expected_result}."
  end
end
