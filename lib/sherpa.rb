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
