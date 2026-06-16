# Shipping Glance to the App Store

A start-to-finish checklist for getting Glance onto the public App Store. Items marked
**(you)** can only be done by you in a browser/Xcode; everything else is already wired up
in this repo.

## 0. One-time account + machine setup

- [ ] **(you)** Enroll in the [Apple Developer Program](https://developer.apple.com/programs/enroll/)
      — $99/yr, approval usually 24–48h. Required for the App Store (the free Apple ID
      only does 7-day sideloads).
- [ ] **(you)** Make full Xcode the active toolchain (currently set to Command Line Tools):
      ```sh
      sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
      ```
      Verify with `xcodebuild -version`.
- [ ] Regenerate the project after any `project.yml` change: `./setup.sh` (or `xcodegen generate`).

## 1. Already done in this repo ✅

- **App icon** — `Glance/Assets.xcassets/AppIcon.appiconset` (single 1024×1024, dark + blue accent).
- **Privacy manifest** — `Glance/PrivacyInfo.xcprivacy` (declares UserDefaults reason `CA92.1`;
  no data collected, no tracking).
- **Icon wired into build** — `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` in `project.yml`.
- Usage strings for Photos + Apple Music are already in `project.yml`.

## 2. App Store Connect record  **(you)**

1. The bundle id `dev.stroud.glance` must be unique across the whole App Store. If it's taken,
   change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` and re-run `./setup.sh`.
2. [App Store Connect](https://appstoreconnect.apple.com) → **Apps → + → New App**:
   - Platform: iOS · Name: `Glance` · Primary language · Bundle ID: `dev.stroud.glance` · SKU: `glance`.
3. Fill in:
   - **Category** — Utilities (or Lifestyle).
   - **Privacy Policy URL** — *required* because the app requests Photos + Apple Music. A simple
     hosted page stating "Glance stores all settings on-device and sends no personal data to any
     server" is enough. (e.g. publish one to docs.stroud.dev.)
   - **App Privacy questionnaire** — answer **"Data Not Collected"** (nothing leaves the device).
   - **Age rating** — fill the questionnaire (all "No" → 4+).
   - **Support URL** — the GitHub repo URL works.

## 3. Screenshots  **(you)**

App Store Connect requires **13″ iPad** screenshots at exactly **2732×2048** (landscape — Glance
is landscape-only). The existing `docs/*.jpeg` are 2136×1472 and will be rejected.

Capture fresh ones:
1. Open the project in Xcode, pick the **iPad Pro 13-inch** simulator, ⌘R.
2. Rotate to landscape, let each scene appear, ⌘S to save a screenshot (lands on the Desktop at
   the right pixel size).
3. Upload 3–5 (Weather, News, YouTube, Photos make a good set).

## 4. Archive + upload

**Easiest (Xcode GUI):**
1. Xcode → choose **Any iOS Device (arm64)** as the destination (not a simulator).
2. **Product → Archive**.
3. In the Organizer that opens: **Distribute App → App Store Connect → Upload**. Let Xcode
   manage signing (it creates the Distribution cert + provisioning profile automatically).

**CLI alternative** (after the Distribution cert exists): `./scripts/archive.sh` — see that script.

## 5. Submit for review  **(you)**

1. In App Store Connect, the uploaded build appears under the version after a few minutes of
   processing. Attach it to the **1.0** version.
2. Add **"What's New"** / description / keywords.
3. **Add for Review → Submit**. First reviews typically take ~24–48h.

## Notes / likely review snags

- Glance is iPad-only and **landscape-only** — reviewers test on iPad, which is fine, but make
  sure every enabled scene shows *something* on a fresh install (empty scenes are auto-skipped,
  which is good).
- The Photos and Apple Music permission prompts must have clear usage strings (they do).
- Bump `CURRENT_PROJECT_VERSION` (build number) in `project.yml` for every new upload of the
  same `MARKETING_VERSION`.
