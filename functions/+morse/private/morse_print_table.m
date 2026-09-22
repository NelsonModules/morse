%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function s = morse_print_table(book)
  % Render the code table as an aligned, grouped block of text (letters, then
  % digits, then punctuation), four entries per row. Returns the text; prints it
  % when called with no output. Shared by morse.table and the trainer's table
  % view so both look the same.
  chars = book.chars;
  codes = book.codes;
  isLetter = cellfun(@(c) c >= 'A' && c <= 'Z', chars);
  isDigit = cellfun(@(c) c >= '0' && c <= '9', chars);
  isAccent = cellfun(@(c) double(c) > 127, chars);
  isPunct = ~(isLetter | isDigit | isAccent);

  lines = {};
  lines{end + 1} = _('International Morse code (ITU-R M.1677-1)');
  lines{end + 1} = repmat('-', 1, 41);
  lines = [lines, section(_('Letters'), chars(isLetter), codes(isLetter))];
  lines = [lines, section(_('Digits'), chars(isDigit), codes(isDigit))];
  lines = [lines, section(_('Punctuation'), chars(isPunct), codes(isPunct))];
  lines = [lines, section(_('Accented letters'), chars(isAccent), codes(isAccent))];
  s = strjoin(lines, char(10));
  if nargout == 0
    disp(s);
    clear s
  end
end
%=============================================================================
function out = section(title, chars, codes)
  out = {'', [title, ':']};
  perRow = 4;
  cells = cell(1, numel(chars));
  for k = 1:numel(chars)
    cells{k} = sprintf('  %-3s %-8s', chars{k}, codes{k});
  end
  row = '';
  for k = 1:numel(cells)
    row = [row, cells{k}]; %#ok<AGROW>
    if mod(k, perRow) == 0
      out{end + 1} = row; %#ok<AGROW>
      row = '';
    end
  end
  if ~isempty(row)
    out{end + 1} = row;
  end
end
%=============================================================================
