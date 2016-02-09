#!/usr/bin/env ruby -E utf-8
#<Encoding:UTF-8>

# This script should be run from Marked 2 to work

# Change dir to MARKED_ORIGIN path env var set by Marked and assign variables for all env vars.
Dir.chdir(ENV['MARKED_ORIGIN'])

# Global variables

$mlpp_marked_origin        = ENV['MARKED_ORIGIN']
$mlpp_marked_ext           = ENV['MARKED_EXT']
$mlpp_marked_filename      = File.basename(ENV['MARKED_PATH'], ".#{$mlpp_marked_ext}")
$mlpp_lilypond_output_path = File.join($mlpp_marked_origin, "#{$mlpp_marked_filename}-lilypond-data")
$mlpp_script_dir           = File.dirname(__FILE__)
$mlpp_home_dir             = File.join(ENV['HOME'], ".markdown-lilypond-preprocessor")
$mlpp_config_file          = File.join($mlpp_home_dir, "config")
$mlpp_template_dir         = File.join($mlpp_home_dir, "templates")
$mlpp_default_template     = File.join($mlpp_script_dir, "lib/default-template.ly")
$mlpp_lilypond_bin         = "/Applications/LilyPond.app/Contents/Resources/bin/lilypond"

def log( data )
	timestamp = Time.now.getutc
	output = "  \n`#{timestamp}`: #{data}"
	log_path = File.join($mlpp_script_dir, "log.txt")
	File.open(log_path, 'a') { |f| f.write(output) }
end

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

def find_and_process_snippets(markdown)
	# Regex to find lilypond snippets. First part determines if it is a code-block or else checks if it's a LilyPond-snippet.
	re_get_snippet = /((^`{3,})\w*\n[\s\S]*?\n(\2))|(?:<!--\s*(lilypond-(?:simple|full))\s*-->$\n(?:(```)\w*$)*)([\s\S]*?)(\5*\n<!--\s*\4\s*-->)/mi
	
	# Find all simple snippets in markdown and process them.
	processed_markdown = markdown.gsub(re_get_snippet).with_index do | m, index |

		if $2 # If group 2 is present, then it should display as code - proceed without processing
			$1
		else # Else check what type of snippet (simple|full|...)
			case $4
			when "lilypond-simple"
				output_src = process_simple_snippet($6, index)
				"<figure class=\"music-container\"><img src=\"#{output_src}\" /></figure>"
			else
				"*The `#{$4}`-tag is not yet implemented!*"
			end
		end
	end

	return processed_markdown
end

def process_simple_snippet(snippet, index)
	
	# Regex to get snippet data, group 1 = config, group 2 = music.
	re_get_data_from_snippet = /((?:\w*\:\s*[\w\W]*?\n)+)([^\1]+)/mi
	data = re_get_data_from_snippet.match(snippet)
	
	# Process config and music.
	config = extract_lilypond_config(data[1])
	music = process_music(data[2])

	# Make lilypond file from snippet data
	file_src = lilypond_simple_output( {
		"config" => config,
		"music" => music
		}, index )
	return file_src
end

def lilypond_simple_output( lilypond_obj, index )
	# Construct the lilypond file
	lilypond_filename = "lilypond-snippet-#{index}.ly"
	config = lilypond_obj["config"]
	music = lilypond_obj["music"]
	songprops = config["songprops"]
	config_hash = config["config_hash"]
	template = config_hash["template"]
	template_content = get_lilypond_template( template, index )
	last_run_prefix = "_"

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
		`#{$mlpp_lilypond_bin} -dbackend=eps -dresolution=600 --png #{lilypond_filename}`
		basename = File.basename(lilypond_filename, ".ly")
		`rm #{basename}*.eps #{basename}*.count #{basename}*.tex #{basename}*.texi`
		identical = false
	end
	random = rand(1000)
	generated_file = File.basename(lilypond_filename, ".ly") + ".png?#{random}"
	return generated_file
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

def extract_lilypond_config( config )
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
	processed_config["config_hash"] = config_hash

	# songprops_string = "#{songprops['language']}#{songprops['key']}#{songprops['time']}"
	return processed_config
end

def process_music( music )
	# Make LilyPond variable of music data.
	music = "music = {#{music}}"
	return music
end

def get_lilypond_template( template_file, index = '?')
	log_template = false
	# Set default template if template_file is empty or not set
	if !template_file
		template_file = $mlpp_default_template
	end
	
	# Search for templates:
	# 
	# 1. If env var MARKED_ORIGIN is set, start searching for templates here
	# 2. Look in $HOME/."processor_name"/templates
	# 3. (Use the built in template, located?)
	# 
	# return template

	template_dir = File.dirname(template_file)
	template_filename = File.basename(template_file, ".*") + ".ly"
	template_path = File.join(
		File.dirname(template_file),
		File.basename(template_file, ".*") + ".ly"
		)

	# Different locations to look for template
	marked_origin_template = File.join( $mlpp_marked_origin, template_path )
	template_dir_template = File.join( $mlpp_template_dir, template_path )

	template = "___Template `#{template_path}` in the snippet no `#{index}` was not found.___"

	# Search for file as entered
	if File.file?( File.expand_path( template_path ))
		template = IO.read( template_path )
		if log_template
			log( "Template found (#{index}):\n #{template_file}" )
		end
	# Search for file in marked_origin dir
	
	elsif File.file?( marked_origin_template )
		template = IO.read( marked_origin_template )
		if log_template
			log( "Template found (#{index}):\n #{marked_origin_template}" )
		end

	# Search in template dir in user-root
	
	elsif File.file?( template_dir_template )
		template = IO.read( template_dir_template )
		if log_template
			log( "Template found (#{index}):\n #{template_dir_template}" )
		end

	end
	return template
end

input = $stdin.read
processed_markdown = find_and_process_snippets( input )
$stdout.print processed_markdown