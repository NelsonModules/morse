%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function morse_practice_action(action, S)
  % The single callback behind every control of morse.practice. S holds the
  % uifigure components; ACTION selects what to do. Kept in one place so the
  % trainer's behavior reads top to bottom.
  switch action
    case 'update'
      [wpm, farns] = morse_practice_speeds(S);
      txt = morse_practice_text(S.edit);
      if isempty(txt)
        S.readout.Text = '';
      else
        S.readout.Text = morse_practice_readout(morse.encode(txt));
      end

    case 'play'
      txt = morse_practice_text(S.edit);
      if isempty(txt)
        S.status.Text = _('Type a message first.');
        return
      end
      code = morse.encode(txt);
      S.readout.Text = morse_practice_readout(code);
      [wpm, farns] = morse_practice_speeds(S);
      freq = morse_practice_freq(S.freq);
      args = morse_practice_audio_args(wpm, farns, freq);
      S.status.Text = _('Playing...');
      drawnow();
      [y, fs] = morse.tone(code, 'Input', 'code', args{:});
      if ~isempty(y)
        player = audioplayer(y, fs);
        playblocking(player);
      end
      S.status.Text = sprintf(_('Sent %d characters at %d WPM, %d Hz.'), numel(txt), wpm, freq);

    case 'save'
      txt = morse_practice_text(S.edit);
      if isempty(txt)
        S.status.Text = _('Type a message first.');
        return
      end
      [fn, pth] = uiputfile({'*.wav', 'WAV audio (*.wav)'}, _('Save Morse audio'), 'morse.wav');
      if isequal(fn, 0) || isequal(pth, 0)
        return
      end
      [wpm, farns] = morse_practice_speeds(S);
      freq = morse_practice_freq(S.freq);
      args = morse_practice_audio_args(wpm, farns, freq);
      target = fullfile(pth, fn);
      morse.towav(target, morse.encode(txt), 'Input', 'code', args{:});
      S.status.Text = [_('Saved to '), target];

    case 'table'
      morse_practice_table_window();
  end
end
%=============================================================================
function [wpm, farns] = morse_practice_speeds(S)
  % Read the code speed and the overall (Farnsworth) speed, snapping both
  % sliders to whole words per minute and holding the overall speed at or below
  % the code speed, then refresh their value labels.
  wpm = round(S.wpm.Value);
  farns = round(S.farns.Value);
  if farns > wpm
    farns = wpm;
  end
  S.wpm.Value = wpm;
  S.farns.Value = farns;
  S.wpmval.Text = [num2str(wpm), ' WPM'];
  S.farnsval.Text = [num2str(farns), ' WPM'];
end
%=============================================================================
function args = morse_practice_audio_args(wpm, farns, freq)
  % The name-value options for morse.tone / morse.towav: the code speed and
  % frequency, plus Farnsworth only when the overall speed is actually slower.
  args = {'WPM', wpm, 'Frequency', freq};
  if farns < wpm
    args = [args, {'Farnsworth', farns}];
  end
end
%=============================================================================
function txt = morse_practice_text(hEdit)
  % Read the message field as one trimmed line.
  txt = strtrim(char(hEdit.Value));
end
%=============================================================================
function freq = morse_practice_freq(hDrop)
  % The selected tone frequency (the drop-down value is a text such as '700 Hz').
  freq = sscanf(hDrop.Value, '%d');
end
%=============================================================================
function s = morse_practice_readout(code)
  % Lay the Morse code out for the readout: one word per line so a long message
  % stays readable. A multi-word code becomes a cellstr (the form the label
  % renders as separate lines); a single word stays a char row.
  parts = strsplit(code, ' / ');
  if numel(parts) <= 1
    s = code;
  else
    s = parts;
  end
end
%=============================================================================
