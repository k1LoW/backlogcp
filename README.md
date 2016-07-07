# backlogcp [![Gem](https://img.shields.io/gem/v/backlogcp.svg)](https://rubygems.org/gems/backlogcp)

Backlog file copy command like `scp`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'backlogcp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backlogcp

## Usage

### STEP1

Copy Backlog file URI.

Example:

- https://xxxxxxxxx.backlog.jp/file/XXXXX/path/to/file.png
- https://xxxxxxxxx.backlog.jp/ViewAttachment.action?attachmentId=000000000000
- https://xxxxxxxxx.backlog.jp/downloadAttachment/000000000000/file.png

### STEP2

Use `backlogcp` command like `scp`.

```sh
$ export BACKLOG_API_KEY=XXXXXxxxXXXXxxXXXXXxXXXXXXX
$ backlogcp https://xxxxxxxxx.backlog.jp/file/XXXXX/path/to/file.png ./
```

## Support file type

- Shared file
- Attachment file on issue

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/k1LoW/backlogcp/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
