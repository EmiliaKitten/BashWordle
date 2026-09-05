# BashWordle

A simple Wordle-style game written in Bash.

## Arguments

**Syntax:**

```text
scriptname [-l <int between 3 and 10>] [-c] FILE
```

**Example:**

```bash
./wordle.sh -l 6 words.txt
```

### Options

| Argument      | Description                                                       |
| ------------- | ----------------------------------------------------------------- |
| `-l <length>` | **Optional.** Sets the word length. Must be between **3 and 10**. |
| `-c`          | **Optional.** Enables different contrast feedback.                               |
| `FILE`        | A file containing words/strings separated by newlines.            |

### Examples

```bash
# Use the default word length
./wordle.sh words.txt

# Use 6-letter words
./wordle.sh -l 6 words.txt

# Use 6-letter words with different feedback colors output
./wordle.sh -l 6 -c words.txt
```
