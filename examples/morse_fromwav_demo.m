%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
% Decode Morse from audio with morse.fromwav: a clean round trip, the same clip
% with the tone frequency detected automatically, a Farnsworth-spaced clip, and
% a noisy clip locked onto a known tone.
%=============================================================================
if ~ismodule('morse')
  run([fileparts(mfilename('fullpathext')), '/../loader.m']);
end
%=============================================================================
message = 'CQ CQ DE NELSON';
wav = [tempdir(), 'morse_fromwav_demo.wav'];

disp('=== 1. Write a WAV, then decode it back ===');
morse.towav(wav, message, 'WPM', 20, 'Frequency', 700);
fprintf('  wrote  : %s\n', wav);
[text, code, info] = morse.fromwav(wav);
fprintf('  code   : %s\n', code);
fprintf('  text   : %s\n', text);
fprintf('  detected: %.0f Hz, ~%.0f WPM, %d elements\n', ...
  info.frequency, info.wpm, info.elements);
fprintf('  matches original: %d\n', strcmp(text, message));
disp(' ');

disp('=== 2. Tone frequency found automatically ===');
% No 'Frequency' hint: fromwav estimates it from the dominant spectral peak.
info2 = struct();
[t2, ~, info2] = morse.fromwav(wav);
fprintf('  estimated tone: %.0f Hz -> %s\n', info2.frequency, t2);
disp(' ');

disp('=== 3. Farnsworth spacing (crisp elements, slow overall) ===');
morse.towav(wav, message, 'WPM', 28, 'Farnsworth', 10, 'Frequency', 600);
fprintf('  decoded: %s\n', morse.fromwav(wav));
disp(' ');

disp('=== 4. Noisy recording, locked onto a known 700 Hz tone ===');
[y, fs] = morse.tone(message, 'WPM', 20, 'Frequency', 700);
y = y + 0.25 * (2 * rand(size(y)) - 1);          % additive white noise
y = y / max(abs(y));
audiowrite(wav, y, fs);
fprintf('  auto frequency : %s\n', morse.fromwav(wav));
fprintf('  Frequency = 700: %s\n', morse.fromwav(wav, 'Frequency', 700));
disp(' ');

delete(wav);
disp('Tip: [text, code, info] = morse.fromwav(file) also returns the code and');
disp('     the detected frequency, unit, WPM and threshold.');
%=============================================================================
