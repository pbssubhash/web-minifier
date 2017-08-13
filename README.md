# web-minifier.rb
Compiles html/js/css files into one html file and minifies everything. Give it a try with your projects.
- Will not work with dynamically loaded files
- Very basic working script

## Why?
- You can compile/minify your content into a single file
- See how much total code is in your project
- See how much minification can be achieved. The projects I've tested have showed about 30% reduction of file size

## Usage
`ruby web-minifier.rb html_file output_directory [minify=true|false (default true)]`

Created by Sunmock Yang 2017 for fun.
