<!--
Guiding Principles:

Changelogs are for humans, not machines.
There should be an entry for every single version.
The same types of changes should be grouped.
Versions and sections should be linkable.
The latest version comes first.
The release date of each version is displayed.
Mention whether you follow Semantic Versioning.

Usage:

Change log entries are to be added to the Unreleased section under the
appropriate stanza (see below). Each entry should ideally include a tag and
the Github issue reference in the following format:

* (<tag>) \#<issue-number> message

The issue numbers will later be link-ified during the release process so you do
not have to worry about including a link manually, but you can if you wish.

Types of changes (Stanzas):

"Features" for new features.
"Improvements" for changes in existing functionality.
"Deprecated" for soon-to-be removed features.
"Bug Fixes" for any bug fixes.
"Client Breaking" for breaking CLI commands and REST routes.
"State Machine Breaking" for breaking the AppState

Ref: https://keepachangelog.com/en/1.0.0/
-->

# Changelog

## [Unreleased]

## [agoric-upgrade-7] - 2022-08-02

* Merge cosmos/gaia v7.0.2 [diff](https://github.com/cosmos/gaia/compare/v7.0.2...Agoric:ag0:Agoric-upgrade-7)

## [agoric-upgrade-6] - 2022-07-15

* Incorporate `ante.NewSetUpContextDecorator()` into ante handlers to reset gas meter for correct calculation
* Implement update handler for `agoric-upgrade-6` that sets MaxGas to 120000000
