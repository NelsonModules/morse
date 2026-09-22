%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
% <--AUDIO OUTPUT REQUIRED-->
%=============================================================================
% play returns the samples and sample rate it sent to the output device.
[y, fs] = morse.play('E', 'WPM', 30);
assert_isequal(fs, 8000);
assert_istrue(numel(y) == round((1.2 / 30) * 8000));
%=============================================================================
% 'Block', false returns immediately with the audioplayer handle.
[y2, fs2, player] = morse.play('SOS', 'WPM', 20, 'Block', false);
assert_isequal(fs2, 8000);
assert_isequal(class(player), 'audioplayer');
stop(player);
%=============================================================================
