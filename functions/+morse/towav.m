%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function varargout = towav(filename, varargin)
  % morse.towav(FILENAME, INPUT) synthesizes the Morse audio for INPUT (plain
  % text or a code string) and writes it to the WAV file FILENAME, so it can be
  % shared or played later without Nelson.
  %
  % morse.towav(FILENAME, INPUT, 'WPM', 18, ...) accepts every option of
  % morse.tone; see the help of morse.tone for their meaning and defaults.
  %
  % [Y, FS] = morse.towav(...) also returns the samples and sample rate written.
  %
  % See also morse.tone, morse.play.
  filename = morse_text_arg(filename, 'FILENAME');
  if isempty(filename)
    error('morse:invalidFilename', 'FILENAME must not be empty.');
  end
  [y, fs] = morse.tone(varargin{:});
  if isempty(y)
    error('morse:emptyAudio', 'Nothing to write: the input produced no audio.');
  end
  audiowrite(filename, y, fs);
  if nargout > 0
    varargout{1} = y;
  end
  if nargout > 1
    varargout{2} = fs;
  end
end
%=============================================================================
