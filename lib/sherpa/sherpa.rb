require 'citrus'
require_relative 'progress'
require_relative 'version'
require_relative 'preprocessor'

module Sherpa

  module Parser
    def self.parse string, options = {}
      require_grammars
      string = Preprocessor.preprocess string
      SherbornGrammar.parse(string, options).value
    end
    def self.require_grammars
      unless defined? SherbornGrammar
        Citrus.require File.join File.expand_path(File.dirname __FILE__ ), '*'
      end
    end
  end

  module Formatter
    def self.format_comparisons citations
      string = <<-EOS
      <html>
        <head>
          <meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head>
          <link href="sherpa.css" media="screen" rel="stylesheet" type="text/css" />
        </head>
        <body>
      EOS
      for citation in citations.sort_by{|a| a[:citation]}.uniq
        our_cells = []
        their_cells = []
        any_different = false
        for column in [:title, :volume, :date, :pages] do
          cells =  make_value_cells citation, column
          our_cells << cells[:us]
          their_cells << cells[:them]
          any_different ||= cells[:different]
        end

        string << <<-EOS
        <table class="citation">
          <tr>
            <td class="citation">#{citation[:citation]}</td>
          </tr>
        </table>
        EOS

        string << '<table>'
          string << "<tr>"
          for cell in our_cells
            string << cell
          end
          string << "</tr>"

          string << "<tr>"
          for cell in their_cells
            string << cell
          end
          string << "</tr>"
        string << '</table>'

      end
      string << "</body></html>"
    end

    def self.make_value_cells citation, field
      them = citation[:them][field]
      us = citation[:citations].first[field]
      both_blank = (them || '') == '' && (us || '') == ''
      different = us != them
      css_classes = [different ? 'different' : both_blank ? 'both_blank' : 'same']
      css_classes << field.to_s
      css_classes << 'value'
      css_classes = css_classes.join ' '
      {us:   %{<td class="#{css_classes}">#{us}</td>},
       them: %{<td class="#{css_classes}">#{them}</td>},
       different: different}
    end
  end

end
