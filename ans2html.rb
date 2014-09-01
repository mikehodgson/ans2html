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
content.gsub!(/\r/, '<br>').gsub!(/\s/, '&nbsp;')
content = content.ansi2html

# Print the output!
print %{
<html><head>
	<style>
		body,html {
			background-color: #000;
		}

		.fg-black 		{color: #000000}
		.fg-red 		{color: #aa0000}
		.fg-green		{color: #00aa00}
		.fg-yellow 	{color: #aa5500}
		.fg-blue		{color: #0000aa}
		.fg-magenta 	{color: #aa00aa}
		.fg-cyan 		{color: #00aaaa}
		.fg-white		{color: #c0c0c0}

		.bold-fg-black 	{color: #606060}
		.bold-fg-red 		{color: #ff5555}
		.bold-fg-green		{color: #00ff00}
		.bold-fg-yellow 	{color: #ffff00}
		.bold-fg-blue		{color: #0000ff}
		.bold-fg-magenta 	{color: #ff55ff}
		.bold-fg-cyan 		{color: #55ffff}
		.bold-fg-white		{color: #ffffff}

		.bg-black 		{background-color: #000000}
		.bg-red 		{background-color: #aa0000}
		.bg-green		{background-color: #00aa00}
		.bg-yellow 	    {background-color: #aa5500}
		.bg-blue		{background-color: #0000aa}
		.bg-magenta 	{background-color: #aa00aa}
		.bg-cyan 		{background-color: #00aaaa}
		.bg-white		{background-color: #c0c0c0}

		.bold-bg-black 		{background-color: #606060}
		.bold-bg-red 		{background-color: #ff5555}
		.bold-bg-green		{background-color: #00ff00}
		.bold-bg-yellow 	{background-color: #ffff00}
		.bold-bg-blue		{background-color: #0000ff}
		.bold-bg-magenta 	{background-color: #ff55ff}
		.bold-bg-cyan 		{background-color: #55ffff}
		.bold-bg-white		{background-color: #ffffff}

		pre {
			white-space: pre;           /* CSS 2.0 */
			white-space: pre-wrap;      /* CSS 2.1 */
			white-space: pre-line;      /* CSS 3.0 */
			white-space: -pre-wrap;     /* Opera 4-6 */
			white-space: -o-pre-wrap;   /* Opera 7 */
			white-space: -moz-pre-wrap; /* Mozilla */
			white-space: -hp-pre-wrap;  /* HP Printers */
			word-wrap: break-word;      /* IE 5+ */
			line-height: 15px;
			font-size: 15px;
			letter-spacing: 0px;
		}
</style>
</head>
<body>
	<pre style="color: #ccc; background: #000; width: 720px; margin:auto; float: none;">
		#{content}
	</pre>
</body>
</html>
}