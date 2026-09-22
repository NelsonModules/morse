%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function [text, code, info] = fromwav(filename, opts)
  % TEXT = morse.fromwav(FILENAME) reads the WAV file FILENAME, detects the
  % keyed Morse tone in it and decodes it to text. It is the inverse of
  % morse.towav: morse.fromwav on a file written by morse.towav('f.wav', 'SOS')
  % returns 'SOS'.
  %
  % The tone is turned into an on/off envelope (matched to the tone frequency),
  % thresholded, and read as runs: the short and long tones become dits and
  % dahs, and the silences become the gaps inside a letter, between letters and
  % between words. The element speed is measured from the audio, so the WPM does
  % not have to be known in advance.
  %
  % [TEXT, CODE] = morse.fromwav(...) also returns the recovered Morse code
  % string (dots, dashes, spaces and '/'), the same form morse.encode produces.
  %
  % [TEXT, CODE, INFO] = morse.fromwav(...) also returns a struct with the
  % detected 'frequency' (Hz), 'unit' (seconds), 'wpm', 'threshold' and the
  % number of 'elements' found.
  %
  % Name-value options:
  %   'Frequency'    (default [])   the tone frequency in hertz; [] estimates it
  %                  from the dominant spectral peak, which suits a clean signal.
  %   'WindowMs'     (default 5)    envelope smoothing window in milliseconds.
  %   'Threshold'    (default [])   on/off threshold on the normalized envelope
  %                  in [0, 1]; [] picks it automatically between the tone and
  %                  the silence level.
  %   'MinElementMs' (default 10)   on-runs shorter than this are treated as
  %                  glitches and ignored.
  %
  % See also morse.towav, morse.decode, morse.tone.
  arguments
    filename
    opts.Frequency double = []
    opts.WindowMs (1,1) double {mustBePositive} = 5
    opts.Threshold double = []
    opts.MinElementMs (1,1) double {mustBeGreaterThanOrEqual(opts.MinElementMs, 0)} = 10
  end
  filename = morse_text_arg(filename, 'FILENAME');
  if isempty(filename)
    error('morse:invalidFilename', 'FILENAME must not be empty.');
  end
  if ~isempty(opts.Frequency)
    mustBePositive(opts.Frequency);
  end
  if ~isempty(opts.Threshold)
    mustBeGreaterThanOrEqual(opts.Threshold, 0);
    mustBeLessThanOrEqual(opts.Threshold, 1);
  end
  [y, fs] = audioread(filename);
  [code, info] = morse_detect_code(y, fs, opts);
  if isempty(code)
    text = '';
  else
    text = morse.decode(code);
  end
end
%=============================================================================
