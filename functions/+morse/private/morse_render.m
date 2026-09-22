%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function [y, fs] = morse_render(code, o)
  % Synthesize the audio for a Morse CODE string (dot/dash groups, spaces
  % between letters, '/' between words) using the resolved options O with
  % fields WPM, Farnsworth, Frequency, SampleRate, Amplitude and RampMs.
  % Timing follows the standard element ratios (dit 1, dah 3, intra-letter gap
  % 1, inter-letter gap 3, word gap 7 units) with an element unit of 1.2/WPM
  % seconds (the PARIS convention). When Farnsworth is set below WPM the letter
  % and word gaps are stretched by the ARRL formula so the elements stay crisp
  % while the overall speed drops. Returns a column vector Y and its rate FS.
  fs = o.SampleRate;
  unit = 1.2 / o.WPM;

  farns = o.Farnsworth;
  if isempty(farns) || farns >= o.WPM
    interLetterGap = 3 * unit;
    wordGap = 7 * unit;
  else
    ta = (60 * o.WPM - 37.2 * farns) / (o.WPM * farns);
    interLetterGap = 3 * ta / 19;
    wordGap = 7 * ta / 19;
  end

  dit = morse_beep(unit, o.Frequency, fs, o.Amplitude, o.RampMs);
  dah = morse_beep(3 * unit, o.Frequency, fs, o.Amplitude, o.RampMs);
  gIntra = zeros(round(unit * fs), 1);
  gLetter = zeros(round(interLetterGap * fs), 1);
  gWord = zeros(round(wordGap * fs), 1);

  segs = {};
  words = strsplit(strtrim(code), '/');
  for wi = 1:numel(words)
    letters = strsplit(strtrim(words{wi}), ' ');
    firstLetter = true;
    for li = 1:numel(letters)
      pat = letters{li};
      if isempty(pat)
        continue
      end
      if ~firstLetter
        segs{end + 1} = gLetter; %#ok<AGROW>
      end
      firstLetter = false;
      for si = 1:numel(pat)
        if si > 1
          segs{end + 1} = gIntra; %#ok<AGROW>
        end
        if pat(si) == '.'
          segs{end + 1} = dit; %#ok<AGROW>
        elseif pat(si) == '-'
          segs{end + 1} = dah; %#ok<AGROW>
        end
      end
    end
    if wi < numel(words)
      segs{end + 1} = gWord; %#ok<AGROW>
    end
  end
  if isempty(segs)
    y = zeros(0, 1);
  else
    y = cat(1, segs{:});
  end
end
%=============================================================================
