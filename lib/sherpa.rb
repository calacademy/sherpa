require 'citrus'

module Sherpa

  def self.parse string
    Citrus.require File.join File.expand_path(File.dirname __FILE__ ), '..', 'lib/*'
    SherbornGrammar.parse(preprocess string).value
  end

  def self.preprocess string
    remove_mismatched_brackets string
  end

  # copied from AntCat
  def self.remove_mismatched_brackets string
    remove_mismatched string, '(', ')'
    remove_mismatched string, '[', ']'
  end

  def self.remove_mismatched string, open, close
    open_bracket_positions = []
    unopened_bracket_positions = []

    string.length.times do |position|
      char = string[position,1]
      if char == open
        open_bracket_positions.push position
      elsif char == close
        unless open_bracket_positions.empty?
          open_bracket_positions.pop
        else
          unopened_bracket_positions.push position
        end
      end
    end

    for position in open_bracket_positions.concat(unopened_bracket_positions).sort.reverse
      string[position,1] = ''
    end

    string
  end

end
