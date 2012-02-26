require 'citrus'
require_relative 'progress'
require_relative 'version'

module Sherpa::Preprocessor
  def self.preprocess string
    remove_mismatched_brackets(
    fix_incorrect_closing_parenthesis(
    remove_trailing_comma(
    correct_conch(
      string))))
  end

  def self.fix_incorrect_closing_parenthesis string
    string.gsub /\[([^\]\)]+)\)/, '[\1]'
  end

  def self.correct_conch string
    string.gsub /\bConch,/, 'Conch.'
  end

  def self.remove_trailing_comma string
    return string[0..-2] if string[-1] == ','
    string
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
