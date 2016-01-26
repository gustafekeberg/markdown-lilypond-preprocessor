#!/usr/bin/env ruby -E utf-8
#<Encoding:UTF-8>

def process_markdown(markdown)
	# Regex to find lilypond snippets. First part determines if it is a code-block or else checks if it's a LilyPond-snippet.
	re_get_snippet = /((^`{3,})\w*\n[\s\S]*?\n(\2))|(?:<!--\s*(lilypond-snippet)\s*-->$\n(?:(```)\w*$)*)([\s\S]*?)(\5*\n<!--\s*\4\s*-->)/mi

	# Find all snippets in markdown and process them.
	processed_markdown = markdown.gsub(re_get_snippet).with_index do | m, index |
		# If group 2 is present, then it's code - return without processing
		if $2
			$1
		else
			process_snippet($6, index)
		end
	end

	return processed_markdown
end

def process_snippet(snippet, index)
	
	# Regex to get snippet data, group 1 = config, group 2 = music.
	re_get_data_from_snippet = /((?:\w*\:\s*[\w\W]*?\n)+)([^\1]+)/mi
	data = re_get_data_from_snippet.match(snippet)
	
	# Process config.
	config = process_config(data[1])

	# Process music.
	music = process_music(data[2])

	snippet = "### Snippet no ##{index+1}  \n\n"
	if config['songprops'].length != 0
		songprops = "#### Songprops:  \n```\n#{config['songprops']}\n```  \n"
	end
	if config['template'].length != 0
		template = "#### Template:  \n```\n#{config['template']}\n```  \n"
	end
	if config['not_processed'].length != 0
		not_processed = "#### Not processed config:  \n```\n#{config['not_processed']}\n```  \n"
	end
	if config .length != 0
		config = "#### Config:  \n```\n#{config}\n```  \n"
	end
	# return "#{snippet}#{songprops}#{template}#{not_processed}#### Music:  \n```\n#{music}\n```"
	return_data = "#{snippet}#{config}#### Music:  \n```\n#{music}\n```"
	return "<div style=\"background-color: red;\">#{return_data}</div>"
end

def process_config( config )
	# Prepare hashes for different config parts.
	template = {}
	songprops = {}
	not_processed = {}

	# Read all config and reformat to LilyPond syntax.
	config.each_line do |line|
		match = /(\w*)\:\s*([\w\W]*[^\s])/.match(line)
		key = match[1]
		value = match[2]

		case key
		when "key"
			k = value.split('-')
			songprops[key] = "\\key #{k[0]} \\#{k[1]}\n"
		when "time"
			songprops[key] = "\\#{key} #{value}\n"
		when "language"
			songprops[key] = "\\#{key} \"#{value}\"\n"
		when "template", "baseline"
			template[key] = value
		else
			not_processed[key] = value
		end
		
	end

	# Return hash of all processed config values.
	config_hash = {
		"songprops"=>songprops,
		"template"=>template,
		"not_processed"=>not_processed
	}
	# songprops_string = "#{songprops['language']}#{songprops['key']}#{songprops['time']}"
	return config_hash
end

def process_music( music )
	# Make LilyPond variable of music data.
	music = "music = {#{music}}"
	return music
end

input = $stdin.read
processed_markdown = process_markdown( input )
$stdout.print processed_markdown
