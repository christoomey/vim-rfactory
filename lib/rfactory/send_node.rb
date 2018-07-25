# frozen_string_literal: true

module Rfactory
  class SendNode
    def initialize(node)
      @node = node
      @receiver_node = node.to_a[0]
      @method_name = node.to_a[1]
      @arg_nodes = node.to_a[2]
    end

    def building_factory?
      method_name.to_sym == :create
    end

    def at_cursor_location?(row, column)
      rows.include?(row) && columns.include?(column)
    end

    def factory_name
      arg_nodes.children.first if building_factory?
    end

    private

    attr_accessor :node, :receiver_node, :method_name, :arg_nodes

    def location
      node.loc
    end

    def columns
      location.column..location.last_column
    end

    def rows
      location.first_line..location.last_line
    end
  end
end
