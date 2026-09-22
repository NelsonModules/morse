# Changelog

All notable changes to the `morse` module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-22

Initial release.

### Added

- `morse.encode` and `morse.decode`: turn text into International Morse code
  (ITU-R M.1677-1) and back. Case is ignored. You can set the separators, the
  dot and dash symbols, and what happens with characters that are not in the
  table.
- `morse.table`: show the code table, or return it as a cell array.
- `morse.isvalid`: check whether a string is valid Morse code.
- `morse.prosigns`, and prosigns in `morse.encode`: a group in angle brackets
  such as `<AR>` or `<SK>` is sent as one run-together symbol (option
  `Prosigns`, on by default).
- Accented letters from the ITU extension (A grave, A/O/U diaeresis, C cedilla,
  E grave, E acute, N tilde), for both encoding and decoding.
- `morse.tone`: build the audio for a message. It uses PARIS timing, and you
  can set the speed (WPM), tone frequency, sample rate, volume, edge ramps and
  Farnsworth spacing.
- `morse.play`: play the audio. Use `Block, false` to keep working while it
  plays; it then returns the `audioplayer`.
- `morse.towav`: save the audio to a WAV file.
- `morse.fromwav`: read a WAV file and decode the Morse in it. It finds the tone
  frequency and the speed on its own, and handles Farnsworth spacing.
- `morse.practice`: a simple training window. Type a message, see its Morse,
  and play it. You can set the code speed, the overall (Farnsworth) speed and
  the tone, save a WAV file, and open the code table.
- `morse.encode`, `morse.tone`, `morse.play` and `morse.towav` also take a
  string array or a cellstr; the parts are joined into words.
- English and French (fr_FR) text for the error messages and the interface,
  loaded through `i18nHelpers`.
