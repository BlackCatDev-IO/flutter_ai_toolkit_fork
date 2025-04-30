// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../styles/action_button_style.dart';
import '../../styles/action_button_type.dart';
import '../../styles/llm_chat_view_style.dart';
import '../action_button.dart';
import 'input_state.dart';

/// A button widget that adapts its appearance and behavior based on the current
/// input state.
@immutable
class InputButton extends StatelessWidget {
  /// Creates an [InputButton].
  ///
  /// All parameters are required:
  /// - [inputState]: The current state of the input.
  /// - [chatStyle]: The style configuration for the chat interface.
  /// - [onSubmitPrompt]: Callback function when submitting a prompt.
  /// - [onCancelPrompt]: Callback function when cancelling a prompt.
  /// - [onStartRecording]: Callback function when starting audio recording.
  /// - [onStopRecording]: Callback function when stopping audio recording.
  const InputButton({
    required this.inputState,
    required this.chatStyle,
    required this.onSubmitPrompt,
    required this.onCancelPrompt,
    required this.onStartRecording,
    required this.onStopRecording,
    super.key,
  });

  /// The current state of the input.
  final InputState inputState;

  /// The style configuration for the chat interface.
  final LlmChatViewStyle chatStyle;

  /// Callback function when submitting a prompt.
  final void Function() onSubmitPrompt;

  /// Callback function when cancelling a prompt.
  final void Function() onCancelPrompt;

  /// Callback function when starting audio recording.
  final void Function() onStartRecording;

  /// Callback function when stopping audio recording.
  final void Function() onStopRecording;

  ActionButtonType? _getButtonTypeForState(InputState state) {
    return switch (state) {
      InputState.canSubmitPrompt => ActionButtonType.submit,
      InputState.canCancelPrompt => ActionButtonType.stop,
      InputState.canStt => ActionButtonType.record,
      InputState.isRecording => ActionButtonType.stop,
      InputState.canCancelStt => null,
      InputState.disabled => ActionButtonType.disabled,
    };
  }

  VoidCallback _getCallbackForState(InputState state) {
    return switch (state) {
      InputState.canSubmitPrompt => onSubmitPrompt,
      InputState.canCancelPrompt => onCancelPrompt,
      InputState.canStt => onStartRecording,
      InputState.isRecording => onStopRecording,
      InputState.canCancelStt => () {}, // Progress indicator has no callback
      InputState.disabled => () {}, // Disabled state has no callback
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = switch (inputState) {
      InputState.canSubmitPrompt => chatStyle.submitButtonStyle!,
      InputState.canCancelPrompt => chatStyle.stopButtonStyle!,
      InputState.canStt => chatStyle.recordButtonStyle!,
      InputState.isRecording => chatStyle.stopButtonStyle!,
      InputState.canCancelStt => null, // This state uses a progress indicator
      InputState.disabled => chatStyle.disabledButtonStyle!,
    };

    // Speech to text loading
    if (style == null) {
      return CircularProgressIndicator(
        color: chatStyle.progressIndicatorColor!,
      );
    }

    final buttonType = _getButtonTypeForState(inputState);
    final callback = _getCallbackForState(inputState);

    // If we have a valid button type and a custom icon is provided for this button type in the customIcons map, use it
    if (buttonType != null && style.customIcons.containsKey(buttonType)) {
      final customStyle = ActionButtonStyle(
        iconColor: style.iconColor,
        iconDecoration: style.iconDecoration,
        text: style.text,
        textStyle: style.textStyle,
        customIcons: {buttonType: style.customIcons[buttonType]!},
      );

      return ActionButton(style: customStyle, onPressed: callback);
    }

    // Fall back to the standard ActionButton with default icon
    return ActionButton(style: style, onPressed: callback);
  }
}
