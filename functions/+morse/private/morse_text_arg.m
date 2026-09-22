%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function s = morse_text_arg(value, name)
  % Normalize a text input into a char row vector, raising morse:invalidText
  % with the argument NAME otherwise. Accepts a char row vector, a scalar
  % string, a string array or cellstr (its elements are joined by a space, so a
  % multi-line message becomes space-separated words) and a multi-row char
  % array (its rows are joined the same way). Shared by encode, decode, isvalid,
  % tone, play and towav so every entry point accepts the same shapes.
  if (isstring(value) && ~isscalar(value)) || iscellstr(value)
    parts = cellstr(value);
    value = strjoin(parts(:)', ' ');
  elseif isstring(value) && isscalar(value)
    value = char(value);
  elseif ischar(value) && size(value, 1) > 1
    value = strjoin(cellstr(value)', ' ');
  end
  if ischar(value) && (isempty(value) || isrow(value))
    s = value;
    if isempty(s)
      s = '';
    end
    return
  end
  error('morse:invalidText', ...
    '%s must be text (a char row vector, a string, or a cellstr).', name);
end
%=============================================================================
