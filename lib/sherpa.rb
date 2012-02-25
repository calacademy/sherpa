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
    us = citation[:citations].first
    return {} unless us
    them = citation[:them]
    return {} unless them

    comparison = {}
    comparison.merge! compare_our_field_to_their_field :title, us, them
    comparison.merge! compare_our_field_to_their_field :date, us, them
    comparison.merge! compare_our_field_to_their_field :pages, us, them
    comparison.merge! compare_our_series_volume_issue_to_theirs us, them
    comparison.empty? ? {} : {comparison: comparison}
  end

  def self.compare_our_series_volume_issue_to_theirs us, them
    our_series_volume_issue = us[:series_volume_issue]
    their_volume = them[:volume]
    their_number = them[:number]
    return {} unless our_series_volume_issue || their_volume || their_number
    their_series_volume_issue = ''
    if their_volume
      their_series_volume_issue << their_volume
    end
    if their_number
      if !their_series_volume_issue.empty?
        their_series_volume_issue << ' '
      end
      their_series_volume_issue << their_number
    end
    {series_volume_issue: our_series_volume_issue == their_series_volume_issue ? :same : :different}
  end

  def self.compare_our_field_to_their_field field, us, them
    our_field = us[field]
    their_field = them && them[field]
    return {} unless our_field || their_field
    {field => our_field == their_field ? :same : :different}
  end

end
