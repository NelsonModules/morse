%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
assert_isequal(morse_version(), '1.0.0');
%=============================================================================
% encode
assert_isequal(morse.encode('SOS'), '... --- ...');
assert_isequal(morse.encode('sos'), '... --- ...');
assert_isequal(morse.encode('HELLO WORLD'), '.... . .-.. .-.. --- / .-- --- .-. .-.. -..');
assert_isequal(morse.encode('E'), '.');
assert_isequal(morse.encode(''), '');
assert_isequal(morse.encode("SOS"), '... --- ...');
%=============================================================================
% encode: custom separators and symbols
assert_isequal(morse.encode('SO', 'LetterSeparator', '|'), '...|---');
assert_isequal(morse.encode('E', 'Dot', '*'), '*');
assert_isequal(morse.encode('AB', 'Dot', '.', 'Dash', '_'), '._ _...');
%=============================================================================
% encode: unknown handling
[c, sk] = morse.encode('A#B');
assert_isequal(c, '.- -...');
assert_isequal(sk, {'#'});
assert_isequal(morse.encode('A#B', 'OnUnknown', 'keep'), '.- # -...');
ok = false; try; morse.encode('#', 'OnUnknown', 'error'); catch e; ok = strcmp(e.identifier, 'morse:unknownCharacter'); end
assert_istrue(ok);
%=============================================================================
% decode
assert_isequal(morse.decode('... --- ...'), 'SOS');
assert_isequal(morse.decode('.... . .-.. .-.. --- / .-- --- .-. .-.. -..'), 'HELLO WORLD');
assert_isequal(morse.decode('.... . .-.. .-.. ---  .-- --- .-. .-.. -..'), 'HELLO WORLD');
%=============================================================================
% decode: unknown handling
[t, unk] = morse.decode('... ........ ---');
assert_isequal(t, 'S?O');
assert_isequal(unk, {'........'});
assert_isequal(morse.decode('... ........ ---', 'Placeholder', '@'), 'S@O');
ok = false; try; morse.decode('........', 'OnUnknown', 'error'); catch e; ok = strcmp(e.identifier, 'morse:unknownCode'); end
assert_istrue(ok);
%=============================================================================
% round trip on the full printable set
book = morse.table();
chars = [book{:, 1}];
assert_isequal(morse.decode(morse.encode(chars)), chars);
%=============================================================================
% table (26 letters + 10 digits + 18 punctuation + 8 accented = 62)
assert_isequal(size(book), [62 2]);
assert_isequal(book{1, 1}, 'A');
assert_isequal(book{1, 2}, '.-');
%=============================================================================
% prosigns: bracketed letters are keyed run-together as one symbol
assert_isequal(morse.encode('<SK>'), '...-.-');
assert_isequal(morse.encode('<AR>'), '.-.-.');
assert_isequal(morse.encode('<SOS>'), '...---...');
assert_isequal(morse.encode('CQ <AR>'), '-.-. --.- / .-.-.');
assert_isequal(morse.encode('<ar>'), '.-.-.');
% disabled: the brackets are just unknown characters that are skipped
assert_isequal(morse.encode('<AR>', 'Prosigns', false), '.- .-.');
prosignTable = morse.prosigns();
assert_isequal(size(prosignTable, 2), 3);
assert_isequal(prosignTable{1, 1}, 'AR');
assert_isequal(prosignTable{1, 3}, '.-.-.');
%=============================================================================
% accented letters (ITU extension), stored as code points so this test is ASCII
assert_isequal(morse.encode(char(201)), '..-..');          % E acute
assert_isequal(morse.encode(char(233)), '..-..');          % e acute (upper-cased)
assert_isequal(double(morse.decode('..-..')), 201);
assert_isequal(morse.encode(char([67 65 70 201])), '-.-. .- ..-. ..-..');
%=============================================================================
% string array and cellstr inputs join with a space (words)
assert_isequal(morse.encode({'SOS', 'OK'}), '... --- ... / --- -.-');
assert_isequal(morse.encode(["HELLO", "WORLD"]), morse.encode('HELLO WORLD'));
%=============================================================================
% edge cases: blank and unmappable-only input encode to nothing
assert_isequal(morse.encode('   '), '');
assert_isequal(morse.encode('###', 'OnUnknown', 'skip'), '');
assert_isequal(morse.decode(''), '');
assert_isequal(morse.decode('   '), '');
%=============================================================================
% isvalid
assert_istrue(morse.isvalid('... --- ...'));
assert_istrue(morse.isvalid('.... . .-.. .-.. --- / .-- --- .-. .-.. -..'));
assert_isfalse(morse.isvalid('........'));
assert_isfalse(morse.isvalid(''));
assert_isfalse(morse.isvalid('hello'));
%=============================================================================
% tone: timing and shape
[y, fs] = morse.tone('SOS', 'WPM', 20, 'Frequency', 700, 'SampleRate', 8000);
assert_isequal(fs, 8000);
assert_istrue(iscolumn(y));
% SOS at 20 WPM: 27 element-units of 1.2/20 s at 8000 Hz.
assert_isequal(numel(y), 27 * round((1.2 / 20) * 8000));
assert_istrue(max(abs(y)) <= 0.6 + 1e-9);
%=============================================================================
% tone: 'code' input equals text input
[y1, ~] = morse.tone('SOS');
[y2, ~] = morse.tone('... --- ...', 'Input', 'code');
assert_isequal(y1, y2);
%=============================================================================
% tone: empty input yields empty audio
[ye, fse] = morse.tone('');
assert_isequal(numel(ye), 0);
assert_isequal(fse, 8000);
%=============================================================================
% tone: Farnsworth lengthens the gaps but not the number of tones
[yf, ~] = morse.tone('OK', 'WPM', 20, 'Farnsworth', 10);
[yn, ~] = morse.tone('OK', 'WPM', 20);
assert_istrue(numel(yf) > numel(yn));
%=============================================================================
% Audio round trips (towav / fromwav / play) live in test_morse_audio.m, tagged
% <--AUDIO REQUIRED--> so the runner loads the core audio module for them.
%=============================================================================
% localization catalogs are present and well-formed
locDir = [modulepath('morse'), '/locale'];
for catalog = {'morse-errors-en_US.json', 'morse-errors-fr_FR.json', ...
               'morse-ui-en_US.json', 'morse-ui-fr_FR.json'}
  p = [locDir, '/', catalog{1}];
  assert_istrue(isfile(p));
  assert_istrue(isstruct(jsondecode(fileread(p))));
end
%=============================================================================
% invalid arguments
ok = false; try; morse.encode(5); catch e; ok = strcmp(e.identifier, 'morse:invalidText'); end
assert_istrue(ok);
ok = false; try; morse.tone('SOS', 'WPM', -1); catch e; ok = ~isempty(strfind(e.identifier, 'mustBePositive')); end
assert_istrue(ok);
%=============================================================================
