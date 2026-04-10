import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// Custom text input field for the Reeder app.
///
/// Features:
/// - Placeholder text
/// - Clear button
/// - Focus border highlight
/// - Custom styling without Material dependencies
class ReederTextField extends StatefulWidget {
  /// Text editing controller.
  final TextEditingController? controller;

  /// Placeholder text when empty.
  final String? placeholder;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g., presses Enter).
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to auto-focus when the widget is first built.
  final bool autofocus;

  /// Whether to show a clear button when text is present.
  final bool showClearButton;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Text input action (e.g., done, search, next).
  final TextInputAction? textInputAction;

  /// Maximum number of lines.
  final int maxLines;

  /// Focus node.
  final FocusNode? focusNode;

  /// Prefix widget (e.g., search icon).
  final Widget? prefix;

  const ReederTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.showClearButton = true,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.focusNode,
    this.prefix,
  });

  @override
  State<ReederTextField> createState() => _ReederTextFieldState();
}

class _ReederTextFieldState extends State<ReederTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: _isFocused
            ? Border.all(color: theme.accentColor, width: 1.5)
            : Border.all(color: theme.separatorColor, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          // Prefix
          if (widget.prefix != null) ...[
            IconTheme(
              data: IconThemeData(
                color: theme.secondaryTextColor,
                size: AppDimensions.icon,
              ),
              child: widget.prefix!,
            ),
            const SizedBox(width: AppDimensions.spacingS),
          ],

          // Text input
          Expanded(
            child: EditableText(
              controller: _controller,
              focusNode: _focusNode,
              style: theme.typography.body,
              cursorColor: theme.accentColor,
              backgroundCursorColor: theme.tertiaryTextColor,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),

          // Clear button
          if (widget.showClearButton && _hasText)
            GestureDetector(
              onTap: _clearText,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimensions.spacingS),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.tertiaryTextColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '×',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.backgroundColor,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
