# Todo

## Misc

- [ ] Find a good name: `LilyPond In Markdown = LIM`?

## Fix code

- [ ] Rename variables
- [ ] Handle error output from LilyPond or script: *replace image with error message if error?* / print to `stderr` / log?

## Functions

- [ ] Make cropped SVG's.
    - [ ] Check out [lilycrop.sh](https://github.com/andrewacashner/lilypond/blob/master/lilycrop.sh) to see if it's possible to make cropped PDFs which then are converted to SVG via [pdf2svg](http://www.cityinthesky.co.uk/opensource/pdf2svg/).
    + Tools:
        - [epstopdf](https://www.ctan.org/pkg/epstopdf)
        - [lilycrop](https://www.ctan.org/pkg/epstopdf)
        - [pdf2svg](http://www.cityinthesky.co.uk/opensource/pdf2svg/)
        - [ps2eps](https://www.ctan.org/pkg/ps2eps)
        - [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)  (Install [pdftk](http://stackoverflow.com/questions/32505951/pdftk-server-on-os-x-10-11/33248310#33248310) on El Capitan)
- [ ] Handle blockquotes: `>` (capture all the blockquotes -> check if the blockquote contains a lilypond-snippet -> process snippet)
- [ ] Handle multiple pages
- [ ] Template file should be copied to `$mlpp_lilypond_output_full_path` if the file doesn't already exists there. The copied template should then be used to process the snippets. This will prevent errors in snippet processing if templates are changed/updated. To use a newer version of a template, just remove the template copy from `$mlpp_lilypond_output_full_path`.

## Features

- [ ] Store some global configuration variables in multimarkdown-header? `template-dir: ...` ...
- [ ] Handle both piped-input and files
- [ ] Be able to run script on it's own, without Marked 2
- [ ] Config keys:
    + [x] `content_placeholder: "name of var"` - used to rename the variable where the content is placed, default name = `#{lilypond_content}`
    + [ ] `template_path: ~/...` = where to store/look for templates
    + [ ] `copy_template: true/false`

## Done

- [x] Why is the document processed twice?
- [x] ~~Handle `<!-- lilypond-full -->`~~ not needed any more
- [x] Replace all occurrences of `#{lily_content}`, not just the first one as I believe it is now
- [x] Clean-up code
- [x] Function to get template (can be stored in different places)
- [x] Default template
- [x] Restore function that checks for identical `lilypond snippets`
- [x] Where to store lilypond-files and output (`Markdown-file/subfolder`)?
- [x] Config format -> YAML
- [x] Handle Markdown files with UTF-8 characters in filename
- [x] Two modes: `<!-- lilypond-simple -->` / `<!-- lilypond-full -->`. Process music differently depending on if entered as direct input or as variable:

---

# New mode

Template consists of two parts:

1. Config in YAML-format, delimited by three dashes (optional)
2. Lilypond content → `#{lily_content}`

## Template
````
<!-- lilypond-snippet -->
```ly
---
key: variable
variables:
    one: one
    two: two
    three: three
---

\time 3/4
\key a \minor

a b c | d e f | g2. \bar "|."

```
<!-- lilypond-snippet -->
````

# Old mode (discarded)

## Simple mode

```ly
---
key: config
---

a b c d
```

## Full mode?

If written as variable, multiple variables is possible. Template could be formatted something like this:

```ly
{{ var_1 }}
{{ var_2 }}
{{ var_3 }}

\var_2

\test {
    \var_1
    \var_3
    }
```

or

Snippet:

```
---
author: Name
---

global = {}
notes = {}
```

Template-file:

```
#{content}

\music {
    \global
    \notes
}

```

`#{content}` is replaced by the content of the snippet, everything that comes after the YAML-part.