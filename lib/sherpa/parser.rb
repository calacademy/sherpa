require 'citrus'
require_relative 'preprocessor'

module Sherpa::Parser

  def self.parse string, options = {}
    require_grammars
    string = Sherpa::Preprocessor.preprocess string
    SherbornGrammar.parse(string, options).value
  end

  def self.require_grammars
    unless defined? SherbornGrammar
      Citrus.require File.join File.expand_path(File.dirname __FILE__ ), '*'
    end
  end

end
