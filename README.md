# morse

Morse Code Practice with Nelson

International Morse code for [Nelson](https://nelson-lang.github.io/nelson-website/):

encode text to dots and dashes and decode it back, look up the code table,
turn a message into keyed-tone audio, play it or save it to a WAV file, and
practice with an interactive trainer.

## Load

```matlab
run('/path/to/morse/loader.m')
```

## Quick start

```matlab
morse.encode('SOS')                 % '... --- ...'
morse.decode('... --- ...')         % 'SOS'
morse.decode(morse.encode('HELLO WORLD'))   % 'HELLO WORLD'

morse.encode('<AR>')                % prosign, run together: '.-.-.'
morse.encode(char(201))             % accented letters (E acute): '..-..'
morse.encode({'SOS', 'OK'})         % string array / cellstr join into words

morse.table()                       % print the ITU-R M.1677-1 table
morse.prosigns()                    % common prosigns (AR, SK, BT, ...)
morse.isvalid('... --- ...')        % true

morse.play('CQ CQ', 'WPM', 18, 'Frequency', 600)   % send it to the speaker
morse.towav('sos.wav', 'SOS')                       % or write a WAV file
morse.fromwav('sos.wav')                            % ... and decode it back: 'SOS'

morse.practice()                    % open the interactive trainer
```

## Functions

| Function | Purpose |
|----------|---------|
| `morse.encode(text, ...)` | Text to Morse code. Accepts char/string/cellstr; options: `LetterSeparator`, `WordSeparator`, `Dot`, `Dash`, `OnUnknown`, `Prosigns`. |
| `morse.decode(code, ...)` | Morse code back to text. Options: `Dot`, `Dash`, `OnUnknown`, `Placeholder`. |
| `morse.table()` | The code table, printed or returned as an N-by-2 cell array. |
| `morse.prosigns()` | The common procedural signals (prosigns). |
| `morse.isvalid(code)` | True when every group of a Morse string decodes. |
| `morse.tone(input, ...)` | Synthesize the audio samples `[y, fs]` (no playback). |
| `morse.play(input, ...)` | Synthesize and play on the default output device (`Block`, false for non-blocking). |
| `morse.towav(file, input, ...)` | Synthesize and write a WAV file. |
| `morse.fromwav(file, ...)` | Detect the tone in a WAV file and decode it back to text. |
| `morse.practice()` | Interactive trainer window. |

### Audio options

`morse.tone`, `morse.play` and `morse.towav` share the same options:

- `WPM` (default `20`) — element speed in words per minute (PARIS convention).
- `Farnsworth` (default `[]`) — when set below `WPM`, keeps the dots and dashes
  crisp while stretching the gaps between letters and words (ARRL timing), for
  learning at a slower overall pace.
- `Frequency` (default `700`) — tone frequency in hertz.
- `SampleRate` (default `8000`) — samples per second.
- `Amplitude` (default `0.6`) — peak amplitude in `[0, 1]`.
- `RampMs` (default `5`) — raised-cosine edge ramp, in milliseconds, to avoid
  clicks.
- `Input` (`'auto'`, `'text'` or `'code'`) — how the argument is interpreted;
  `'auto'` tells `'SOS'` from `'... --- ...'` apart.

`morse.play`, `morse.towav` and `morse.fromwav` use Nelson's core `audio`
module. `morse.fromwav` measures the element speed from the audio (the WPM need
not be known), finds the tone frequency automatically for a clean recording
(pass `Frequency` to lock onto a known tone in noise), and separates the letter
and word gaps by their own clustering, so Farnsworth-spaced sending decodes too.

## Examples

See `examples/morse_demo.m` for a short tour.

## Tests

```matlab
test_run('/path/to/morse/tests/test_morse.m')
```

## License

LGPL-3.0-or-later.
