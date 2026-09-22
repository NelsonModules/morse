%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
% <--AUDIO REQUIRED-->
%=============================================================================
% towav writes a readable WAV file.
f = [tempdir(), 'test_morse_', createGUID(), '.wav'];
morse.towav(f, 'SOS');
info = audioinfo(f);
assert_isequal(info.SampleRate, 8000);
[yr, fsr] = audioread(f);
assert_isequal(fsr, 8000);
assert_istrue(numel(yr) == 27 * round((1.2 / 20) * 8000));
delete(f);
%=============================================================================
% fromwav round-trips several messages, speeds and frequencies.
cases = {{'SOS', 20, 700}, {'HELLO WORLD', 12, 500}, {'CQ DE F4ABC', 25, 900}, {'PARIS', 30, 600}};
for k = 1:numel(cases)
  c = cases{k};
  f = [tempdir(), 'test_morse_fw_', createGUID(), '.wav'];
  morse.towav(f, c{1}, 'WPM', c{2}, 'Frequency', c{3});
  [text, code, dinfo] = morse.fromwav(f);
  assert_isequal(text, c{1});
  assert_isequal(code, morse.encode(c{1}));
  assert_istrue(abs(dinfo.frequency - c{3}) < 25);
  delete(f);
end
%=============================================================================
% fromwav decodes Farnsworth spacing too.
f = [tempdir(), 'test_morse_fw_', createGUID(), '.wav'];
morse.towav(f, 'HELLO WORLD', 'WPM', 25, 'Farnsworth', 8, 'Frequency', 600);
assert_isequal(morse.fromwav(f), 'HELLO WORLD');
delete(f);
%=============================================================================
% Playback (morse.play / audioplayer) needs a real output device and lives in
% test_morse_play.m, tagged <--AUDIO OUTPUT REQUIRED-->.
%=============================================================================
