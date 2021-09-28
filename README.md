# c-basher

A very small (and simple) unit testing tool for C (made in bash).

## How to run it

Add the `tests` folder to your project root. Execute `tests/c-basher.sh <path/to/file.c>` where `<path/to/file.c>` is a path relative to the project root directory. After it, you will receive the testing result summary, e.g.

```
1. SMALL: PASSED
2. LARGE: FAILED
Expected:
20 14
Recieved:
20 15
3. MEDIUM IDK: PASSED

Total tests: 3
Passed: 2
Failed: 1

Some tests failed
```

Running `c-basher` will compile the program and place it in `bin/` as `output`. If there's no `bin/` directory, it will be created automatically.

## Prerequisites

- Mandatory `cases.txt` file that describes your test cases
- Optional `ignore.txt` file that describes strings to be ignored from the received output of the program.

These files should be located in the `tests/` directory. If you don't want to use `tests/cases.txt` file, you can specify a case file path with the `-c` option when calling `c-basher.sh` (e. g. `tests/c-basher.sh example.c -c foo/bar/my-case-file.txt`, this path is relative to the **`tests/`** directory).

### Dependencies

- gcc
- sed

The example below contains 3 test cases where every one of them have an input (it can span 1 or more lines) and an expected output (it can also span 1 or more lines)

### `cases.txt` format:

```
Test name GOES here, IT CAN BE ANYTHING
1 2 3 input starts on the next line

5 8 expected output starts after a new line after the input

TEST CASE2
input
can span multiple
lines until a new line

same goes with
expected output

NEGATIVE_NUMBERS
-1 -2
-4 -5

2 4
8 10
```

### `ignore.txt` format

```
These
Words
Will
Be
Removed
THIS EXACT LINE WILL BE REMOVED
```

## Options

| Option | Argument (Example) | Explanation                                                                                                                                                                                                                                                 |
| ------ | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-c`   | path/to/file.txt   | You can specify a different file to be used instead of the default `cases.txt` file                                                                                                                                                                         |
| `-t`   | "make output"      | You can specify a different compilation task to be carried out instead of the default `gcc $project_root/$1 -o $project_root/$output_dir/$output_file` (for example if you're using a Makefile, just be sure that it generates the `bin/output` executable) |

## Example

If you clone this repository, you can run the [example](./example.c) by executing `tests/c-basher.sh example.c`. You should get:

```
Total tests: 7
Passed: 6
Failed: 1

Some tests failed
```

See [`tests/ignore.txt`](./tests/ignore.txt) about how to ignore unecessary printed data from the example.

Read more about the development process [here](https://bx2.tech/software/unit-testing-c-with-bash).
