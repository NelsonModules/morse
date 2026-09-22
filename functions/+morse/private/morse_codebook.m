%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function book = morse_codebook()
  % The International Morse code table (ITU-R M.1677-1): letters, digits and
  % the standard punctuation. Returned once as a struct so encode, decode,
  % table and isvalid all read the same single source of truth.
  %
  %   book.chars : 1xN cellstr, one upper-case character per entry.
  %   book.codes : 1xN cellstr, the matching dot/dash pattern.
  persistent CACHE
  if ~isempty(CACHE)
    book = CACHE;
    return
  end
  map = {
    'A', '.-';      'B', '-...';    'C', '-.-.';    'D', '-..';
    'E', '.';       'F', '..-.';    'G', '--.';     'H', '....';
    'I', '..';      'J', '.---';    'K', '-.-';     'L', '.-..';
    'M', '--';      'N', '-.';      'O', '---';     'P', '.--.';
    'Q', '--.-';    'R', '.-.';     'S', '...';     'T', '-';
    'U', '..-';     'V', '...-';    'W', '.--';     'X', '-..-';
    'Y', '-.--';    'Z', '--..';
    '0', '-----';   '1', '.----';   '2', '..---';   '3', '...--';
    '4', '....-';   '5', '.....';   '6', '-....';   '7', '--...';
    '8', '---..';   '9', '----.';
    '.', '.-.-.-';  ',', '--..--';  '?', '..--..';  '''', '.----.';
    '!', '-.-.--';  '/', '-..-.';   '(', '-.--.';   ')', '-.--.-';
    '&', '.-...';   ':', '---...';  ';', '-.-.-.';  '=', '-...-';
    '+', '.-.-.';   '-', '-....-';  '_', '..--.-';  '"', '.-..-.';
    '$', '...-..-'; '@', '.--.-.'
  };
  % Accented letters from the ITU extension. Kept as code points (char(cp)) so
  % this source file stays ASCII; each has a code that no other entry uses, so
  % the decode table stays unambiguous. upper() maps a lower-case accent to its
  % upper-case form, so encode matches them without a separate lower-case list.
  accents = {
    192, '.--.-';    % A grave
    196, '.-.-';     % A diaeresis
    199, '-.-..';    % C cedilla
    200, '.-..-';    % E grave
    201, '..-..';    % E acute
    209, '--.--';    % N tilde
    214, '---.';     % O diaeresis
    220, '..--'      % U diaeresis
  };
  chars = map(:, 1)';
  codes = map(:, 2)';
  for k = 1:size(accents, 1)
    chars{end + 1} = char(accents{k, 1});
    codes{end + 1} = accents{k, 2};
  end
  book = struct();
  book.chars = chars;
  book.codes = codes;
  CACHE = book;
end
%=============================================================================
