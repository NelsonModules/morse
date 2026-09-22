%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function tf = morse_is_code(s)
  % True when S looks like an already-formed Morse code string: it holds at
  % least one dot or dash and nothing but dots, dashes, slashes and whitespace.
  % Used by the 'auto' input mode of tone/play/towav to tell 'SOS' (text) from
  % '... --- ...' (code) apart.
  if isempty(s)
    tf = false;
    return
  end
  hasSymbol = any(s == '.') || any(s == '-');
  onlyCode = all(s == '.' | s == '-' | s == '/' | isspace(s));
  tf = hasSymbol && onlyCode;
end
%=============================================================================
