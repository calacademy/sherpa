require 'citrus'
require_relative 'progress'
require_relative 'sherpa/version'

module Sherpa

  module Parser
    def self.parse string
      Citrus.require File.join File.expand_path(File.dirname __FILE__ ), '..', 'lib/*'
      SherbornGrammar.parse(Preprocessor.preprocess string).value
    end
  end

  module Preprocessor
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
  end

  module Comparer
    def self.compare_us_and_them citation
      us = citation[:citations] && citation[:citations].first
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

  module Formatter
    def self.format_comparisons citations
      string = <<-EOS
      <html>
        <head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head>
      <body>
        <style>
          .same {
            background: lightgreen;
          }
          .different {
            background: lightpink;
          }
          .citation {
            width: 400px;
          }
          td {
            min-width: 50px;
          }
        </style>
        <table style='width: 500px'>
      EOS
      for citation in citations
        our_cells = []
        their_cells = []
        any_different = false
        for column in [:title, :series_volume_issue, :volume, :number, :date, :pages] do
          entry = make_entry citation, column
          our_cells << entry[:us]
          their_cells << entry[:them]
          any_different ||= entry[:different]
        end

        string << '<table>'
        css_class = (any_different ? 'different' : 'same') + ' citation'
        string << <<-EOS
        <tr class="#{css_class}">
          <td></td>
          <td colspan=100>#{citation[:citation]}</td>
        </tr>
        EOS

        string << "<tr><td>Us</td>"
        for cell in our_cells
          string << cell
        end
        string << "</tr>"

        string << "<tr><td>Them</td>"
        for cell in their_cells
          string << cell
        end
        string << "</tr>"
        string << '</table>'
      end
      string << "</table></html></body>"
    end

    def self.make_entry citation, field
      them = citation[:them][field]
      us = citation[:citations].first[field]
      different = us != them
      css_class = different ? "different" : "same"
      {us: "<td class=#{css_class}>#{us}</td>", them: "<td class=#{css_class}>#{them}</td>", different: different}
    end
  end

end
