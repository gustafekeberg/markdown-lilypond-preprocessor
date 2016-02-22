# LilyPond snippets in markdown

*A preprocessor for LilyPond snippets in Markdown files.*

- The goal for this ruby script is to make it easy to include music via a LilyPond snippet in a Markdown file.
- The snippet should be as easy as possible to enter into the Markdown file.
- To simplify the LilyPond code a template is used, and only the relevant data (note pitches, durations, time signature, key signature ...) is entered in the Markdown file. The rest of the LilyPond code is in the template file.
- Currently the processor will only work with [Marked 2](http://marked2app.com/), but in the end it's supposed to be fully functional on it's own.


## How does it work, what does it do?

1. The script will find the LilyPond snippet in the Markdown,
2. process it,
3. output a PNG,
4. replace the snippet with the PNG.

## LilyPond snippet - example

The code below shows an example of a LilyPond snippet in a Markdown file.


	<!-- lilypond-snippet -->
	```
	---
	variables:
	    key: variable
	template: default
	---

	\markup #{key}
	d4 b cs d | e e e2 | \break
	e4 d cs b | a a a2 \bar "|."

	```
	<!-- lilypond-snippet -->

Explanation:

- The snippet begins and ends with `<!-- lilypond-snippet -->`.
- The three backticks in in the beginning and end `` ``` `` are only there to make the snippet appear as code if the preprocessor script is not available, they can be omitted.
- The three dashes `---` are used to delimit the YAML-formatted config section.
	+ In the config section it's possible to specify a template file to use and some variables that can be used in the template.
	+ Variables can be used in templates like this: `#{key}`. Now `#{key}` will be placeholder for the value of the variable named `key`.

End of example

## TODO: Howto use the script

- [ ] How to run the script?
- [ ] Where to store templates?
- [ ] Config file location?