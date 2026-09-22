%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function varargout = table()
  % morse.table() prints the International Morse code table, grouped into
  % letters, digits and punctuation.
  %
  % T = morse.table() instead returns the table as an N-by-2 cell array whose
  % first column holds each character and second column its dot/dash code, for
  % example T{1, :} is {'A', '.-'}.
  %
  % See also morse.encode, morse.decode.
  book = morse_codebook();
  if nargout > 0
    varargout{1} = [book.chars(:), book.codes(:)];
    return
  end
  morse_print_table(book);
end
%=============================================================================
