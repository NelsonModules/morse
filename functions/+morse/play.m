%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function varargout = play(varargin)
  % morse.play(INPUT) synthesizes the Morse audio for INPUT (plain text such as
  % 'SOS' or a code string such as '... --- ...') and plays it on the default
  % audio output, returning when the sound has finished.
  %
  % morse.play(INPUT, 'WPM', 25, 'Frequency', 600, ...) accepts every option of
  % morse.tone (WPM, Farnsworth, Frequency, SampleRate, Amplitude, RampMs,
  % Input); see the help of morse.tone for their meaning and defaults.
  %
  % morse.play(INPUT, 'Block', false) starts the audio and returns immediately
  % instead of waiting for it to finish; the default 'Block', true returns when
  % the sound has finished.
  %
  % [Y, FS] = morse.play(...) also returns the samples and sample rate that
  % were played; [Y, FS, PLAYER] = morse.play(...) also returns the audioplayer
  % (useful to stop a non-blocking playback with stop(PLAYER)).
  %
  % See also morse.tone, morse.towav, morse.encode.
  [block, args] = local_take_block(varargin);
  [y, fs] = morse.tone(args{:});
  player = [];
  if ~isempty(y)
    player = audioplayer(y, fs);
    if block
      playblocking(player);
    else
      play(player);
    end
  end
  if nargout > 0
    varargout{1} = y;
  end
  if nargout > 1
    varargout{2} = fs;
  end
  if nargout > 2
    varargout{3} = player;
  end
end
%=============================================================================
function [block, args] = local_take_block(args)
  % Pull an optional 'Block' name-value pair out of the argument list (leaving
  % the rest for morse.tone) and return its logical value (default true).
  block = true;
  k = 2;                       % args{1} is the positional INPUT
  while k < numel(args)
    name = args{k};
    if (ischar(name) || (isstring(name) && isscalar(name))) && strcmpi(char(name), 'Block')
      block = logical(args{k + 1});
      args(k:k + 1) = [];
      continue
    end
    k = k + 1;
  end
end
%=============================================================================
