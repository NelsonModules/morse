%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
function varargout = practice()
  % morse.practice() opens the Morse trainer: a single window where you type a
  % message, see it turn into Morse in a radio-style readout, and send it to the
  % speaker. The code speed, the overall (Farnsworth) speed and the tone are
  % adjustable, the audio can be saved to a WAV file, and the full code table is
  % one click away.
  %
  % H = morse.practice() also returns the window handle.
  %
  % See also morse.play, morse.encode, morse.table.
  if exist('uifigure') == 0
    error('morse:noDisplay', ...
      'morse.practice needs a graphical display (run Nelson with the GUI, not the -cli).');
  end

  % --- palette (one calm system, defined once) -------------------------------
  ink = [0.11 0.12 0.15];      % primary text
  muted = [0.42 0.45 0.50];    % secondary text
  page = [0.97 0.97 0.98];     % window background
  card = [1.00 1.00 1.00];     % input surfaces
  accent = [0.85 0.44 0.09];   % primary action (signal amber)
  accentInk = [1 1 1];
  readoutBg = [0.12 0.13 0.16];% radio readout surface
  readoutFg = [0.98 0.80 0.42];

  W = 760; H = 680; L = 40; CW = W - 2 * L;

  fig = uifigure('Name', _('Morse Code Trainer'), 'Position', [120 100 W H], ...
    'Color', page);

  % --- header ----------------------------------------------------------------
  uilabel(fig, 'Text', _('Morse Code Trainer'), 'Position', [L H-58 CW 32], ...
    'FontSize', 20, 'FontWeight', 'bold', 'FontColor', ink);
  uilabel(fig, 'Text', _('Type a message, watch it become Morse, and send it.'), ...
    'Position', [L H-84 CW 20], 'FontSize', 12, 'FontColor', muted);

  % --- message input ---------------------------------------------------------
  uilabel(fig, 'Text', _('MESSAGE'), 'Position', [L H-120 CW 18], ...
    'FontSize', 10, 'FontWeight', 'bold', 'FontColor', muted);
  S.edit = uieditfield(fig, 'Value', 'SOS', 'Position', [L H-172 CW 40], ...
    'FontSize', 14, 'BackgroundColor', card, 'FontColor', ink, ...
    'Tooltip', _('The message to send.'));

  % --- morse readout ---------------------------------------------------------
  uilabel(fig, 'Text', _('MORSE'), 'Position', [L H-208 CW 18], ...
    'FontSize', 10, 'FontWeight', 'bold', 'FontColor', muted);
  S.readout = uilabel(fig, 'Text', '', 'Position', [L H-266 CW 50], ...
    'BackgroundColor', readoutBg, 'FontColor', readoutFg, ...
    'FontName', 'monospaced', 'FontSize', 15, 'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'center');

  % --- controls --------------------------------------------------------------
  cy = H - 336;
  uilabel(fig, 'Text', _('SPEED'), 'Position', [L cy+24 120 18], ...
    'FontSize', 10, 'FontWeight', 'bold', 'FontColor', muted);
  S.wpm = uislider(fig, 'Limits', [5 40], 'Value', 20, 'Position', [L cy 250 3], ...
    'MajorTicks', [5 40], 'MinorTicks', [], ...
    'Tooltip', _('Words per minute (element speed).'));
  S.wpmval = uilabel(fig, 'Text', '20 WPM', 'Position', [L+266 cy-10 80 22], ...
    'FontSize', 11, 'FontWeight', 'bold', 'FontColor', ink);

  uilabel(fig, 'Text', _('TONE'), 'Position', [L+420 cy+24 120 18], ...
    'FontSize', 10, 'FontWeight', 'bold', 'FontColor', muted);
  freqList = {'400 Hz', '500 Hz', '600 Hz', '700 Hz', '800 Hz', '900 Hz', '1000 Hz'};
  S.freq = uidropdown(fig, 'Items', freqList, 'Value', '700 Hz', ...
    'Position', [L+420 cy-8 140 24], 'BackgroundColor', card, ...
    'Tooltip', _('Pitch of the tone.'));

  py = cy - 56;
  uilabel(fig, 'Text', _('OVERALL'), 'Position', [L py+24 200 18], ...
    'FontSize', 10, 'FontWeight', 'bold', 'FontColor', muted);
  S.farns = uislider(fig, 'Limits', [5 40], 'Value', 20, 'Position', [L py 250 3], ...
    'MajorTicks', [5 40], 'MinorTicks', [], ...
    'Tooltip', _('Overall (Farnsworth) speed; at or below the code speed the spacing is stretched.'));
  S.farnsval = uilabel(fig, 'Text', '20 WPM', 'Position', [L+266 py-10 80 22], ...
    'FontSize', 11, 'FontWeight', 'bold', 'FontColor', ink);

  % --- actions ---------------------------------------------------------------
  by = H - 476;
  S.play = uibutton(fig, 'Text', _('Play'), 'Position', [L by 170 46], ...
    'BackgroundColor', accent, 'FontColor', accentInk, 'FontSize', 14, ...
    'FontWeight', 'bold', 'Tooltip', _('Send the message to the speaker.'));
  S.save = uibutton(fig, 'Text', _('Save WAV...'), 'Position', [L+186 by+6 150 34], ...
    'BackgroundColor', card, 'FontColor', ink, 'FontSize', 12, ...
    'Tooltip', _('Write the Morse audio to a WAV file.'));
  S.tableBtn = uibutton(fig, 'Text', _('Code table'), 'Position', [L+352 by+6 150 34], ...
    'BackgroundColor', card, 'FontColor', ink, 'FontSize', 12, ...
    'Tooltip', _('Show the International Morse code table.'));

  % --- status + tips ---------------------------------------------------------
  S.status = uilabel(fig, 'Text', _('Ready.'), 'Position', [L by-40 CW 22], ...
    'FontSize', 11, 'FontColor', accent);
  uilabel(fig, 'Text', ...
    _('Tip: letters are separated by a space and words by  /  .  Lower OVERALL below SPEED for Farnsworth spacing: crisp letters at a slower pace.'), ...
    'Position', [L 20 CW 40], 'FontSize', 10, 'FontColor', muted);

  % Wire callbacks now that every handle is captured in S.
  S.edit.ValueChangedFcn = @(o, e) morse_practice_action('update', S);
  S.wpm.ValueChangedFcn = @(o, e) morse_practice_action('update', S);
  S.farns.ValueChangedFcn = @(o, e) morse_practice_action('update', S);
  S.play.ButtonPushedFcn = @(o, e) morse_practice_action('play', S);
  S.save.ButtonPushedFcn = @(o, e) morse_practice_action('save', S);
  S.tableBtn.ButtonPushedFcn = @(o, e) morse_practice_action('table', S);

  % Prime the readout from the default message.
  morse_practice_action('update', S);

  if nargout > 0
    varargout{1} = fig;
  end
end
%=============================================================================
