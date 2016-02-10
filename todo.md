# Todo

- [ ] Handle pipe-input or filename
- [ ] Store global configs in multimarkdown-config file? `template-dir: ...`
- [ ] Handle `<!-- lilypond-full -->`

---

- [x] Function to get template (can be stored in different places)
- [x] Default template
- [x] Restore function that checks for identical `lilypond snippets`
- [x] Where to store lilypond-files and output (`Markdown-file/subfolder`)?
- [x] Config format -> YAML
- [x] Handle Markdown files with UTF-8 characters in filename
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

