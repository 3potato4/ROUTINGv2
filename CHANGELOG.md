# Release log

All shipped updates are labeled **V.#** (consecutive integers). Bump `shared/releaseVersion.ts` and add a section here on each release.

## V.2

- Consecutive **V.#** release labels (`shared/releaseVersion.ts`, `CHANGELOG.md`, project rule).
- **ReleaseVersionBadge** in the app header (and on loading/error screens); `releaseVersion` on `/api/health`.

## V.1

- Prefer Outfield **Latitude / Longitude** on CSV upload (skip upload-time Google Geocoding when coords are present).
- Outfield Account ID in customer ids (`outfield-…`).
- Partial CSV import, clear-data UX, cross-route and Western Philly routing fixes (prior work through `fba70f0`).
