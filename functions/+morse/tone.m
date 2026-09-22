%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function [y, fs] = tone(input, opts)
  % [Y, FS] = morse.tone(INPUT) synthesizes the Morse audio for INPUT and
  % returns the samples Y (a column vector in [-1, 1]) and the sample rate FS,
  % without playing anything. INPUT is either plain text ('SOS') or an already
  % formed Morse code string ('... --- ...'); by default the two are told apart
  % automatically.
  %
  % Timing is the PARIS convention: an element unit of 1.2/WPM seconds, a dit of
  % one unit, a dah of three, a one-unit gap inside a letter, three units
  % between letters and seven between words. Each keyed tone is a raised-cosine
  % shaped sine so it does not click.
  %
  % Name-value options:
  %   'WPM'        (default 20)   element speed in words per minute.
  %   'Farnsworth' (default [])   when set below WPM, stretch the letter and
  %                word gaps (ARRL timing) so beginners get crisp characters at
  %                a slower overall pace; [] keeps standard spacing.
  %   'Frequency'  (default 700)  tone frequency in hertz.
  %   'SampleRate' (default 8000) samples per second.
  %   'Amplitude'  (default 0.6)  peak amplitude in [0, 1].
  %   'RampMs'     (default 5)    raised-cosine edge ramp in milliseconds.
  %   'Input'  'auto' (default), 'text' or 'code' - how INPUT is interpreted.
  %
  % See also morse.play, morse.towav, morse.encode.
  arguments
    input
    opts.WPM (1,1) double {mustBePositive} = 20
    opts.Farnsworth double = []
    opts.Frequency (1,1) double {mustBePositive} = 700
    opts.SampleRate (1,1) double {mustBePositive} = 8000
    opts.Amplitude (1,1) double {mustBeGreaterThanOrEqual(opts.Amplitude, 0), mustBeLessThanOrEqual(opts.Amplitude, 1)} = 0.6
    opts.RampMs (1,1) double {mustBeGreaterThanOrEqual(opts.RampMs, 0)} = 5
    opts.Input {mustBeMember(opts.Input, {'auto', 'text', 'code'})} = 'auto'
  end
  input = morse_text_arg(input, 'INPUT');
  if ~isempty(opts.Farnsworth)
    mustBePositive(opts.Farnsworth);
  end

  switch opts.Input
    case 'text'
      code = morse.encode(input);
    case 'code'
      code = input;
    otherwise
      if morse_is_code(input)
        code = input;
      else
        code = morse.encode(input);
      end
  end
  [y, fs] = morse_render(code, opts);
end
%=============================================================================
