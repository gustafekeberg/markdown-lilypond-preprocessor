# Markdown preprocessor for LilyPond snippets in markdown file

The goal for this preprocessor is to make it easy to include music via a LilyPond snippet in a markdown file.

## RegExps

- [Get the LilyPond snippet](https://regex101.com/r/yG2eW8/6):  
    ```
    /((^`{3,})\w*\n[\s\S]*?\n(\2))|(?:<!--\s*(lilypond-snippet)\s*-->$\n(?:(```)\w*$)*)([\s\S]*?)(\5*\n<!--\s*\4\s*-->)/mi
    ```

- [Extract data from the snippet](https://regex101.com/r/yG2eW8/5). Config-lines (must be kept together, no whitespace between lines) as `1st group`, assume the rest is music as `2nd group`:  
    ```
    /((?:\w*\:\s*[\w\W]*?\n)+)([^\1]+)/mi
    ```

## LilyPond snippet

````
<!-- lilypond-snippet -->
```

key: b-minor
time: 4/4
template: default

d4 b cs d | e e e2 | \break
e4 d cs b | a a a2 \bar "|."

```
<!--lilypond-snippet -->
````

### Explanation

- The code has to be enclosed in `<!--lilypond-markdown-->` tags
- The three backticks ` ``` ` are only used to format the snippet as code if no pre-processor is available. It can be eliminated without any problems.