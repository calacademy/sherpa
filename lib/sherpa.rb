require 'citrus'

module Sherpa
  def self.parse string
    Citrus.require File.join File.expand_path(File.dirname __FILE__ ), '..', 'lib/*'
    SherbornGrammar.parse(string).value
  end
end
