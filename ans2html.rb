require 'htmlentities'
require 'strscan'
require 'stringio'

class String
    AnsiColor = {
        "1" => "bold",
        "4" => "underline",
        "30" => "black",
        "31" => "red",
        "32" => "green",
        "33" => "yellow",
        "34" => "blue",
        "35" => "magenta",
        "36" => "cyan",
        "37" => "white",
        "40" => "bg-black",
        "41" => "bg-red",
        "42" => "bg-green",
        "43" => "bg-yellow",
        "44" => "bg-blue",
        "45" => "bg-magenta",
        "46" => "bg-cyan",
        "47" => "bg-white",
    }
end

class String
    def ansi2html
        ansi = StringScanner.new(self)
        html = StringIO.new
        until ansi.eos?
            if ansi.scan(/\&\#26\;.*/)
            	html.print(%{})
            elsif ansi.scan(/\e\[0?m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="#{AnsiColor["37"]} #{AnsiColor["40"]}">#{ansi[1]}</span>})
            elsif ansi.scan(/\e\[0;(\d+);(\d+)m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="#{AnsiColor[ansi[2]]} #{AnsiColor[ansi[1]]}">#{ansi[3]}</span>})
            elsif ansi.scan(/\e\[1;(\d+);(\d+)m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="bold-#{AnsiColor[ansi[2]]} #{AnsiColor[ansi[1]]}">#{ansi[3]}</span>})
            elsif ansi.scan(/\e\[0;(\d+)m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="#{AnsiColor[ansi[1]]}">#{ansi[2]}</span>})
            elsif ansi.scan(/\e\[1;(\d+)m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="bold-#{AnsiColor[ansi[1]]}">#{ansi[2]}</span>})
            elsif ansi.scan(/\e\[(\d+);(\d+)m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="#{AnsiColor[ansi[1]]} #{AnsiColor[ansi[2]]}">#{ansi[3]}</span>})
            elsif ansi.scan(/\e\[(\d+)m([^\e]*)(?=\e|$)/)
                html.print(%{<span class="#{AnsiColor[ansi[1]]}">#{ansi[2]}</span>})
            elsif ansi.scan(/\e\[([\d;]+)m([^\e]*)(?=\e|$)/)
                html.print(%{})
            elsif ansi.scan(/\e\[(\d+)C/)
            	i = 1
            	begin
            		html.print(%{&nbsp;})
            		i += 1
            	end until i > ansi[1].to_i
            else
                html.print(ansi.scan(/./m))
            end
        end
        html.string
    end
end

fn = ARGV.first
coder = HTMLEntities.new
content = ''

File.open(fn, "rb:ibm437") do |f|
	loop do
		break if not buf = f.gets(nil, 1)
		if (buf.ord > 126 || buf.ord < 32) && buf.ord != 27 && buf.ord != 13 && buf.ord != 10
			content += coder.encode(buf, :decimal)
		else
			content += buf
		end
	end
end

content.gsub!(/\r/, '<br>')
content.gsub!(/\s/, '&nbsp;')
content.gsub!(/\&\#26\;.*/, '')
content = content.ansi2html
print ""
print %{
<html><head>
	<style>
		.black 		{color: #000000}
		.red 		{color: #800000}
		.green		{color: #008000}
		.yellow 	{color: #808000}
		.blue		{color: #000080}
		.magenta 	{color: #800080}
		.cyan 		{color: #008080}
		.white		{color: #c0c0c0}

		.bold-black 	{color: #606060}
		.bold-red 		{color: #ff0000}
		.bold-green		{color: #00ff00}
		.bold-yellow 	{color: #ffff00}
		.bold-blue		{color: #0000ff}
		.bold-magenta 	{color: #ff00ff}
		.bold-cyan 		{color: #00ffff}
		.bold-white		{color: #ffffff}

		.bg-black 		{background-color: #000000}
		.bg-red 		{background-color: #800000}
		.bg-green		{background-color: #008000}
		.bg-yellow 	    {background-color: #808000}
		.bg-blue		{background-color: #000080}
		.bg-magenta 	{background-color: #800080}
		.bg-cyan 		{background-color: #008080}
		.bg-white		{background-color: #c0c0c0}

pre {
	white-space: pre;           /* CSS 2.0 */
	white-space: pre-wrap;      /* CSS 2.1 */
	white-space: pre-line;      /* CSS 3.0 */
	white-space: -pre-wrap;     /* Opera 4-6 */
	white-space: -o-pre-wrap;   /* Opera 7 */
	white-space: -moz-pre-wrap; /* Mozilla */
	white-space: -hp-pre-wrap;  /* HP Printers */
	word-wrap: break-word;      /* IE 5+ */
	}
</style>
</head><body><pre style="color: #ccc; background: #000; width: 640px;">
}
print content
# print "<br>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# print "</pre><img src=\"http://planettelex.org/img/logo.png\"></body></html>"
# print coder.encode(content, :decimal)