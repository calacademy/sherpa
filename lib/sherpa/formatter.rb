module Sherpa::Formatter
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
      for column in [:title, :volume, :date, :pages] do
        cells =  make_value_cells citation, column
        our_cells << cells[:us]
        their_cells << cells[:them]
      end

      string << <<-EOS
      <table class="citation">
        <tr>
          <td class="citation">#{citation[:citation]}</td>
        </tr>
      </table>
      EOS

      string << '<table>'
        string << '<tr>' << our_cells.join << '</tr>'
        string << '<tr>' << their_cells.join << '</tr>' unless our_cells.join == their_cells.join
      string << '</table>'

    end
    string << "</body></html>"
  end

  def self.make_value_cells citation, field
    them = citation[:them][field]
    us = citation[:citations].first[field]
    different = us != them
    css_classes = [different ? 'different' : 'same']
    css_classes << field.to_s
    css_classes << 'value'
    css_classes = css_classes.join ' '
    {us:   %{<td class="#{css_classes}">#{us}</td>},
      them: %{<td class="#{css_classes}">#{them}</td>},
      different: different}
  end
end
