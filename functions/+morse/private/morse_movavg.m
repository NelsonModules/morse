%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function m = morse_movavg(x, w)
  % Trailing moving average of the column vector X over a window of W samples,
  % computed in O(n) from a prefix sum (no toolbox dependency). Returns a vector
  % of length numel(X)-W+1; the constant W/2 delay it introduces cancels out
  % when the result is only used for on/off run lengths.
  x = x(:);
  n = numel(x);
  if w <= 1 || n == 0
    m = x;
    return
  end
  if w > n
    w = n;
  end
  cs = [0; cumsum(x)];
  m = (cs(w + 1:end) - cs(1:end - w)) / w;
end
%=============================================================================
