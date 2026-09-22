%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function varargout = prosigns()
  % morse.prosigns() prints the common Morse procedural signals (prosigns):
  % letters run together and sent as one symbol. In text they are written
  % between angle brackets, and morse.encode turns '<AR>' into the run-together
  % code '.-.-.'.
  %
  % P = morse.prosigns() instead returns an N-by-3 cell array with the prosign
  % name, its bracketed text form and its dot/dash code.
  %
  % See also morse.encode, morse.table.
  names = {'AR', 'AS', 'BT', 'CT', 'KN', 'SK', 'SN', 'SOS'};
  meaning = { ...
    _('end of message'), _('wait'), _('break / new section (=)'), _('start of message'), ...
    _('invitation to a named station'), _('end of contact'), _('understood'), _('distress')};
  p = cell(numel(names), 3);
  for k = 1:numel(names)
    p{k, 1} = names{k};
    p{k, 2} = ['<', names{k}, '>'];
    p{k, 3} = morse.encode(['<', names{k}, '>']);
  end
  if nargout > 0
    varargout{1} = p;
    return
  end
  disp(_('Common Morse prosigns (letters sent run together)'));
  disp(repmat('-', 1, 49));
  for k = 1:size(p, 1)
    fprintf('  %-6s %-11s %-11s %s\n', p{k, 1}, p{k, 2}, p{k, 3}, meaning{k});
  end
end
%=============================================================================
