%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function [code, diag] = morse_detect_code(y, fs, o)
  % Recover a Morse code string from an audio signal Y sampled at FS.
  %
  % The keyed tone is turned into an on/off envelope, thresholded, then read as
  % runs: the on-runs become dits and dahs, the silences between them become the
  % intra-letter, inter-letter and word gaps. O carries the resolved options
  % Frequency ([] = estimate the dominant tone), WindowMs, Threshold ([] = auto)
  % and MinElementMs. DIAG returns the numbers the detector inferred
  % (frequency, unit seconds, wpm, threshold) for inspection.
  diag = struct('frequency', NaN, 'unit', NaN, 'wpm', NaN, 'threshold', NaN, 'elements', 0);
  y = double(y);
  if ~isvector(y)
    y = mean(y, 2);               % mix a stereo/multichannel clip to mono
  end
  y = y(:);
  n = numel(y);
  code = '';
  if n < 4
    return
  end

  % --- tone frequency: given, or the dominant spectral peak above 50 Hz -------
  freq = o.Frequency;
  if isempty(freq)
    freq = morse_dominant_frequency(y, fs);
  end
  diag.frequency = freq;

  % --- tone-matched (quadrature) envelope -------------------------------------
  w = max(1, round(o.WindowMs / 1000 * fs));
  if isempty(freq) || ~isfinite(freq) || freq <= 0
    env = sqrt(morse_movavg(y .^ 2, w));          % broadband fallback
  else
    t = (0:n - 1)' / fs;
    ii = morse_movavg(y .* cos(2 * pi * freq * t), w);
    qq = morse_movavg(y .* sin(2 * pi * freq * t), w);
    env = sqrt(ii .^ 2 + qq .^ 2);
  end
  peak = max(env);
  if peak <= 0
    return
  end
  env = env / peak;

  % --- on/off threshold -------------------------------------------------------
  if isempty(o.Threshold)
    hi = env(env > 0.5);
    lo = env(env <= 0.5);
    onLevel = 1; offLevel = 0;
    if ~isempty(hi), onLevel = median(hi); end
    if ~isempty(lo), offLevel = median(lo); end
    thr = 0.5 * (onLevel + offLevel);
  else
    thr = o.Threshold;
  end
  diag.threshold = thr;
  keyed = env > thr;

  % --- on-runs and the interior gaps between them -----------------------------
  edges = diff([false; keyed; false]);
  starts = find(edges == 1);
  stops = find(edges == -1) - 1;
  if isempty(starts)
    return
  end
  onDur = stops - starts + 1;                      % samples per on-run
  gaps = starts(2:end) - stops(1:end - 1) - 1;     % samples per interior gap

  % Drop spurious tiny on-runs (and the gap they split) before measuring.
  minEl = max(1, round(o.MinElementMs / 1000 * fs));
  if any(onDur >= minEl)
    keepIdx = find(onDur >= minEl);
    if numel(keepIdx) < numel(onDur)
      newStarts = starts(keepIdx);
      newStops = stops(keepIdx);
      onDur = newStops - newStarts + 1;
      gaps = newStarts(2:end) - newStops(1:end - 1) - 1;
    end
  end

  unit = morse_estimate_unit(onDur, gaps);
  if ~isfinite(unit) || unit <= 0
    return
  end
  diag.unit = unit / fs;
  diag.wpm = 1.2 / (unit / fs);
  diag.elements = numel(onDur);

  % --- assemble the code ------------------------------------------------------
  % Intra-letter gaps stay one unit; the letter and word gaps are told apart by
  % their own clustering, so a Farnsworth clip (letter/word gaps stretched well
  % beyond 3 and 7 units) is read as correctly as a standard one.
  gapClass = morse_gap_classes(gaps, unit);
  parts = cell(1, numel(onDur));
  for k = 1:numel(onDur)
    sep = '';
    if k > 1
      switch gapClass(k - 1)
        case 2
          sep = ' / ';
        case 1
          sep = ' ';
      end
    end
    if onDur(k) >= 2 * unit
      sym = '-';
    else
      sym = '.';
    end
    parts{k} = [sep, sym];
  end
  code = strjoin(parts, '');
end
%=============================================================================
function cls = morse_gap_classes(gaps, unit)
  % Label each interior gap 0 (intra-letter), 1 (inter-letter) or 2 (word). A
  % gap below two units is intra. The remaining gaps are split into letter and
  % word by the midpoint of their own range; when they form a single cluster
  % (no word gaps present) they are all letter gaps.
  cls = zeros(numel(gaps), 1);
  isBig = gaps >= 2 * unit;
  big = gaps(isBig);
  if isempty(big)
    return
  end
  b = sort(big);
  if b(end) < 1.8 * b(1)
    cls(isBig) = 1;
    return
  end
  cut = 0.5 * (b(1) + b(end));
  idx = find(isBig);
  for i = 1:numel(idx)
    if gaps(idx(i)) >= cut
      cls(idx(i)) = 2;
    else
      cls(idx(i)) = 1;
    end
  end
end
%=============================================================================
function unit = morse_estimate_unit(onDur, gaps)
  % The element unit (dit length, in samples). Primarily the dit cluster of the
  % on-runs; when the on-runs form a single cluster they are taken as dits, and
  % when there are none the smallest gap is read as a three-unit letter gap.
  on = sort(onDur(:));
  unit = NaN;
  if ~isempty(on)
    if on(end) < 2 * on(1)
      unit = median(on);
    else
      cut = 0.5 * (on(1) + on(end));
      dits = on(on < cut);
      if isempty(dits)
        dits = on(1);
      end
      unit = median(dits);
    end
    return
  end
  if ~isempty(gaps)
    unit = min(gaps) / 3;
  end
end
%=============================================================================
function f = morse_dominant_frequency(y, fs)
  % The frequency of the strongest spectral component above 50 Hz.
  n = numel(y);
  nfft = min(n, 2 ^ 16);
  seg = y(1:nfft) .* hanning_window(nfft);
  mag = abs(fft(seg));
  half = floor(nfft / 2);
  mag = mag(1:half + 1);
  freqs = (0:half)' * (fs / nfft);
  mag(freqs < 50) = 0;
  [~, idx] = max(mag);
  f = freqs(idx);
end
%=============================================================================
function w = hanning_window(n)
  if n <= 1
    w = ones(n, 1);
    return
  end
  w = 0.5 * (1 - cos(2 * pi * (0:n - 1)' / (n - 1)));
end
%=============================================================================
