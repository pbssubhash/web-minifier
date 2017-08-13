require 'cssminify'
require 'html_press'
require 'uglifier'
require 'nokogiri'

input_html = ARGV[0]
output_dir = ARGV[1]
minify_toggle = ARGV[2]

help_text = "Usage: ruby web-minifier.rb html_file output_directory [minify=true|false]
- Takes the input html file
- Finds all external css/js files referenced by the html file
- Minifies contents
- Outputs an amalgamated html file + any non-html/css/js files in the same directory as the html file to the specified output folder.

Created by Sunmock Yang 2017 for fun."

def minify(html_path, output_path, minify_toggle)
	original_file_size = 0;

	root_dir = Dir.pwd
	Dir.chdir(File.dirname(html_path))

	html_file = File.open(File.basename(html_path))
	original_file_size += File.read(html_file).length
	doc = Nokogiri::HTML(html_file)

	# Find and replace external javascript with inline
	doc.css('script').each do |script_tag|
		script_src = script_tag["src"]
		if (!script_src.nil? && !script_src.start_with?("http"))
			new_node = doc.create_element('script')
			new_node['type'] = 'text/javascript'
			script_content = File.read(script_src)
			original_file_size += script_content.length
			if minify_toggle
				new_node.content = Uglifier.new.compile(script_content)
			else
				new_node.content = script_content
			end
			script_tag.replace(new_node)
		end
	end

	# Find and replace external css with inline
	doc.css('link[rel=stylesheet]').each do |link_tag|
		if (!link_tag["href"].start_with?("http"))
			new_node = doc.create_element 'style'
			stylesheet_content = File.read(link_tag["href"])
			original_file_size += stylesheet_content.length
			if minify_toggle
				new_node.content = CSSminify.compress(stylesheet_content)
			else
				new_node.content = stylesheet_content
			end
			link_tag.replace(new_node)
		end
	end

	Dir.chdir(root_dir)

	File.open("#{output_path}/index.html",'w') do |s|
		if minify_toggle
	  		s.print HtmlPress.press(doc.inner_html)
	  	else
	  		s.print(doc.inner_html)
	  	end
	end

	# Copy over other assets. Probably need some work on this.
	other_files = Dir.glob("#{File.dirname(html_path)}**/*").reject { |file| file.end_with?(".css") || file.end_with?(".js") || file.end_with?(".html") }
	FileUtils.cp_r(other_files, output_path)\

	puts "Original content size: #{original_file_size} bytes"
	if minify_toggle
		minified_size = File.read("#{output_path}/index.html").length
		puts "Minified content size: #{minified_size} bytes"
		puts "New content is #{minified_size * 100 / original_file_size}\% of original size"
	end
end

if !input_html.nil? && !output_dir.nil?
	minify(input_html, output_dir, minify_toggle != "false")
else
	puts "Missing arguments"
	puts help_text
end


