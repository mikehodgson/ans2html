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
        numOpen = 0
        foreground = "white"
        background = "bg-black"
        bold = false
        boldbg = false
        until ansi.eos?
            if ansi.scan(/\&\#26\;.*/)
            	html.print(%{})
        	elsif ansi.scan(/\e\[0m/)
            	for i in 1..numOpen
            		html.print(%{</span>})
            	end
    			foreground = "white"
		        background = "bg-black"
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                numOpen = 1
            elsif ansi.scan(/\e\[0\;5\m/)
	   	        foreground = foreground.gsub!(/bold-/,'')
	   	        background = 'bold-' + background
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[0\;1\m/)
            	if !bold
	   	        	foreground = 'bold-' + foreground
	   	        end
                html.print(%{<span class="#{foreground}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[0\;5\;(3\d)m/)
	   	        foreground = "#{AnsiColor[ansi[1]]}"
	   	        background = 'bold-' + background
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[0\;5\;(4\d)m/)
	   	        background = "bold-#{AnsiColor[ansi[1]]}"
	   	        if bold
	   	        	foreground = foreground.gsub!(/bold-/,'')
	   	        end
                html.print(%{<span class="#{background} #{foreground}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[1\;5\;(3\d)m/)
	   	        foreground = "bold-#{AnsiColor[ansi[1]]}"
	   	        background = 'bold-' + background
                html.print(%{<span class="#{foreground} #{background}">})
                bold = true
                numOpen += 1
            elsif ansi.scan(/\e\[1\;5\;(4\d)m/)
	   	        background = "bold-#{AnsiColor[ansi[1]]}"
	   	        if !bold
	   	        	foreground = "bold-" + foreground
	   	        end
                html.print(%{<span class="#{foreground} #{background}">})
                bold = true
                numOpen += 1
            elsif ansi.scan(/\e\[5\;(3\d)m/)
            	if bold
		   	        foreground = "bold-#{AnsiColor[ansi[1]]}"
            	else
	   		        foreground = "#{AnsiColor[ansi[1]]}"
            	end
            	background = "bold-" + background;
                html.print(%{<span class="#{foreground} #{background}">})
                numOpen += 1
            elsif ansi.scan(/\e\[5\;(4\d)m/)
	   	        background = "bold-#{AnsiColor[ansi[1]]}"
   	            html.print(%{<span class="#{background}">})
                numOpen += 1
            elsif ansi.scan(/\e\[5\;(3\d);(4\d)m/)
            	if bold
		   	        foreground = "bold-#{AnsiColor[ansi[1]]}"
		   	        background = "bold-#{AnsiColor[ansi[2]]}"
	                html.print(%{<span class="#{foreground} #{background}">})
            	else
		   	        foreground = "#{AnsiColor[ansi[1]]}"
		   	        background = "bold-#{AnsiColor[ansi[2]]}"
	                html.print(%{<span class="#{foreground} #{background}">})
            	end
                numOpen += 1
            elsif ansi.scan(/\e\[5\;(4\d);(3\d)m/)
            	if bold
		   	        foreground = "bold-#{AnsiColor[ansi[2]]}"
		   	        background = "bold-#{AnsiColor[ansi[1]]}"
	                html.print(%{<span class="#{foreground} #{background}">})
            	else
		   	        foreground = "#{AnsiColor[ansi[2]]}"
		   	        background = "bold-#{AnsiColor[ansi[1]]}"
	                html.print(%{<span class="#{foreground} #{background}">})
            	end
                numOpen += 1
            elsif ansi.scan(/\e\[0\;5\;(3\d);(4\d)m/)
	   	        foreground = "#{AnsiColor[ansi[1]]}"
	   	        background = "bold-#{AnsiColor[ansi[2]]}"
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[0;5\;(4\d);(3\d)m/)
	   	        foreground = "#{AnsiColor[ansi[2]]}"
	   	        background = "bold-#{AnsiColor[ansi[1]]}"
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[0\;1\;(3\d);(4\d)m/)
	   	        foreground = "bold-#{AnsiColor[ansi[1]]}"
	   	        if boldbg
		   	        background = "bold-#{AnsiColor[ansi[2]]}"
	   	        else
		   	        background = "#{AnsiColor[ansi[2]]}"
	   	        end
                html.print(%{<span class="#{foreground} #{background}">})
                bold = true
                numOpen += 1
            elsif ansi.scan(/\e\[0\;1\;(4\d);(3\d)m/)
	   	        foreground = "bold-#{AnsiColor[ansi[2]]}"
	   	        if boldbg
	   	        	background = "bold-#{AnsiColor[ansi[1]]}"
	   	        else
	   	        	background = "#{AnsiColor[ansi[1]]}"
	   	        end
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                numOpen += 1
            elsif ansi.scan(/\e\[0\;1\;(3\d)m/)
	   	        foreground = "bold-#{AnsiColor[ansi[1]]}"
                html.print(%{<span class="#{foreground}">})
                bold = true
                numOpen += 1
            elsif ansi.scan(/\e\[0\;(4\d)\;(3\d)m/)
            	for i in 1..numOpen
            		html.print(%{</span>})
            	end
                html.print(%{<span class="#{AnsiColor[ansi[2]]} #{AnsiColor[ansi[1]]}">})
   	            foreground = AnsiColor[ansi[2]]
	            background = AnsiColor[ansi[1]]
                numOpen = 1
                bold = false
                boldbg = false
            elsif ansi.scan(/\e\[1\;(4\d)\;(3\d)m/)
            	for i in 1..numOpen
            		html.print(%{</span>})
            	end
                html.print(%{<span class="bold-#{AnsiColor[ansi[2]]} #{AnsiColor[ansi[1]]}">})
   	            foreground = "bold-#{AnsiColor[ansi[2]]}"
	   	        if boldbg
	   	        	background = "bold-#{AnsiColor[ansi[1]]}"
	   	        else
	   	        	background = "#{AnsiColor[ansi[1]]}"
	   	        end
                numOpen = 1
                bold = true
            elsif ansi.scan(/\e\[0\;(3\d)m/)
	   	        foreground = "#{AnsiColor[ansi[1]]}"
	   	        background = "bg-black"
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                boldbg = false
                numOpen += 1
            elsif ansi.scan(/\e\[0\;(4\d)m/)
	   	        background = "#{AnsiColor[ansi[1]]}"
	   	        foreground = "white"
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                boldbg = false
                numOpen += 1
            elsif ansi.scan(/\e\[1\;(3\d)m/)
                html.print(%{<span class="bold-#{AnsiColor[ansi[1]]}">})
	   	        foreground = "bold-#{AnsiColor[ansi[1]]}"
                bold = true
                numOpen += 1
            elsif ansi.scan(/\e\[1\;(4\d)m/)
            	if boldbg
	   	        	background = "bold-#{AnsiColor[ansi[1]]}"
	   	        else
	   	        	background = "#{AnsiColor[ansi[1]]}"
	   	        end
	   	        if !bold
	   	        	foreground = "bold-" + foreground
	   	        end
                html.print(%{<span class="#{foreground} #{background}">})
                bold = true
                numOpen += 1
            elsif ansi.scan(/\e\[(4\d)\;(3\d)m/)
            	if bold
	   	            foreground = "bold-#{AnsiColor[ansi[2]]}"
	            	if boldbg
		   	        	background = "bold-#{AnsiColor[ansi[1]]}"
		   	        else
		   	        	background = "#{AnsiColor[ansi[1]]}"
		   	        end
            	else
   	                foreground = AnsiColor[ansi[2]]
	            	if boldbg
		   	        	background = "bold-#{AnsiColor[ansi[1]]}"
		   	        else
		   	        	background = "#{AnsiColor[ansi[1]]}"
		   	        end
            	end
                html.print(%{<span class="#{foreground} #{background}">})
                numOpen += 1
            elsif ansi.scan(/\e\[(\d)m/)
            	if ansi[1] == '1'
	            	if !bold
		            	foreground = 'bold-' + foreground
	            	end
	                html.print(%{<span class="#{foreground}">})
	                bold = true
            	elsif ansi[1] == '0'
        			foreground = "white"
			        background = "bg-black"
	                html.print(%{<span class="#{foreground} #{background}">})
	                bold = false
	                boldbg = false
            	elsif ansi[1] == '7'
	            	for i in 1..numOpen
	            		html.print(%{</span>})
	            	end
            		if bold
            			newf = background.gsub!(/bg\-/,'bold-')
	            		newb = foreground.gsub!(/bold\-/,'bg-')
            		else
            			newf = background.gsub!(/bg\-/,'')
	            		newb = "bg-" + foreground.gsub!(/bold\-/,'')
            		end
            		foreground = newf
            		background = newb
	                html.print(%{<span class="#{foreground} #{background}">})
	                numOpen = 0
				end
				numOpen += 1            	
            elsif ansi.scan(/\e\[(3\d)m/m)
            	if bold
	   	            foreground = "bold-#{AnsiColor[ansi[1]]}"
    	            html.print(%{<span class="bold-#{AnsiColor[ansi[1]]}">})
            	else
	                html.print(%{<span class="#{AnsiColor[ansi[1]]}">})
   	                foreground = AnsiColor[ansi[1]]
            	end
                numOpen += 1
            elsif ansi.scan(/\e\[(4\d)m/m)
            	if boldbg
	                background = "bold-" + AnsiColor[ansi[1]]
            	else
	                background = AnsiColor[ansi[1]]
            	end
	            html.print(%{<span class="#{background}">})
                numOpen += 1
            elsif ansi.scan(/\e\[m/m)
    			foreground = "white"
		        background = "bg-black"
                html.print(%{<span class="#{foreground} #{background}">})
                bold = false
                boldbg = false
                numOpen += 1
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
        for i in 1..numOpen
            html.print(%{</span>})
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
		@font-face {
			font-family: ibm437;
			src: url(perfect_dos.ttf);
		}

		body,html {
			background-color: #000;
		}

		.black 		{color: #000000}
		.red 		{color: #aa0000}
		.green		{color: #00aa00}
		.yellow 	{color: #aa5500}
		.blue		{color: #0000aa}
		.magenta 	{color: #aa00aa}
		.cyan 		{color: #00aaaa}
		.white		{color: #c0c0c0}

		.bold-black, .black > .bold 	{color: #606060}
		.bold-red, .red > .bold 		{color: #ff5555}
		.bold-green, .green > .bold		{color: #00ff00}
		.bold-yellow, .yellow > .bold 	{color: #ffff00}
		.bold-blue, .blue > .bold		{color: #0000ff}
		.bold-magenta, .magenta > .bold 	{color: #ff55ff}
		.bold-cyan, .cyan > .bold 		{color: #55ffff}
		.bold-white, .white > .bold		{color: #ffffff}

		.bg-black 		{background-color: #000000}
		.bg-red 		{background-color: #aa0000}
		.bg-green		{background-color: #00aa00}
		.bg-yellow 	    {background-color: #aa5500}
		.bg-blue		{background-color: #0000aa}
		.bg-magenta 	{background-color: #aa00aa}
		.bg-cyan 		{background-color: #00aaaa}
		.bg-white		{background-color: #c0c0c0}

		.bold-bg-black 		{background-color: #606060}
		.bold-bg-red 		{background-color: #ff0000}
		.bold-bg-green		{background-color: #00ff00}
		.bold-bg-yellow 	{background-color: #ffff00}
		.bold-bg-blue		{background-color: #0000ff}
		.bold-bg-magenta 	{background-color: #ff55ff}
		.bold-bg-cyan 		{background-color: #00ffff}
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
			font-family: ibm437;
			line-height: 16px;
			letter-spacing: -1px;
		}
</style>
</head>
<body>
	<pre style="color: #ccc; background: #000; width: 640px; margin:auto; float: none;">
		#{content}
	</pre>
</body>
</html>
}