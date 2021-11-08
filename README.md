# cocoapods-hmap

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/wangson1237/SYCSSColor/master/LICENSE)&nbsp;

A CocoaPods plugin which can gen/read header map file.

**hmap-gen** is able to scan the header files of the target referenced components in the specified Cocoapods project, and generates a header map file that public to all the components
as well as generates a public and private header map file for each referenced component.

- <header.h> : -I<hmap file path>
- "header.h" : -iquote <hmap file path>

For framework, use [yaml-vfs](https://github.com/Cat1237/yaml-vfs) create VFS file to map framework Headers and Modules dir and pass VFS file to `-ivfsoverlay` parameter.

- vfs : -ivfsoverlay <all-product-headers.yaml>

A hmap file includes four types of headers:

- "header.h"
- <module/header.h> **based on project**
- <project_name/header.h> **based on project**
- <*\*/**/header.h> **based on project**
- "*\*/**/header.h" **based on project**
- "module/header.h" **based on project**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cocoapods-mapfile'
```

And then execute:

```shell
# bundle install
$ bundle install
```

Or install it yourself as:

```shell
# gem install
$ gem install cocoapods-mapfile
```

## Quickstart
To begin gen hmap file by opening an Xcodeproj dir, and to your command line with:
```shell
$ hmapfile gen
```
or to your podfile, add this line:
```
$ plugin 'cocoapods-mapfile'
```


## Command Line Tool

Installing the `cocoapods-mapfile` gem will also install two command-line tool `hmapfile reader` and `hmapfile writer` which you can use to generate header map file and read hmap file.

For more information consult
- `hmapfile --help`
- `hmapfile gen --help`
- `hmapfile reader --help`
- `hmapfile writer --help`

### Usage

```shell

# Read or write header map file.
$ hmapfile COMMAND

```

#### Commands

1. `hmapfile gen`:

    - `--project-directory=/porject/dir`: Read .xcworkspace/.xcodeproj file to gen hmap files.
    - `--clean-hmap`: Clean up hmap file settings.

2. `hmapfile reader`:
    - `--hmap-path=/hmap/dir/file`: Read this path of the hmap file.

3. `hmapfile writer`:
    - `--json-path=/project/dir/json`: The path to the hmap json data.
    - `--output-path=/project/dir/hmap file`: The path json data to the hmap file.

example：

```shell
# Read current dir .xcworkspace/.xcodeproj file to Gen hmap files.
$ hmapfile gen

# Read the specified directory .xcworkspace/.xcodeproj file to Gen hmap files.
$ hmapfile gen --project-directory=<project path>

# Clean up hmap file settings.
$ hmapfile gen --clean-hmap
$ hmapfile gen --project-directory=<project path> --clean-hmap

$ hmapfile writer --json-path=../cat.json --output-path=../cat.hmap

$ hmapfile reader --hmap-path=../cat.hmap
```

## For Cocoapods

Add this line in your podfile:

```rb
plugin 'cocoapods-mapfile'
```

This was equl:

```rb
$ hmapfile gen --project-directory=<project path>
```
or, you can set some value:

Every time you execute pod install or pod update, `cocoapods-mapfile` will automatically generate a `header map file` for you and modify:
- `OTHER_CPLUSPLUSFLAGS`
- `OTHER_CFLAGS`
- `USE_HEADERMAP`
- `USER_HEADER_SEARCH_PATHS`
- `HEAD_SEARCH_PATHS`

## Contributing

Bug reports and pull requests are welcome on GitHub at [cocoapods-hmap](https://github.com/Cat1237/cocoapods-hmap). This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cocoapods::Hmap project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cocoapods-hmap/blob/master/CODE_OF_CONDUCT.md).
