# frozen_string_literal: true

module Rfactory
  class FactoryFinder
    def self.find(source, cursor_row, cursor_column)
      new.find(source, cursor_row, cursor_column)
    end

    def self.find_in_file(file_name, cursor_row, cursor_column)
      source = File.read(file_name)

      new.find(source, cursor_row, cursor_column)
    end

    def find(source, cursor_row, cursor_column)
      node = node_at_location(factory_calls(source), cursor_row, cursor_column)

      node.factory_name
    end

    def factory_calls(source)
      send_nodes = Processor.find_send_nodes(source)

      send_nodes.select(&:building_factory?)
    end

    private

    def node_at_location(send_nodes, row, column)
      send_nodes.detect do |send_node|
        send_node.at_cursor_location?(row, column)
      end
    end
  end
end
