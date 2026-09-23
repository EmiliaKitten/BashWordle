# BashWordle

A Wordle-style word game written in Bash. The game chooses a random word from a supplied word list and gives the player six attempts to guess it.

## Requirements

- Bash 4 or newer
- `grep`, `mktemp`, `shuf`, `sort`, and `tr`
- A terminal that supports ANSI color escape sequences for colored feedback

## Usage

Make the script executable and run it with a word-list file:

```bash
chmod +x wordle.sh
./wordle.sh words.txt
```

The syntax is:

```text
wordle.sh [-l <length>] [-c] FILE
```

### Options

| Option | Description |
| --- | --- |
| `-l <length>` | Sets the word length. The value must be an integer from `3` through `10`. The default is `5`. |
| `-c` | Uses the alternative contrast colors for right, misplaced, and wrong letters. |
| `FILE` | Required word-list file. It must be readable and contain one candidate word per line. |

Examples:

```bash
# Five-letter words and the default colors
./wordle.sh words.txt

# Six-letter words
./wordle.sh -l 6 words.txt

# Six-letter words with alternative contrast colors
./wordle.sh -l 6 -c words.txt
```

## Word-list format

The script reads the file one line at a time. It:

- removes Windows carriage returns;
- keeps only lines containing exactly the selected number of letters (`A-Z` or `a-z`);
- converts words to uppercase; and
- removes duplicate entries.

At least one valid word must remain after filtering. The selected answer and every accepted guess come from this filtered list.

## Game rules

Each game starts with six attempts, regardless of the selected word length. Guesses are converted to uppercase and must:

- have exactly the selected number of letters;
- contain alphabetic characters only;
- use only letters that have not already been ruled out; and
- exist in the supplied word list.

Feedback uses these colors by default:

- Green: the letter is correct and in the correct position.
- Yellow: the letter occurs in the answer but is in the wrong position.
- Red: the letter does not occur in the answer.

The duplicate-letter scoring follows Wordle-style matching: letters in correct positions are matched first, then misplaced letters are matched against the remaining letters in the answer.

The game prints `You won!` when the answer is guessed. Otherwise, after all attempts are used or input ends, it prints `You lost!` and reveals the answer.

## Exit codes

| Code | Meaning |
| --- | --- |
| `0` | The game completed normally. |
| `1` | Invalid option, option value, or command syntax. |
| `2` | The required word-list argument is missing or too many arguments were supplied. |
| `3` | The word-list file cannot be read. |
| `4` | A temporary file could not be created. |
| `5` | The word-list contains no valid words of the selected length. |
