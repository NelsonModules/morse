%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
% A short tour of the morse toolbox: the table, encoding, decoding, a round
% trip, and audio (played if an output device is available, otherwise written
% to a WAV file in tempdir).
%=============================================================================
if ~ismodule('morse')
  run([fileparts(mfilename('fullpathext')), '/../loader.m']);
end
%=============================================================================
disp('=== International Morse code table ===');
morse.table();
disp(' ');

disp('=== Encode ===');
message = 'HELLO WORLD';
code = morse.encode(message);
fprintf('  %-12s -> %s\n', message, code);
fprintf('  %-12s -> %s\n', 'SOS', morse.encode('SOS'));
fprintf('  %-12s -> %s\n', 'Nelson 2.0', morse.encode('Nelson 2.0'));
disp(' ');

disp('=== Decode ===');
fprintf('  %s -> %s\n', '... --- ...', morse.decode('... --- ...'));
fprintf('  round trip of ''%s'': %s\n', message, morse.decode(code));
disp(' ');

disp('=== Prosigns and accented letters ===');
fprintf('  %-8s -> %s\n', '<AR>', morse.encode('<AR>'));
fprintf('  %-8s -> %s\n', '<SK>', morse.encode('<SK>'));
fprintf('  accented (E acute) -> %s\n', morse.encode(char(201)));
morse.prosigns();
disp(' ');

disp('=== Audio ===');
[y, fs] = morse.tone(message, 'WPM', 18, 'Frequency', 700);
fprintf('  %d samples at %d Hz (%.2f s)\n', numel(y), fs, numel(y) / fs);
wav = [tempdir(), 'morse_demo.wav'];
morse.towav(wav, message, 'WPM', 18, 'Frequency', 700);
fprintf('  wrote %s\n', wav);
[back, ~, dinfo] = morse.fromwav(wav);
fprintf('  decoded from the WAV: %s (detected ~%.0f WPM, %.0f Hz)\n', ...
  back, dinfo.wpm, dinfo.frequency);
disp(' ');
disp('Tip: morse.play(''SOS'') sends it to the speaker;');
disp('     morse.practice() opens the interactive trainer.');
%=============================================================================
