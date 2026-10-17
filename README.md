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
2. Create your feature branch (`git checkout -b fix/my-fix`)
3. Make sure `crystal spec` and `crystal tool format --check src spec` pass
4. Push to the branch and open a Pull Request

Pull requests are squash-merged, so the **PR title** becomes the commit on
`master`. It must follow [Conventional Commits](https://www.conventionalcommits.org/)
(checked in CI), e.g. `fix: handle empty backtrace` or `feat: add environment context`.

### Releases

Releases are automated with [release-please](https://github.com/googleapis/release-please).
Don't bump versions by hand: on every merge to `master`, it opens (or updates) a
release PR that bumps `shard.yml` and `Airbrake::VERSION` and updates
`CHANGELOG.md`. Merging that PR tags `vX.Y.Z` and publishes a GitHub release.

- `fix:` → patch (`0.0.2` → `0.0.3`)
- `feat:` or breaking change (`feat!:`) → minor while below 1.0 (`0.0.2` → `0.1.0`)
- other types (`chore:`, `docs:`, `test:`…) don't trigger a release

## Contributors

- [klacointe](https://github.com/klacointe) klacointe - creator, maintainer
