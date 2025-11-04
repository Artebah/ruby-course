class TextFormatter
  def format(title, text_lines)
    output = "********** #{title.upcase} **********\n\n"
    text_lines.each_with_index do |line, i|
      output += "#{i + 1}. #{line}\n"
    end
    output += "\n********** END OF REPORT **********"
    output
  end
end

class MarkdownFormatter
  def format(title, text_lines)
    output = "# #{title}\n\n"
    text_lines.each do |line|
      output += "* #{line}\n"
    end
    output
  end
end

class HtmlFormatter
  def format(title, text_lines)
    output = "<html>\n"
    output += "  <head><title>#{title}</title></head>\n"
    output += "  <body>\n"
    output += "    <h1>#{title}</h1>\n"
    output += "    <ul>\n"
    text_lines.each do |line|
      output += "      <li>#{line}</li>\n"
    end
    output += "    </ul>\n"
    output += "  </body>\n"
    output += "</html>"
    output
  end
end

class Report
  attr_accessor :title, :text_lines, :formatter

  def initialize(title, text_lines, formatter_strategy)
    @title = title
    @text_lines = text_lines
    @formatter = formatter_strategy
  end

  def output_report
    @formatter.format(@title, @text_lines)
  end
end


my_data = ["First point", "Second point", "Important conclusion"]

report = Report.new("Monthly Report", my_data, TextFormatter.new)
puts report.output_report
puts "--------------------------------------"

report.formatter = MarkdownFormatter.new
puts report.output_report
puts "--------------------------------------"

report.formatter = HtmlFormatter.new
puts report.output_report



