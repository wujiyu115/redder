# Reeder Flutter - Verification & Testing Checklist

## 1. Build Verification

### Compilation
- [ ] `flutter pub get` completes without errors
- [ ] `flutter analyze` reports no errors (warnings acceptable)
- [ ] `flutter build ios --release` compiles successfully
- [ ] `flutter build apk --release` compiles successfully
- [ ] `flutter build appbundle --release` compiles successfully
- [ ] Isar code generation: `dart run build_runner build` completes

### Startup
- [ ] App launches on iOS simulator (iPhone 15 Pro)
- [ ] App launches on Android emulator (API 26+)
- [ ] Cold start time < 2 seconds
- [ ] Isar database initializes without errors
- [ ] No crash on first launch (empty database)

---

## 2. MVP Integration Test (End-to-End)

### Add Subscription Flow
- [ ] Tap "+" button on source list
- [ ] Enter RSS feed URL (e.g., https://feeds.arstechnica.com/arstechnica/index)
- [ ] Feed discovery finds the feed
- [ ] Preview shows feed title and description
- [ ] Confirm adds feed to source list
- [ ] Feed appears under correct category (Blogs/Podcasts/Videos)

### Refresh Flow
- [ ] Pull-to-refresh triggers feed fetch
- [ ] Loading indicator shows during refresh
- [ ] New articles appear after refresh
- [ ] Elastic bounce animation plays on release
- [ ] Refresh completes within 30 seconds

### Browse & Read Flow
- [ ] Tap feed in source list → article list loads
- [ ] Article list shows title, summary, thumbnail, time
- [ ] Scroll loads more articles (infinite scroll)
- [ ] Tap article → detail page opens with slide transition
- [ ] Article content renders correctly (images, links, code blocks)
- [ ] Reader View strips clutter
- [ ] Left swipe from right edge loads next article
- [ ] Right swipe from left edge goes back
- [ ] Nav bar hides on scroll down, shows on scroll up

### Tag & Organize Flow
- [ ] Bottom action bar shows Later/Bookmark/Favorite buttons
- [ ] Tap tag button toggles highlight
- [ ] Tagged articles appear in corresponding tag timeline
- [ ] Swipe right on list item → Later tag
- [ ] Swipe left on list item → Share

### Theme Switching
- [ ] Settings → Theme shows all 5 options
- [ ] Light theme applies correctly
- [ ] Dark theme applies correctly
- [ ] OLED theme applies correctly (pure black background)
- [ ] Dark Light hybrid: dark list + light content viewer
- [ ] System mode follows device setting
- [ ] Theme switch has 300ms crossfade animation

---

## 3. Platform Compatibility

### iOS 15.0+
- [ ] Test on iOS 15 simulator
- [ ] Test on iOS 16 simulator
- [ ] Test on iOS 17 simulator/device
- [ ] All UI renders correctly
- [ ] No deprecated API warnings

### Android 8.0 (API 26)+
- [ ] Test on API 26 emulator
- [ ] Test on API 30 emulator
- [ ] Test on API 34 emulator/device
- [ ] All UI renders correctly
- [ ] Permissions granted correctly

---

## 4. Tablet & Orientation

### iPad
- [ ] Portrait: 2-column layout (article list + detail)
- [ ] Landscape: 3-column layout (source + article list + detail)
- [ ] Source list slides in from left in portrait mode
- [ ] Column widths are draggable
- [ ] Rotation transition is smooth

### Android Tablet
- [ ] Portrait: 2-column layout
- [ ] Landscape: 3-column layout
- [ ] Same adaptive behavior as iPad

---

## 5. Accessibility (VoiceOver / TalkBack)

### VoiceOver (iOS)
- [ ] Source list items announce: title + unread count
- [ ] Article list items announce: feed name, title, summary, time
- [ ] Buttons are labeled correctly
- [ ] Navigation is logical (top-to-bottom, left-to-right)
- [ ] Swipe gestures have accessible alternatives

### TalkBack (Android)
- [ ] Same checks as VoiceOver
- [ ] Focus order is logical
- [ ] Custom components are accessible

---

## 6. Dynamic Font Size

- [ ] iOS: Settings → Accessibility → Larger Text
  - [ ] Small text size: layout doesn't break
  - [ ] Default text size: normal appearance
  - [ ] Large text size: text scales, layout adapts
  - [ ] Extra large: text scales up to 1.5x, clamped
- [ ] Android: Settings → Display → Font size
  - [ ] Same checks as iOS

---

## 7. Performance Metrics

- [ ] Cold start < 2 seconds
- [ ] Article list scrolling: 60fps (no jank)
- [ ] Memory usage < 200MB with 1000+ articles
- [ ] Database queries < 50ms (check logs for SLOW QUERY warnings)
- [ ] Theme switch animation: smooth 300ms crossfade
- [ ] Page transition: smooth 350ms slide

---

## 8. Final Regression

- [ ] OPML import works (select file → parse → import)
- [ ] OPML export generates valid OPML 2.0
- [ ] Search finds articles by title and content
- [ ] Search highlights keywords
- [ ] Scroll position is saved and restored per timeline
- [ ] Podcast player: play/pause/seek/speed/chapters
- [ ] Video player: inline playback works
- [ ] Image viewer: pinch zoom, swipe between images
- [ ] In-app browser: forward/back/refresh/share
- [ ] Filter editor: create/edit/delete filters
- [ ] Folder management: create/rename/delete
- [ ] Bionic Reading mode applies to article content
- [ ] JSON Feed export generates valid JSON
- [ ] Privacy policy page renders correctly
- [ ] Background refresh triggers on schedule
- [ ] No memory leaks after extended use (30+ minutes)
