# airbrake

[Airbrake](https://airbrake.io/) and
[Errbit](https://github.com/errbit/errbit) notifier for crystal

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  airbrake:
    github: klacointe/airbrake.cr
```

## Usage

```crystal
require "airbrake"
Airbrake.configure do |config|
  config.project_id = "1234"
  config.project_key = "123456789"

  # Optional, use airbrake endpoint by default
  config.endpoint = "http://host.tld"
  # Optional, use ["development", "test"] by default
  config.development_environments = ["development", "test"]
end
```

### Manual notifications

```crystal
begin
  MyRunner.do_hard_work!
rescue ex
  Airbrake.notify(ex)
end
```

`notify` returns the Airbrake response (e.g. `{"id" => "...", "url" => "..."}`),
or `nil` when nothing was sent (development environments) or when Airbrake
replies with an error. Network errors are raised.

### Automatic notifications

```crystal
Airbrake.handle do
  MyRunner.do_hard_work!
end
```

The exception is always re-raised. If notifying Airbrake fails, a warning is
logged on the `airbrake` log source instead of hiding the original exception.

## Development

```sh
crystal spec
```

## Contributing

1. Fork it ( https://github.com/klacointe/airbrake.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [klacointe](https://github.com/klacointe) klacointe - creator, maintainer
