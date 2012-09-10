require 'rubygems'
require 'uglifier'

desc "Create minified version"
task :minify do
	minified = Uglifier.compile(File.read("lightbox.js"))
	File.open('lightbox.min.js', 'w') {|fh| fh.write minified}
	puts "#{Time.now.strftime('%H:%M:%S')} - compiled lightbox.min.js"
end
