require 'citrus'
require_relative 'progress'
require_relative 'version'

module Sherpa::Preprocessor
  def self.preprocess string
    fix_space_after_hyphen(
    remove_mismatched_brackets(
    fix_incorrect_closing_parenthesis(
    remove_trailing_comma(
    fix_typos(
      string)))))
  end

  def self.fix_incorrect_closing_parenthesis string
    string.gsub /\[([^\]\)]+)\)/, '[\1]'
  end

  def self.fix_typos string
    string = string.gsub /\bConch,/, 'Conch.'
    string = string.gsub /\bpi\./, 'pl.'
    string = string.gsub /\bhist,/, 'hist.'
    string
  end

  def self.fix_space_after_hyphen string
    return string
    string.gsub /- (\d)/, '- \1'
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
