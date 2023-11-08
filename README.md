# Backy
![bucky.png](bucky.png)
<small>Bucky the Backy Beaver</small>

Introducing "Backy" - the ultimate database backup gem for Ruby on Rails applications! Safeguard your valuable data with ease, speed, and reliability. Developed with the Rails community in mind, Backy provides a comprehensive solution for handling your database backups, ensuring your information is safe and sound.

## Features

- Database backup and restore.
- Integration with AWS S3 for storing backups.
- Support for both standalone usage and as part of a Rails application.
- Automatic configuration inference when used within a Rails application.
- Logging with colored output.
- Command Line Interface (CLI) for easy management.

## Installation Rails


Add this line to your application's Gemfile:

```ruby
gem 'backy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backy_rb


## Usage

### Standalone

To use Backy in a standalone environment, you can utilize the provided CLI.

    $ backy [command] [options]

Available commands include:

* `download`: Download a file from S3
* `dump`: Dump the database
* `help [COMMAND]`: Describe available commands or one specific command
* `list`: List all dumps
* `push`: Push dump to S3 and delete local file
* `restore`: Restore a database from a dump
* `upload`: Upload a specific file to S3

### In a Rails Application

Backy seamlessly integrates with Rails applications. When included in a Rails app, Backy can automatically infer configurations from the Rails environment.

#### Rake Tasks
Backy provides Rake tasks for easy integration:

```
bin/rails backy:dump
bin/rails backy:restore
```

## Configuration

Backy can be configured through a .backyrc YAML file. Place this file in your home directory or the root of your Rails application.

Example `.backyrc`:

```yaml
defaults:
  use_parallel: true
  s3:
    access_key_id: YOUR_ACCESS_KEY
    secret_access_key: YOUR_SECRET_KEY
    region: YOUR_REGION
    bucket: YOUR_BUCKET
  database:
    host: DB_HOST
    port: DB_PORT
    username: DB_USERNAME
    password: DB_PASSWORD
    database_name: DB_NAME
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubynor/backy.
