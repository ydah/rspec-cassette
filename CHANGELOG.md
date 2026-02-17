# Changelog

## 0.4.0 (2026-02-17)

- Add `ignore_request` block support for custom passthrough conditions.
- Extend `NetConnectManager` to translate `ignore_request` blocks into WebMock-compatible `allow` matchers.
- Add net connection controls compatible with VCR migration use cases:
  - `allow_http_connections_when_no_cassette`
  - `ignore_localhost`
  - `ignore_hosts`
- Add `NetConnectManager` and wire it into the RSpec around hook to enforce and restore WebMock net-connect behavior per example.

## 0.3.0 (2026-02-17)

- Improve sanitization to support non-ASCII characters in cassette names derived from VCR metadata.

## 0.2.0 (2026-02-17)

- Add MetadataResolver to support VCR-compatible `vcr:` metadata alongside existing `use_cassette:` metadata.

## 0.1.0 (2026-02-16)

- Initial release.
