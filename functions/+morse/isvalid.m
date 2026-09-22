%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function tf = isvalid(code)
  % TF = morse.isvalid(CODE) is true when CODE is a non-empty Morse string made
  % only of dots, dashes, letter spaces and word slashes in which every dot/dash
  % group matches a character in the table. morse.isvalid('... --- ...') is
  % true; a stray group such as '........' makes it false.
  %
  % See also morse.decode, morse.table.
  code = morse_text_arg(code, 'CODE');
  if isempty(strtrim(code))
    tf = false;
    return
  end
  if ~all(code == '.' | code == '-' | code == '/' | isspace(code))
    tf = false;
    return
  end
  [~, unknown] = morse.decode(code);
  tf = isempty(unknown);
end
%=============================================================================
