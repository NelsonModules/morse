%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function [text, unknown] = decode(code, opts)
  % TEXT = morse.decode(CODE) turns International Morse CODE back into text.
  % Within a word the dot/dash groups are separated by spaces; words are
  % separated by '/' (the ' / ' produced by morse.encode) or, when no '/' is
  % present, by a run of two or more spaces. morse.decode('... --- ...') is
  % 'SOS'.
  %
  % The result is upper case, the form Morse preserves. It round-trips
  % morse.encode for any text made only of characters in the table:
  % morse.decode(morse.encode('HELLO WORLD')) is 'HELLO WORLD'.
  %
  % Name-value options:
  %   'Dot'  (default '.') and 'Dash' (default '-') the symbols used in CODE.
  %   'OnUnknown'  'mark' (default) replaces an unrecognized group with the
  %                'Placeholder' text, 'error' raises morse:unknownCode.
  %   'Placeholder' (default '?') text put in place of an unrecognized group.
  %
  % [TEXT, UNKNOWN] = morse.decode(...) also returns the unique dot/dash groups
  % that did not match any character.
  %
  % See also morse.encode, morse.isvalid, morse.table.
  arguments
    code
    opts.Dot = '.'
    opts.Dash = '-'
    opts.OnUnknown {mustBeMember(opts.OnUnknown, {'mark', 'error'})} = 'mark'
    opts.Placeholder = '?'
  end
  code = morse_text_arg(code, 'CODE');
  placeholder = char(opts.Placeholder);

  book = morse_codebook();
  lut = containers.Map(book.codes, book.chars);

  % Bring custom symbols back to the canonical dot and dash.
  if ~strcmp(char(opts.Dot), '.')
    code = strrep(code, char(opts.Dot), '.');
  end
  if ~strcmp(char(opts.Dash), '-')
    code = strrep(code, char(opts.Dash), '-');
  end

  % Normalize word boundaries: an explicit '/' wins; otherwise a run of two or
  % more spaces marks a word gap. Either way a single space marks a letter gap.
  if any(code == '/')
    code = strrep(code, '/', ' / ');
  else
    code = regexprep(code, ' {2,}', ' / ');
  end

  tokens = strsplit(strtrim(code), ' ');
  letters = {};
  unknown = {};
  for k = 1:numel(tokens)
    tok = tokens{k};
    if isempty(tok)
      continue
    end
    if strcmp(tok, '/')
      letters{end + 1} = ' '; %#ok<AGROW>
      continue
    end
    if isKey(lut, tok)
      letters{end + 1} = lut(tok); %#ok<AGROW>
    else
      unknown{end + 1} = tok; %#ok<AGROW>
      if strcmp(opts.OnUnknown, 'error')
        error('morse:unknownCode', ...
          'Group ''%s'' does not match any character in the Morse table.', tok);
      end
      letters{end + 1} = placeholder; %#ok<AGROW>
    end
  end
  text = strjoin(letters, '');
  % Collapse the spaces that stood for word gaps into a single blank and trim.
  text = strtrim(regexprep(text, ' +', ' '));

  if isempty(unknown)
    unknown = {};
  else
    unknown = unique(unknown);
  end
end
%=============================================================================
