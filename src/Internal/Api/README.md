# API Support

Different Matrix spec versions have different rules. The Elm SDK doesn't just assume that the spec remains the same in new versions, and instead requires developers to explicitly implement each version.

This file explains what features are supported in which spec versions.

> **DISCLAIMER:** All information in this file is prone to change! I am a single developer creating this in their spare time, and even though I try to be consistent, I may decide (not) to develop certain parts of the API at any time!

The icons have the following meaning:

- ✔️ = Supported
- ⚠️ = To be announced
- ⚡ = Under development
- ❌ = Not supported by SDK
- ⛔ = Not supported by spec

Note that **under development** doesn't always mean that it _will be_ supported.

## Communication

| **Spec version** |   | Syncing | Redaction |
| ---------------- | - | ------- | --------- |
| v1.8   || ⚡ | ⚡ |
| v1.7   || ⚡ | ⚡ |
| v1.6   || ⚠️ | ⚠️ |
| v1.5   || ✔️ | ✔️ |
| v1.4   || ✔️ | ✔️ |
| v1.3   || ✔️ | ✔️ |
| v1.2   || ✔️ | ✔️ |
| v1.1   || ❌ | ✔️ |
| r0.6.1 || ❌ | ✔️ |
| r0.6.0 || ❌ | ✔️ |
| r0.5.0 || ❌ | ✔️ |
| r0.4.0 || ❌ | ✔️ |
| r0.3.0 || ❌ | ✔️ |
| r0.2.0 || ❌ | ✔️ |
| r0.1.0 || ❌ | ✔️ |
| r0.0.1 || ❌ | ✔️ |
| r0.0.0 || ❌ | ✔️ |

## Changing room member status

| **Spec version** |   | Inviting | Joining room id | Leaving room | Kick user | Ban user |
| ---------------- | - | -------- | --------------- | ------------ | --------- | -------- |
| v1.8   || ⚡ | ⚡ | ⚡ | ⚡ | ⚡ |
| v1.7   || ⚡ | ⚡ | ⚡ | ⚡ | ⚡ |
| v1.6   || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| v1.5   || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| v1.4   || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| v1.3   || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| v1.2   || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| v1.1   || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.6.1 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.6.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.5.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.4.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.3.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.2.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.1.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.0.1 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |
| r0.0.0 || ✔️ | ✔️ | ✔️ | ⚡ | ✔️ |

## Getting events for a room

| **Spec version** |   | Event | Joined members | Event at timestamp |
| ---------------- | - | ----- | -------------- | ------------------ |
| v1.8   || ⚡ | ⚡ | ⚡ |
| v1.7   || ⚡ | ⚡ | ⚡ |
| v1.6   || ✔️ | ✔️ | ⚠️ |
| v1.5   || ✔️ | ✔️ | ⛔ |
| v1.4   || ✔️ | ✔️ | ⛔ |
| v1.3   || ✔️ | ✔️ | ⛔ |
| v1.2   || ✔️ | ✔️ | ⛔ |
| v1.1   || ✔️ | ✔️ | ⛔ |
| r0.6.1 || ✔️ | ✔️ | ⛔ |
| r0.6.0 || ✔️ | ✔️ | ⛔ |
| r0.5.0 || ✔️ | ✔️ | ⛔ |
| r0.4.0 || ⛔ | ✔️ | ⛔ |
| r0.3.0 || ⛔ | ✔️ | ⛔ |
| r0.2.0 || ⛔ | ✔️ | ⛔ |
| r0.1.0 || ⛔ | ✔️ | ⛔ |
| r0.0.1 || ⛔ | ✔️ | ⛔ |
| r0.0.0 || ⛔ | ✔️ | ⛔ |

## Sending events to a room

| **Spec version** |   | Message event | State event |
| ---------------- | - | ------------- | ----------- |
| v1.8   || ⚡ | ⚡ |
| v1.7   || ⚡ | ⚡ |
| v1.6   || ✔️ | ✔️ |
| v1.5   || ✔️ | ✔️ |
| v1.4   || ✔️ | ✔️ |
| v1.3   || ✔️ | ✔️ |
| v1.2   || ✔️ | ✔️ |
| v1.1   || ✔️ | ✔️ |
| r0.6.1 || ✔️ | ✔️ |
| r0.6.0 || ✔️ | ✔️ |
| r0.5.0 || ✔️ | ✔️ |
| r0.4.0 || ✔️ | ✔️ |
| r0.3.0 || ✔️ | ✔️ |
| r0.2.0 || ✔️ | ✔️ |
| r0.1.0 || ✔️ | ✔️ |
| r0.0.1 || ✔️ | ✔️ |
| r0.0.0 || ✔️ | ✔️ |
