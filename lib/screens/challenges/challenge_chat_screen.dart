/// Challenge Chat Screen for real-time communication between challenge participants.
/// 
/// This screen provides comprehensive messaging functionality including text messages,
/// image sharing, achievement celebrations, and system notifications. Features include
/// message reactions, user mentions, typing indicators, and smooth real-time updates
/// with proper keyboard handling and message pagination.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';
import '../../models/chat_message.dart';
import '../../models/user_model_clean.dart';

/// Quick response options for motivation and engagement
enum QuickResponse {
  letsgGo('Let\'s go! 🔥'),
  goodJob('Good job! 👏'),
  keepPushing('Keep pushing! 💪'),
  awesome('Awesome! 🎉'),
  motivated('You got this! 💯');

  const QuickResponse(this.text);
  final String text;
}

/// Challenge Chat Screen with comprehensive messaging features
class ChallengeChatScreen extends StatefulWidget {
  /// The challenge for which to display the chat
  final Challenge challenge;

  /// Creates a new ChallengeChatScreen
  /// 
  /// @param challenge The challenge object containing participant data
  const ChallengeChatScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<ChallengeChatScreen> createState() => _ChallengeChatScreenState();
}

class _ChallengeChatScreenState extends State<ChallengeChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _showQuickResponses = false;
  bool _isTyping = false;
  String _typingUsers = '';
  ChatMessage? _replyingToMessage;
  
  // Mock current user data - in real app this would come from auth service
  final String _currentUserId = '123';
  final String _currentUserName = 'John Doe';
  final String _currentUsername = 'johndoe';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMessages();
    _setupKeyboardListener();
    _setupScrollListener();
    
    // Initialize mock data
    ChatService.addMockData(widget.challenge.id);
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _fadeController.forward();
  }

  void _setupKeyboardListener() {
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        // Delay scroll to allow keyboard to appear
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Load more messages when scrolling to top (pagination)
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Loads initial messages from the chat service
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final messages = ChatService.getMessages(widget.challenge.id);
      setState(() {
        _messages = messages;
      });
      
      // Auto-scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load messages: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Loads more messages for pagination (mock implementation)
  Future<void> _loadMoreMessages() async {
    // In real app, this would load earlier messages from the server
    // For now, just show a brief loading indicator
    HapticFeedback.lightImpact();
  }

  /// Scrolls to bottom of message list
  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  /// Sends a message to the chat
  Future<void> _sendMessage({String? customContent, MessageType? messageType}) async {
    final content = customContent ?? _messageController.text.trim();
    if (content.isEmpty && messageType == MessageType.text) return;

    setState(() {
      _isSending = true;
    });

    try {
      final message = ChatService.sendMessage(
        challengeId: widget.challenge.id,
        senderId: _currentUserId,
        senderName: _currentUserName,
        senderUsername: _currentUsername,
        content: content,
        type: messageType ?? MessageType.text,
        replyToMessageId: _replyingToMessage?.id,
      );

      setState(() {
        _messages.add(message);
        _messageController.clear();
        _replyingToMessage = null;
        _showQuickResponses = false;
      });

      // Provide haptic feedback
      HapticFeedback.lightImpact();
      
      // Auto-scroll to bottom
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Failed to send message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Handles reaction to a message
  void _handleReaction(ChatMessage message, ReactionType reactionType) {
    final currentReaction = message.reactions[_currentUserId];
    
    if (currentReaction == reactionType) {
      // Remove reaction if same type
      ChatService.removeReaction(message.id, _currentUserId);
    } else {
      // Add or change reaction
      ChatService.addReaction(message.id, _currentUserId, reactionType);
    }

    // Refresh messages
    setState(() {
      _messages = ChatService.getMessages(widget.challenge.id);
    });
    
    HapticFeedback.selectionClick();
  }

  /// Handles replying to a message
  void _handleReply(ChatMessage message) {
    setState(() {
      _replyingToMessage = message;
    });
    _messageFocusNode.requestFocus();
  }

  /// Cancels the current reply
  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
    });
  }

  /// Shares workout completion to chat
  void _shareWorkoutCompletion() {
    _sendMessage(
      customContent: 'Just completed an awesome workout! 💪',
      messageType: MessageType.workout,
    );
  }

  /// Celebrates an achievement in chat
  void _shareAchievement() {
    _sendMessage(
      customContent: 'New personal record achieved! 🏆',
      messageType: MessageType.achievement,
    );
  }

  /// Shows error message via SnackBar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Shows chat options menu
  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildChatOptionsMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildMessagesList(),
              ),
              if (_replyingToMessage != null) _buildReplyBar(),
              _buildInputSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with challenge info and options
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Challenge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.challenge.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.challenge.participantIds.length} participants',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.challenge.statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.challenge.statusColor,
                width: 1,
              ),
            ),
            child: Text(
              widget.challenge.status.name.toUpperCase(),
              style: TextStyle(
                color: widget.challenge.statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Options menu
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.textPrimary,
            onPressed: _showChatOptions,
          ),
        ],
      ),
    );
  }

  /// Builds the main messages list with loading and empty states
  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentYellow,
        ),
      );
    }

    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // Show newest messages at bottom
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          // Show typing indicator at top
          if (_isTyping && index == 0) {
            return _buildTypingIndicator();
          }
          
          final messageIndex = _isTyping ? index - 1 : index;
          final message = _messages[_messages.length - 1 - messageIndex];
          final isCurrentUser = message.senderId == _currentUserId;
          final showTimestamp = _shouldShowTimestamp(messageIndex);
          
          return Column(
            children: [
              if (showTimestamp) _buildTimestampDivider(message.timestamp),
              _buildMessageBubble(message, isCurrentUser),
            ],
          );
        },
      ),
    );
  }

  /// Builds empty state when no messages exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say something!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          // Quick start options
          Wrap(
            spacing: 8,
            children: [
              _buildQuickResponseChip('Hello everyone! 👋'),
              _buildQuickResponseChip('Let\'s do this! 💪'),
              _buildQuickResponseChip('Good luck! 🍀'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual message bubble
  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            _buildUserAvatar(message),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser) _buildSenderName(message),
                  _buildMessageContent(message, isCurrentUser),
                  if (message.hasReactions) _buildReactions(message),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(message),
          ],
        ],
      ),
    );
  }

  /// Builds user avatar for messages
  Widget _buildUserAvatar(ChatMessage message) {
    return GestureDetector(
      onTap: () => _viewUserProfile(message.senderId),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: _getUserAvatarColor(message.senderId),
        backgroundImage: message.senderAvatarUrl != null
            ? NetworkImage(message.senderAvatarUrl!)
            : null,
        child: message.senderAvatarUrl == null
            ? Text(
                message.senderName.isNotEmpty 
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : null,
      ),
    );
  }

  /// Builds sender name for non-current user messages
  Widget _buildSenderName(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        message.senderName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds the main message content bubble
  Widget _buildMessageContent(ChatMessage message, bool isCurrentUser) {
    Color bubbleColor;
    Color textColor;
    
    if (message.type == MessageType.system) {
      bubbleColor = AppTheme.textSecondary.withOpacity(0.2);
      textColor = AppTheme.textSecondary;
    } else if (isCurrentUser) {
      bubbleColor = AppTheme.accentYellow;
      textColor = Colors.black;
    } else {
      bubbleColor = AppTheme.surfaceColor;
      textColor = AppTheme.textPrimary;
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
            bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isReply) _buildReplyContext(message),
            _buildMessageText(message, textColor),
            const SizedBox(height: 4),
            _buildMessageFooter(message, isCurrentUser),
          ],
        ),
      ),
    );
  }

  /// Builds reply context for reply messages
  Widget _buildReplyContext(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppTheme.accentYellow,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSenderName ?? 'Unknown',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentYellow,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToContent ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds message text with special formatting for different types
  Widget _buildMessageText(ChatMessage message, Color textColor) {
    Widget content;
    
    switch (message.type) {
      case MessageType.achievement:
        content = Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
        break;
      case MessageType.workout:
        content = Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
        break;
      case MessageType.system:
        content = Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
        break;
      default:
        content = Text(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        );
    }

    return content;
  }

  /// Builds message footer with timestamp and status
  Widget _buildMessageFooter(ChatMessage message, bool isCurrentUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.formattedTime,
          style: TextStyle(
            color: isCurrentUser 
                ? Colors.black54 
                : AppTheme.textSecondary.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        if (isCurrentUser) ...[
          const SizedBox(width: 4),
          Icon(
            message.isRead ? Icons.done_all : Icons.done,
            size: 12,
            color: message.isRead ? Colors.blue : Colors.grey,
          ),
        ],
      ],
    );
  }

  /// Builds reactions display for messages
  Widget _buildReactions(ChatMessage message) {
    if (!message.hasReactions) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: ReactionType.values.map((reactionType) {
          final users = message.reactions.entries
              .where((entry) => entry.value == reactionType)
              .map((entry) => entry.key)
              .toList();
          
          if (users.isEmpty) return const SizedBox.shrink();
          
          final hasCurrentUser = users.contains(_currentUserId);
          
          return GestureDetector(
            onTap: () => _handleReaction(message, reactionType),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasCurrentUser 
                    ? AppTheme.accentYellow.withOpacity(0.2)
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasCurrentUser 
                      ? AppTheme.accentYellow
                      : AppTheme.borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ChatMessage.getReactionEmoji(reactionType),
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (users.length > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      users.length.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: hasCurrentUser 
                            ? AppTheme.accentYellow
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds typing indicator
  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _buildUserAvatar(ChatMessage(
            id: 'typing',
            content: '',
            senderId: 'other',
            senderName: 'Someone',
            senderUsername: 'someone',
            timestamp: DateTime.now(),
            type: MessageType.text,
          )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'typing',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        curve: Curves.easeInOut,
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds timestamp dividers
  Widget _buildTimestampDivider(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppTheme.borderColor.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatTimestampDivider(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppTheme.borderColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds reply bar when replying to a message
  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
          left: BorderSide(
            color: AppTheme.accentYellow,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: AppTheme.accentYellow,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingToMessage!.senderName}',
                  style: TextStyle(
                    color: AppTheme.accentYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _replyingToMessage!.content,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: AppTheme.textSecondary,
            iconSize: 16,
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  /// Builds input section with text field and send button
  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_showQuickResponses) _buildQuickResponses(),
            Row(
              children: [
                // Attachment button (placeholder)
                IconButton(
                  icon: const Icon(Icons.add),
                  color: AppTheme.textSecondary,
                  onPressed: _showAttachmentOptions,
                ),
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) {
                      setState(() {
                        // Update quick responses visibility
                        _showQuickResponses = text.isEmpty;
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Quick responses toggle
                IconButton(
                  icon: Icon(
                    _showQuickResponses ? Icons.keyboard : Icons.emoji_emotions_outlined,
                  ),
                  color: AppTheme.textSecondary,
                  onPressed: () {
                    setState(() {
                      _showQuickResponses = !_showQuickResponses;
                    });
                  },
                ),
                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.accentYellow,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: _messageController.text.trim().isNotEmpty
                              ? AppTheme.accentYellow
                              : AppTheme.textSecondary,
                          onPressed: _messageController.text.trim().isNotEmpty
                              ? () => _sendMessage()
                              : null,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds quick response options
  Widget _buildQuickResponses() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: QuickResponse.values.length,
        itemBuilder: (context, index) {
          final response = QuickResponse.values[index];
          return _buildQuickResponseChip(response.text);
        },
      ),
    );
  }

  /// Builds individual quick response chip
  Widget _buildQuickResponseChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _sendMessage(customContent: text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentYellow.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.accentYellow,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds chat options menu
  Widget _buildChatOptionsMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Options
          _buildChatOption(
            icon: Icons.info_outline,
            title: 'Challenge Info',
            onTap: () {
              Navigator.pop(context);
              // Navigate to challenge details
            },
          ),
          _buildChatOption(
            icon: Icons.notifications_outlined,
            title: 'Mute Notifications',
            onTap: () {
              Navigator.pop(context);
              // Toggle notifications
            },
          ),
          _buildChatOption(
            icon: Icons.fitness_center,
            title: 'Share Workout',
            onTap: () {
              Navigator.pop(context);
              _shareWorkoutCompletion();
            },
          ),
          _buildChatOption(
            icon: Icons.emoji_events,
            title: 'Share Achievement',
            onTap: () {
              Navigator.pop(context);
              _shareAchievement();
            },
          ),
        ],
      ),
    );
  }

  /// Builds individual chat option item
  Widget _buildChatOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      onTap: onTap,
    );
  }

  /// Shows message options (react, reply, etc.)
  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ReactionType.values.map((reaction) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _handleReaction(message, reaction);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      ChatMessage.getReactionEmoji(reaction),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Reply option
            if (message.senderId != _currentUserId)
              ListTile(
                leading: const Icon(Icons.reply, color: AppTheme.textPrimary),
                title: const Text('Reply', style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _handleReply(message);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Shows attachment options
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChatOption(
              icon: Icons.photo,
              title: 'Photo (Coming Soon)',
              onTap: () => Navigator.pop(context),
            ),
            _buildChatOption(
              icon: Icons.fitness_center,
              title: 'Share Workout',
              onTap: () {
                Navigator.pop(context);
                _shareWorkoutCompletion();
              },
            ),
            _buildChatOption(
              icon: Icons.emoji_events,
              title: 'Share Achievement',
              onTap: () {
                Navigator.pop(context);
                _shareAchievement();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder for viewing user profile
  void _viewUserProfile(String userId) {
    // TODO: Navigate to user profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View profile for user $userId'),
        backgroundColor: AppTheme.accentYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Gets user avatar color based on user ID
  Color _getUserAvatarColor(String userId) {
    // Generate consistent color based on user ID
    final colors = [
      AppTheme.rankA,
      AppTheme.rankB,
      AppTheme.rankC,
      AppTheme.rankS,
      AppTheme.rankSS,
    ];
    return colors[userId.hashCode % colors.length];
  }

  /// Determines if timestamp divider should be shown
  bool _shouldShowTimestamp(int index) {
    if (index == _messages.length - 1) return true; // Always show for first message
    
    final currentMessage = _messages[_messages.length - 1 - index];
    final nextMessage = _messages[_messages.length - index];
    
    final difference = nextMessage.timestamp.difference(currentMessage.timestamp);
    return difference.inHours >= 1; // Show divider if messages are 1+ hours apart
  }

  /// Formats timestamp for dividers
  String _formatTimestampDivider(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[timestamp.weekday - 1];
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}