# Egypt Guide

Flutter tourism companion for Egypt.

## Flight booking flow

The flight section is intentionally kept simple:

1. Search route/date/passengers
2. Show available flight offers with live schedule + fare from the connected provider
3. Tap an offer and choose available seats when the airline provides a seat map
4. Enter passenger/contact details
5. Pay securely with Paymob
6. Create the airline booking and show the booking reference

There are no hard-coded flight prices or schedules in the Flutter app.

Legacy flight detail, demo payment-success, e-ticket and boarding-pass screens were removed because they were not part of this streamlined flow.

## Backend

The Flutter app calls the Cloudflare Worker configured in `FlightService` and `PaymobService`.
A reference Worker source is included in `backend/cloudflare_worker.js`.

## Run

```bash
flutter pub get
flutter analyze
flutter run
```
