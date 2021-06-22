# cocoapods-hmap

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/wangson1237/SYCSSColor/master/LICENSE)&nbsp;

A CocoaPods plugin which can gen/read header map file.

hmap-gen is able to scan the header files of the target referenced components in the specified Cocoapods project, and generates a header map file that public to all the components
as well as generates a public and private header map file for each referenced component.

At the same time, hmap-reader can read the header, bucktes, string_table information saved in the header map file.

- ✅ It can read hmap file.

- ✅ It can generate header map file.

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

## Usage

The command should be executed in directory that contains podfile.

```shell
# write the hmap file to podfile/Pods/Headers/HMap
$ pod hmap-gen

# write the hmap file to /project/dir/Pods/Headers/HMap
$ pod hmap-gen --project-directory=/project/dir/

# read the hmap file from /hmap/dir/file
$ pod hmap-reader --hmap-path=/hmap/dir/file
```

At same time, you can put this line in your podfile:

```rb
plugin 'cocoapods-mapfile'
```

Every time you execute pod install or pod update, `cocoapods-mapfile` will automatically generate a `header map file` for you and modify `HEAD_SEARCH_PATHS`.

### Option && Flags

`hmap-gen/hmap-writer`:

- `--project-directory=/project/dir/`: The path to the root of the project directory.
- `--nosave-origin-header-search-paths`: This option will not save xcconfig origin [HEADER_SEARCH_PATHS] and put `hmap file path` first.
- `--clean-hmap`: This option will clean up all `hmap-gen/hmap-writer` setup for hmap.

`hmap-reader`:

- `--hmap-path=/hmap/dir/file`: The path of the hmap file.

## Command Line Tool

Installing the 'cocoapods-mapfile' gem will also install two command-line tool `hmap_reader` and `hmap-writer` which you can use to generate header map file and read hmap file.

For more information consult `hmap_reader --help` or `hmap_writer --help`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [cocoapods-hmap](https://github.com/Cat1237/cocoapods-hmap). This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cocoapods::Hmap project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cocoapods-hmap/blob/master/CODE_OF_CONDUCT.md).
