require "ripper"
require "pry"

# _dunno, root = Ripper.sexp(File.read("sample.rb"))

class FactoryCallFinder
  def self.find(root)
    new.find(root)
  end

  def find(node)
    if found?(node)
      node
    else
      node.children.detect do |child_node|
        find(child_node)
      end
    end
  end

  private

  def found?(node)
    node.of_type?(:method_add_arg) &&
      node.meta_data_of_type?(:fcall) &&
      node.meta_data_of_child_type?(:@ident) &&
      node.meta_data_with_content?("create")
  end
end

class MetaData
  def initialize(meta_data)
    @parent_type = meta_data[0]
    @child_type = meta_data[1][0]
    @content = meta_data[1][1]
    @location = meta_data[1][2]
  end

  def of_type?(expected_type)
    parent_type == expected_type
  end

  def of_child_type?(expected_type)
    child_type == expected_type
  end

  def with_content?(expected_content)
    content == expected_content
  end

  private

  attr_accessor :content, :location, :parent_type, :child_type
end

class Node
  attr_accessor :children

  def initialize(node)
    @type = node[0]
    binding.pry
    @meta_data = MetaData.new(node[1])
    @children = node[2].map do |child_node|
      Node.new(child_node)
    end
    @raw_node = node
  end

  def of_type?(expected_type)
    type == expected_type
  end

  def meta_data_of_type?(expected_type)
    meta_data.of_type?(expected_type)
  end

  def meta_data_of_child_type?(expected_type)
    meta_data.of_child_type?(expected_type)
  end

  def meta_data_with_content?(expected_content)
    meta_data.with_content?(expected_content)
  end

  def ==(other_node)
    raw_node == other_node.raw_node
  end

  protected

  attr_accessor :raw_node

  private

  attr_accessor :type, :meta_data
end

should_match = [:method_add_arg,
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

nested_should_match = [:bodystmt,
         [[:assign,
           [:var_field, [:@ident, "user", [14, 6]]],
           [:method_add_arg,
            [:fcall, [:@ident, "create", [14, 13]]],
            [:arg_paren,
             [:args_add_block,
              [[:symbol_literal, [:symbol, [:@ident, "subscriber", [14, 21]]]],
               [:symbol_literal, [:symbol, [:@ident, "with_full_subscription", [14, 34]]]],
               [:symbol_literal, [:symbol, [:@ident, "needs_onboarding", [14, 59]]]]],
              false]]]],
          [:command,
           [:@ident, "sign_in_as", [15, 6]],
           [:args_add_block, [[:var_ref, [:@ident, "user", [15, 17]]]], false]],
          [:command,
           [:@ident, "visit", [17, 6]],
           [:args_add_block, [[:vcall, [:@ident, "root_path", [17, 12]]]], false]],
          ]]

[
  [:should_match, should_match, Node.new(should_match)],
  [:should_not_match, should_not_match, nil],
  [:tricky_should_not_match, tricky_should_not_match, nil],
  [:nested_should_match, nested_should_match, Node.new(should_match)],
].each do |test_name, test_case, expected_result|
  if FactoryCallFinder.find(Node.new(test_case)) == expected_result # - node
    puts "#{test_name} passed!"
  else
    puts "#{test_name} failed! Expected #{expected_result}."
  end
end
