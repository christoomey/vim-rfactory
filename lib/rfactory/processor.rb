# frozen_string_literal: true

module Rfactory
  class Processor < AST::Processor
    attr_accessor :send_nodes

    def self.find_send_nodes(code)
      exp = Parser::CurrentRuby.parse(code)
      ast = new
      ast.process(exp)
      ast.send_nodes
    rescue Parser::SyntaxError
      warn "Syntax Error found while parsing #{file}"
    end

    def handler_missing(node)
      node.children.each do |child|
        process(child) if child.is_a? Parser::AST::Node
      end
    end

    def on_send(node)
      self.send_nodes ||= []
      self.send_nodes << Rfactory::SendNode.new(node)
    end
  end
end
