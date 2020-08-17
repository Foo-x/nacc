# nacc

A Nim AtCoder command line tool.  
Only tested on Windows Subsystem for Linux.  
Feel free to open an issue.


## Features

- Create a directory for AtCoder contest
    - Download sample cases
- Test your code


## Installation

```sh
nimble install https://github.com/Foo-x/nacc
```


## Usage

```sh
# create a directory for the contest and download sample cases
nacc new abc175
```

![](./static/nacc_new.PNG)

```sh
# test your code
nacc test abc175 a
```

![](./static/nacc_test.PNG)
