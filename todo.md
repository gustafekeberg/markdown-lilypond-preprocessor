# Todo

- [x] Function to get template (can be stored in different places)
- [x] Default template
- [ ] Where to store lilypond-files and output (`Markdown-file/subfolder`)?
- [ ] Config format -> YAML
- [ ] Store global configs in multimarkdown-config file? `template-dir: ...`
- [x] Two modes: `<!-- lilypond-simple -->` / `<!-- lilypond-full -->`. Process music differently depending on if entered as direct input or as variable:

## Simple mode

```ly
key: config

a b c d
```
    
## Full mode

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

