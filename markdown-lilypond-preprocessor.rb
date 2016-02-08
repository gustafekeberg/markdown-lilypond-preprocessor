#!/usr/bin/env ruby -E utf-8
#<Encoding:UTF-8>

# This script should be run from Marked 2 to work

# Change dir to MARKED_ORIGIN path env var set by Marked and assign variables for all env vars.
Dir.chdir(ENV['MARKED_ORIGIN'])

# Global variables

$mlpp_marked_origin       = ENV['MARKED_ORIGIN']
$mlpp_marked_ext          = ENV['MARKED_EXT']
$mlpp_marked_filename     = File.basename(ENV['MARKED_PATH'], ".#{$mlpp_marked_ext}")
$mlpp_lilypond_output_path = "#{$mlpp_marked_origin}#{$mlpp_marked_filename}-lilypond-data"
$mlpp_script_dir          = "#{ENV['HOME']}/.markdown-lilypond-preprocessor"
$mlpp_config_file         = "#{$mlpp_script_dir}/config"
$mlpp_template_dir        = "#{$mlpp_script_dir}/templates"

def read_config_file( file )
	# Read config file, create it with default values if it doesn't exist
	
	if File.file?( file )
		configs = IO.read(file)
	else
		configs = "lilypond_bin: \"/Applications/LilyPond.app/Contents/Resources/bin/lilypond\"\ndefault_template: \"default-template\""
		dirname = File.dirname( file )
		unless File.directory?( dirname )
		  FileUtils.mkdir_p( dirname )
		end
		IO.write( file, configs )
	end
	return configs
end

def process_markdown(markdown)
	# Regex to find lilypond snippets. First part determines if it is a code-block or else checks if it's a LilyPond-snippet.
	re_get_snippet = /((^`{3,})\w*\n[\s\S]*?\n(\2))|(?:<!--\s*(lilypond-(?:simple|full))\s*-->$\n(?:(```)\w*$)*)([\s\S]*?)(\5*\n<!--\s*\4\s*-->)/mi
	
	# Find all simple snippets in markdown and process them.
	processed_markdown = markdown.gsub(re_get_snippet).with_index do | m, index |

		if $2 # If group 2 is present, then it should display as code - proceed without processing
			$1
		else # Else check what type of snippet (simple|full|...)
			case $4
			when "lilypond-simple"
				process_snippet($6, index)
			else
				"*The `#{$4}`-tag is not yet implemented!*"
			end
		end
	end

	return processed_markdown
end

def make_lilypond_file( lilypond_obj, i )
	# Construct the lilypond file
	lilypond_filename = "lilypond-snippet-#{i}.ly"
	config = lilypond_obj["config"]
	music = lilypond_obj["music"]
	songprops = config["songprops"]
	template = config["template"]
	last_run_prefix = "-"

	lilypond_bin = "/Applications/LilyPond.app/Contents/Resources/bin/lilypond"
	
	# Replace with get template function!
	# Update function: "filename"+".ly"
	unless config["template"]
		template = "default-template"
	end
	template = File.basename(template, ".*") + ".ly"
	template_content = IO.read(template)

	songprops_string = ""
	songprops.each do |key, value|
		songprops_string += value
	end
	songprops_string = "songprops = {\n#{songprops_string}}"

	template_processed = template_content.gsub('#{music}', music)
	template_processed = template_processed.gsub('#{songprops}', songprops_string)
	IO.write(lilypond_filename, template_processed)

	last_run_filename = last_run_prefix + lilypond_filename

	file_content = IO.read(lilypond_filename)
	last_run_file_content = ""
	
	if File.file?(last_run_filename)
		last_run_file_content = IO.read(last_run_filename)
	end

	# Check if lilypond-snippet files has changed since last run, then run LilyPond
	identical = true
	unless file_content == last_run_file_content
		`cp #{lilypond_filename} #{last_run_filename}`
		`#{lilypond_bin} -dbackend=eps -dresolution=600 --png #{lilypond_filename}`
		basename = File.basename(lilypond_filename, ".ly")
		`rm #{basename}*.eps #{basename}*.count #{basename}*.tex #{basename}*.texi`
		identical = false
	end
	random = rand(1000)
	generated_file = File.basename(lilypond_filename, ".ly") + ".png?#{random}"
	return generated_file
end

def process_snippet(snippet, index)
	
	# Regex to get snippet data, group 1 = config, group 2 = music.
	re_get_data_from_snippet = /((?:\w*\:\s*[\w\W]*?\n)+)([^\1]+)/mi
	data = re_get_data_from_snippet.match(snippet)
	
	# Process config and music.
	config = process_config(data[1])
	music = process_music(data[2])

	# Make lilypond file
	file_src = make_lilypond_file( {
		"config" => config,
		"music" => music
		}, index )
	return "<figure class=\"music-container\"><img src=\"#{file_src}\" /></figure>"
end

def get_config_keys( lines )

	config_hash = {}
	# Read all config lines and return hash
	lines.each_line do |line|
		match = /(\w*)\:\s*([\w\W]*[^\s])/.match(line)
		key = match[1]
		value = match[2]
		config_hash[key] = value
	end
	return config_hash
end

def process_config( config )
	# Prepare hashes for different config parts.
	processed_config = {}
	songprops = {}
	not_processed = {}

	config_hash = get_config_keys( config )

	# Reformat hash to LilyPond syntax.
	config_hash.each do |key, value|
		case key
		when "key"
			k = value.split('-')
			songprops[key] = "\\key #{k[0]} \\#{k[1]}\n"
		when "time"
			songprops[key] = "\\#{key} #{value}\n"
		when "language"
			songprops[key] = "\\#{key} \"#{value}\"\n"
		when "template", "baseline"
			config_hash[key] = value
		else
			not_processed[key] = value
		end
		
	end

	# Return hash of all processed config values.
	processed_config["songprops"] = songprops
	processed_config["not_processed"] = not_processed

	# songprops_string = "#{songprops['language']}#{songprops['key']}#{songprops['time']}"
	return processed_config
end

def process_music( music )
	# Make LilyPond variable of music data.
	music = "music = {#{music}}"
	return music
end

def get_lilypond_template( template_filename )
	# Search for templates:
	# 
	# 1. If env var MARKED_ORIGIN is set, start searching for templates here
	# 2. Look in $HOME/."processor_name"/templates
	# 3. (Use the built in template, located?)
	# 
	# return template

	# Add different locations to look for template
	marked_origin_template = "#{$mlpp_marked_origin}#{template_filename}"
	template_dir_template = "#{$mlpp_template_dir}/#{template_filename}"

	template = "___Template `#{template}` was not found.___"

	# Search for file as entered
	if File.file?( File.expand_path( template_filename ))
		template = IO.read( template_filename )
	# Search for file in marked_origin dir
	
	elsif File.file?( marked_origin_template )
		template = IO.read( marked_origin_template )

	# Search in template dir in user-root
	
	elsif File.file?( template_dir_template )
		template = IO.read( template_dir_template )

	end
	return template
end

input = $stdin.read
processed_markdown = process_markdown( input )
$stdout.print processed_markdown
