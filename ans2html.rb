require 'htmlentities'
require 'strscan'
require 'stringio'

class String
    AnsiColor = {
        "30" => "fg-black",
        "31" => "fg-red",
        "32" => "fg-green",
        "33" => "fg-yellow",
        "34" => "fg-blue",
        "35" => "fg-magenta",
        "36" => "fg-cyan",
        "37" => "fg-white",
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
        numOpen = 0
        fg = "fg-white"
        bg = "bg-black"
        fgbold = false
        bgbold = false
        until ansi.eos?
            if ansi.scan(/SAUCE00.*/)
            	html.print(%{})
        	elsif ansi.scan(/\e\[([\d;]+)m/)
        		fgboldstr = ''
        		bgboldstr = ''
        		if ansi[1] == '0'
        			fgbold = false
        			bgbold = false
        			bg = 'bg-black'
        			fg = 'fg-white'
        		else
	 				ansi[1].split(/\;/).each do |code|
	 					case code.to_i
		 					when 0
			        			fgbold = false
			        			bgbold = false
			        			bg = 'bg-black'
			        			fg = 'fg-white'
		 					when 1
		 						fgbold = true
		 					when 5
		 						bgbold = true
		 					when 30..37
		 						fg = AnsiColor[code]
		 					when 40..47
		 						bg = AnsiColor[code]
		 					else
		 						puts "missing code: #{code}"
		 				end
	 				end
        		end
 				if fgbold
 					fgboldstr = 'bold-'
 				end
 				if bgbold
 					bgboldstr = 'bold-'
 				end
                html.print(%{</span><span class="#{fgboldstr}#{fg} #{bgboldstr}#{bg}">})
            elsif ansi.scan(/\e\[m/)
    			fg = "fg-white"
		        bg = "bg-black"
                fgbold = false
                bgbold = false
                html.print(%{</span><span class="#{fg} #{bg}">})
            elsif ansi.scan(/\e\[(\d+)C/)
            	i = 1
            	begin
            		html.print(%{&nbsp;})
            		i += 1
            	end until i > ansi[1].to_i
            elsif ansi.scan(/\e\[C/)
				html.print(%{&nbsp;})
            elsif ansi.scan(/\e\[[\d;\?]+[a-zA-Z]/)
				html.print(%{})
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

# Open file, explicitly select IBM Codepage 437
File.open(fn, "rb:ibm437") do |f|
	loop do
		break if not buf = f.gets(nil, 1)
		# Don't encode characters we'll need later.
		if (buf.ord > 126 || buf.ord < 32) && buf.ord != 27 && buf.ord != 13 && buf.ord != 10
			content += coder.encode(buf, :decimal)
		else
			content += buf
		end
	end
end

# Convert carriage returns & spaces, remove SAUCE, convert to HTML!
content.gsub!(/\r/, '<br>').gsub!(/\s/, '&nbsp;').gsub!(/\n/, '')
content = content.ansi2html
content.gsub!(/\<span ([^>]*)>([^>]*)\<br\>([^<]*)\<\/span\>/, '<span \1>\2</span><br><span \1>\3</span>')

# Print the output!
print %{
<!DOCTYPE html>
<html>
<head>
	<style>
		.ansi br {
			line-height: 0%;
		}

		.ansi .fg-black 	{color: #000000}
		.ansi .fg-red 		{color: #aa0000}
		.ansi .fg-green		{color: #00aa00}
		.ansi .fg-yellow 	{color: #aa5500}
		.ansi .fg-blue		{color: #0000aa}
		.ansi .fg-magenta 	{color: #aa00aa}
		.ansi .fg-cyan 		{color: #00aaaa}
		.ansi .fg-white		{color: #c0c0c0}

		.ansi .bold-fg-black 	{color: #606060}
		.ansi .bold-fg-red 		{color: #ff5555}
		.ansi .bold-fg-green	{color: #00ff00}
		.ansi .bold-fg-yellow 	{color: #ffff00}
		.ansi .bold-fg-blue		{color: #0000ff}
		.ansi .bold-fg-magenta 	{color: #ff55ff}
		.ansi .bold-fg-cyan		{color: #55ffff}
		.ansi .bold-fg-white	{color: #ffffff}

		.ansi .bg-black		{background-color: #000000}
		.ansi .bg-red 		{background-color: #aa0000}
		.ansi .bg-green		{background-color: #00aa00}
		.ansi .bg-yellow    {background-color: #aa5500}
		.ansi .bg-blue		{background-color: #0000aa}
		.ansi .bg-magenta 	{background-color: #aa00aa}
		.ansi .bg-cyan 		{background-color: #00aaaa}
		.ansi .bg-white		{background-color: #c0c0c0}

		.ansi .bold-bg-black	{background-color: #606060}
		.ansi .bold-bg-red 		{background-color: #ff5555}
		.ansi .bold-bg-green	{background-color: #00ff00}
		.ansi .bold-bg-yellow 	{background-color: #ffff00}
		.ansi .bold-bg-blue		{background-color: #0000ff}
		.ansi .bold-bg-magenta 	{background-color: #ff55ff}
		.ansi .bold-bg-cyan		{background-color: #55ffff}
		.ansi .bold-bg-white	{background-color: #ffffff}

		pre.ansi {
			background-color: #000;
			white-space: pre;           /* CSS 2.0 */
			white-space: pre-wrap;      /* CSS 2.1 */
			white-space: pre-line;      /* CSS 3.0 */
			white-space: -pre-wrap;     /* Opera 4-6 */
			white-space: -o-pre-wrap;   /* Opera 7 */
			white-space: -moz-pre-wrap; /* Mozilla */
			white-space: -hp-pre-wrap;  /* HP Printers */
			word-wrap: break-word;      /* IE 5+ */
			font-family: monospace;
			line-height: 15px;
			font-size: 15px;
			letter-spacing: 0px;
			padding: 0px;
			margin: auto;
			float: none;
			width: 721px;
		}

		.ansi span {
			margin-bottom: 0px;
			padding: 0px;
			height: 15px;
			line-height: 15px;
		}
</style>
</head>
<body>
	<pre class="ansi">
		#{content}
	</pre>
</body>
</html>
}