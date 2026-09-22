%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function w = morse_beep(dur, freq, fs, amp, rampMs)
  % One keyed tone: a sine of frequency FREQ and amplitude AMP lasting DUR
  % seconds at sample rate FS, with a raised-cosine ramp of RAMPMS milliseconds
  % at each end. The ramp removes the click a hard on/off edge makes, which is
  % what a real keyer's envelope does. Returns a column vector.
  n = round(dur * fs);
  if n <= 0
    w = zeros(0, 1);
    return
  end
  t = (0:n - 1)' / fs;
  w = amp * sin(2 * pi * freq * t);
  r = round(rampMs / 1000 * fs);
  r = min(r, floor(n / 2));
  if r >= 1
    up = 0.5 * (1 - cos(pi * (0:r - 1)' / r));
    w(1:r) = w(1:r) .* up;
    w(n - r + 1:n) = w(n - r + 1:n) .* flipud(up);
  end
end
%=============================================================================
