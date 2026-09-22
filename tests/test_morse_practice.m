%=============================================================================
% Copyright (c) 2026-present Allan CORNET (Nelson)
%=============================================================================
% This file is part of the morse module for Nelson.
%=============================================================================
% LICENCE_BLOCK_BEGIN
% SPDX-License-Identifier: LGPL-3.0-or-later
% LICENCE_BLOCK_END
%=============================================================================
% <--ADV-CLI MODE-->
% <--GUI MODE-->
%=============================================================================
h = morse.practice();
drawnow();
assert_isequal(h.Type, 'figure');
children = h.Children;
% The message field is an editable uieditfield primed with the default 'SOS'.
messageValue = '';
editable = '';
% The Morse readout is the monospaced label, primed from the default message.
readout = '';
for k = 1:numel(children)
  c = children(k);
  if strcmp(c.Type, 'uieditfield')
    messageValue = c.Value;
    editable = c.Editable;
  end
  if strcmp(c.Type, 'uilabel') && strcmp(c.FontName, 'monospaced')
    readout = c.Text;
  end
end
assert_isequal(messageValue, 'SOS');
assert_isequal(editable, 'on');
assert_isequal(readout, '... --- ...');
close(h);
%=============================================================================
