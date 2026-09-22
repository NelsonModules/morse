%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function [code, skipped] = encode(text, opts)
  % CODE = morse.encode(TEXT) turns TEXT into International Morse code. Letters
  % are separated by a single space and words by ' / ', so morse.encode('SOS')
  % is '... --- ...' and morse.encode('HELLO WORLD') is
  % '.... . .-.. .-.. --- / .-- --- .-. .-.. -..'.
  %
  % The mapping is the ITU-R M.1677-1 table (letters, digits and the standard
  % punctuation); it is case-insensitive. Characters that are not in the table
  % are handled according to 'OnUnknown'.
  %
  % Name-value options:
  %   'LetterSeparator' (default ' ')   text put between the letters of a word.
  %   'WordSeparator'   (default ' / ') text put between words.
  %   'Dot'             (default '.')   symbol used for a dit.
  %   'Dash'            (default '-')   symbol used for a dah.
  %   'OnUnknown'  'skip' (default) drops an unmappable character, 'error'
  %                raises morse:unknownCharacter, 'keep' copies it verbatim as
  %                its own token (for display only, not decodable).
  %
  % [CODE, SKIPPED] = morse.encode(...) also returns the unique characters that
  % were dropped or kept because they are not in the table.
  %
  % See also morse.decode, morse.table, morse.play.
  arguments
    text
    opts.LetterSeparator = ' '
    opts.WordSeparator = ' / '
    opts.Dot = '.'
    opts.Dash = '-'
    opts.OnUnknown {mustBeMember(opts.OnUnknown, {'skip', 'error', 'keep'})} = 'skip'
    opts.Prosigns (1,1) {mustBeNumericOrLogical} = true
  end
  text = morse_text_arg(text, 'TEXT');
  letterSep = char(opts.LetterSeparator);
  wordSep = char(opts.WordSeparator);

  book = morse_codebook();
  lut = containers.Map(book.chars, book.codes);

  s = upper(text);
  words = {};
  letters = {};
  skipped = {};
  n = numel(s);
  i = 1;
  while i <= n
    ch = s(i);
    if isspace(ch)
      % Any run of whitespace closes the current word (empty runs collapse).
      if ~isempty(letters)
        words{end + 1} = strjoin(letters, letterSep); %#ok<AGROW>
        letters = {};
      end
      i = i + 1;
      continue
    end
    if logical(opts.Prosigns) && ch == '<'
      close = i + find(s(i + 1:end) == '>', 1);
      if ~isempty(close)
        % A prosign: the bracketed letters are keyed as one run-together symbol.
        inner = s(i + 1:close - 1);
        group = '';
        for j = 1:numel(inner)
          [pat, sk] = local_symbol(lut, inner(j), opts);
          group = [group, pat]; %#ok<AGROW>
          if ~isempty(sk), skipped{end + 1} = sk; end %#ok<AGROW>
        end
        if ~isempty(group)
          letters{end + 1} = group; %#ok<AGROW>
        end
        i = close + 1;
        continue
      end
    end
    [pat, sk] = local_symbol(lut, ch, opts);
    if ~isempty(pat)
      letters{end + 1} = pat; %#ok<AGROW>
    elseif strcmp(opts.OnUnknown, 'keep')
      letters{end + 1} = ch; %#ok<AGROW>
    end
    if ~isempty(sk)
      skipped{end + 1} = sk; %#ok<AGROW>
    end
    i = i + 1;
  end
  if ~isempty(letters)
    words{end + 1} = strjoin(letters, letterSep);
  end
  code = strjoin(words, wordSep);

  if isempty(skipped)
    skipped = {};
  else
    skipped = unique(skipped);
  end
end
%=============================================================================
function [pat, sk] = local_symbol(lut, ch, opts)
  % The dot/dash pattern of a single character (with the custom Dot/Dash
  % applied), or '' when the character is not in the table; SK is the character
  % when it was not found, '' otherwise. Honors OnUnknown = 'error'.
  sk = '';
  if isKey(lut, ch)
    pat = strrep(lut(ch), '.', char(opts.Dot));
    pat = strrep(pat, '-', char(opts.Dash));
    return
  end
  pat = '';
  sk = ch;
  if strcmp(opts.OnUnknown, 'error')
    error('morse:unknownCharacter', ...
      'Character ''%s'' (code %d) is not in the Morse table.', ch, double(ch));
  end
end
%=============================================================================
