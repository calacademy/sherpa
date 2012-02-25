require 'citrus'

module Sherpa

  def self.parse string
    Citrus.require File.join File.expand_path(File.dirname __FILE__ ), '..', 'lib/*'
    SherbornGrammar.parse(preprocess string).value
  end

  def self.preprocess string
    remove_mismatched_brackets(
    remove_trailing_comma(
      string))
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

  def self.compare_us_to_them citation
    comparison = {}
    us = citation[:citations].first
    return {} unless us
    them = citation[:them]
    return {} unless them

    our_title = us[:title]
    their_title = them && them[:title]
    comparison[:title] = our_title == their_title ? :same : :different if our_title || their_title
    comparison.empty? ? {} : {comparison: comparison}

    our_date = us[:date]
    their_date = them && them[:date]
    comparison[:date] = our_date == their_date ? :same : :different if our_date || their_date
    comparison.empty? ? {} : {comparison: comparison}

  end

end
