import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../chat_l10n.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'text_message.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages, delivery time and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.dateLocale,
    required this.message,
    required this.messageWidth,
    this.onFilePressed,
    required this.onImagePressed,
    this.onPreviewDataFetched,
    required this.previousMessageSameAuthor,
    required this.nextMessageSameAuthor,
    required this.shouldRenderTime,
    required this.showName,
    required this.l10n,
  }) : super(key: key);

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown.
  final String? dateLocale;

  /// Any message type
  final types.Message message;

  /// Maximum message width
  final int messageWidth;

  /// See [FileMessage.onPressed]. Used it to open file preview.
  final void Function(types.FileMessage)? onFilePressed;

  /// See [ImageMessage.onPressed]. Will open image preview.
  final void Function(String) onImagePressed;

  /// See [TextMessage.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Whether previous message was sent by the same person. Used for
  /// different spacing for sent and received messages.
  final bool previousMessageSameAuthor;
  final bool nextMessageSameAuthor;

  /// Whether delivery time should be rendered. It is not rendered for
  /// received messages and when sent messages have small difference in
  /// delivery time.
  final bool shouldRenderTime;

  /// Show author name
  final bool showName;

  final ChatL10n l10n;

  Widget _buildMessage() {
    switch (message.type) {
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return FileMessage(
          message: fileMessage,
          onPressed: onFilePressed,
        );
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return ImageMessage(
          message: imageMessage,
          messageWidth: messageWidth,
          onPressed: onImagePressed,
        );

      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return TextMessage(
          message: textMessage,
          onPreviewDataFetched: onPreviewDataFetched,
        );
      default:
        return Container();
    }
  }

  Widget _buildStatus(BuildContext context) {
    switch (message.status) {
      case types.Status.delivered:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.deliveredIcon!,
                color: InheritedChatTheme.of(context).theme.primaryColor,
              )
            : Image.asset(
                'assets/icon-delivered.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.read:
        return InheritedChatTheme.of(context).theme.readIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.readIcon!,
                color: InheritedChatTheme.of(context).theme.primaryColor,
              )
            : Image.asset(
                'assets/icon-read.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.sending:
        return SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(
            backgroundColor: Colors.transparent,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              InheritedChatTheme.of(context).theme.primaryColor,
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildTime(
      bool currentUserIsAuthor, BuildContext context, types.User author) {
    final _user = InheritedUser.of(context).user;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: Text(
            "${author.name} - " +
                DateFormat.jm(dateLocale).format(
                  DateTime.fromMillisecondsSinceEpoch(
                    message.timestamp! * 1000,
                  ),
                ),
            style: InheritedChatTheme.of(context).theme.caption.copyWith(
                  color: InheritedChatTheme.of(context).theme.captionColor,
                ),
          ),
        ),
        if (currentUserIsAuthor) _buildStatus(context)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final _borderRadius = BorderRadius.circular(_messageBorderRadius);
    final _currentUserIsAuthor = _user.id == message.author.id;

    return Container(
      alignment: _user.id == message.author.id
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: EdgeInsets.only(
        bottom: previousMessageSameAuthor ? 8 : 16,
        left: 12,
        right: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: messageWidth.toDouble(),
        ),
        child: Column(
          crossAxisAlignment: _user.id == message.author.id
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Card(
              elevation: .6,
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: _borderRadius,
              ),
              color: !_currentUserIsAuthor
                  ? InheritedChatTheme.of(context).theme.secondaryColor
                  : InheritedChatTheme.of(context).theme.primaryColor,
              child: ClipRRect(
                borderRadius: _borderRadius,
                child: _buildMessage(),
              ),
            ),
            Visibility(
              visible: shouldRenderTime,
              child: Container(
                margin: EdgeInsets.only(top: 6),
                child:
                    _buildTime(_currentUserIsAuthor, context, message.author),
              ),
            )
          ],
        ),
      ),
    );
  }
}
