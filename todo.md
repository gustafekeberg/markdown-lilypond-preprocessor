# Todo

- [ ] Handle pipe-input or filename
- [ ] Store global configs in multimarkdown-config file? `template-dir: ...`
- [ ] ~~Handle `<!-- lilypond-full -->`~~ not needed any more
- [ ] Template file should be copied to `$mlpp_lilypond_output_full_path` if the file doesn't already exists there. The copied template should then be used to process the snippets. This will prevent errors in snippet processing if templates are changed/updated. To use a newer version of a template, just remove the template copy from `$mlpp_lilypond_output_full_path`.
- [ ] Rename variables
- [ ] Clean-up code
- [ ] Config key: `lilypond_content_variable_name: "name of var"` - used to rename the variable where the content is placed, default name = `#{lily_content}`
- [ ] Check out [lilycrop.sh](https://github.com/andrewacashner/lilypond/blob/master/lilycrop.sh) to see if it's possible to make cropped PDFs which then are converted to SVG via [pdf2svg](http://www.cityinthesky.co.uk/opensource/pdf2svg/). ([pdftk](http://stackoverflow.com/questions/32505951/pdftk-server-on-os-x-10-11/33248310#33248310) on El Capitan)


---

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
<!-- lilypond -->
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
<!-- lilypond -->
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