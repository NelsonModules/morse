%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function morse_practice_table_window()
  % A small companion window that shows the International Morse code table in a
  % monospaced, scrollable panel. Opened by the trainer's "Code table" button.
  page = [0.97 0.97 0.98];
  readoutBg = [0.12 0.13 0.16];
  readoutFg = [0.90 0.92 0.96];
  W = 560; H = 560;
  fig = uifigure('Name', _('Morse Code Table'), 'Position', [200 120 W H], ...
    'Color', page);
  txt = morse_print_table(morse_codebook());
  lines = strsplit(txt, char(10));
  ta = uitextarea(fig, 'Value', lines, 'Position', [20 20 W-40 H-40], ...
    'BackgroundColor', readoutBg, 'FontColor', readoutFg, ...
    'FontName', 'monospaced', 'FontSize', 12);
  ta.Editable = 'off';
end
%=============================================================================
