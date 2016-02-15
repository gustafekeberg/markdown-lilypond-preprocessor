# LilyPond snippets in markdown/multimarkdown

*Markdown/MultiMarkdown preprocessor for LilyPond snippets in markdown file.*

The goal for this simple ruby script is to make it easy to include music via a LilyPond snippet in a markdown file.

*There are many things to do before it's complete!*

## LilyPond snippet - example

    <!-- lilypond-simple -->
    ```
    
    key: b-minor
    time: 4/4
    template: default
    
    d4 b cs d | e e e2 | \break
    e4 d cs b | a a a2 \bar "|."
    
    ```
    <!--lilypond-simple -->

### Explanation

- The code has to be enclosed in `<!-- lilypond-simple -->` or `<!-- lilypond-full -->` tags
- The three backticks \`\`\` are only used to format the snippet as code if no pre-processor is available. It can be eliminated without any problems.

## Howto use the script

- [ ] How to run the script?
- [ ] Where to store templates?
- [ ] Different modes: `<!-- lilypond-simple -->` or `<!-- lilypond-full -->`
