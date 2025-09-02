/// Chat message model for challenge communication.
/// 
/// This model represents individual messages within challenge chat rooms,
/// supporting various message types including text, images, achievements,
/// and system notifications. It includes metadata for real-time features
/// like read status, reactions, and user mentions.

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Types of messages that can be sent in challenge chat
enum MessageType {
  text,        // Regular text message
  image,       // Image attachment
  achievement, // Achievement celebration
  system,      // System notifications (user joined, etc.)
  workout,     // Workout completion share
}

/// Types of reactions available for messages
enum ReactionType {
  like,     // 👍
  fire,     // 🔥
  strong,   // 💪
  celebrate, // 🎉
}

/// Represents a chat message in a challenge room
class ChatMessage extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// Content of the message
  final String content;
  
  /// ID of the user who sent the message
  final String senderId;
  
  /// Display name of the sender
  final String senderName;
  
  /// Username of the sender (for @mentions)
  final String senderUsername;
  
  /// URL to sender's profile picture (nullable)
  final String? senderAvatarUrl;
  
  /// Timestamp when message was sent
  final DateTime timestamp;
  
  /// Type of message (text, image, achievement, etc.)
  final MessageType type;
  
  /// Whether the message has been read by the current user
  final bool isRead;
  
  /// Map of user reactions (userId -> ReactionType)
  final Map<String, ReactionType> reactions;
  
  /// List of user IDs mentioned in the message
  final List<String> mentions;
  
  /// Image URL for image messages
  final String? imageUrl;
  
  /// Achievement data for achievement messages
  final Map<String, dynamic>? achievementData;
  
  /// Workout data for workout share messages
  final Map<String, dynamic>? workoutData;
  
  /// Whether this is a reply to another message
  final String? replyToMessageId;
  
  /// Content of the message being replied to (for display)
  final String? replyToContent;
  
  /// Sender name of the message being replied to
  final String? replyToSenderName;

  /// Creates a new ChatMessage instance
  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderUsername,
    this.senderAvatarUrl,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.reactions = const {},
    this.mentions = const [],
    this.imageUrl,
    this.achievementData,
    this.workoutData,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderName,
  });

  /// Creates a ChatMessage from JSON data
  /// 
  /// @param data Map containing JSON fields
  /// @param documentId The message ID
  /// @return ChatMessage instance
  factory ChatMessage.fromJson(Map<String, dynamic> data, String documentId) {
    return ChatMessage(
      id: documentId,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderUsername: data['senderUsername'] ?? '',
      senderAvatarUrl: data['senderAvatarUrl'],
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      type: _parseMessageType(data['type']),
      isRead: data['isRead'] ?? false,
      reactions: Map<String, ReactionType>.from(
        (data['reactions'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, _parseReactionType(value)),
        ),
      ),
      mentions: List<String>.from(data['mentions'] ?? []),
      imageUrl: data['imageUrl'],
      achievementData: data['achievementData'],
      workoutData: data['workoutData'],
      replyToMessageId: data['replyToMessageId'],
      replyToContent: data['replyToContent'],
      replyToSenderName: data['replyToSenderName'],
    );
  }

  /// Converts ChatMessage to JSON-compatible map
  /// 
  /// @return Map ready for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'senderAvatarUrl': senderAvatarUrl,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'reactions': reactions.map((key, value) => MapEntry(key, value.name)),
      'mentions': mentions,
      'imageUrl': imageUrl,
      'achievementData': achievementData,
      'workoutData': workoutData,
      'replyToMessageId': replyToMessageId,
      'replyToContent': replyToContent,
      'replyToSenderName': replyToSenderName,
    };
  }

  /// Creates a copy of ChatMessage with updated fields
  ChatMessage copyWith({
    String? id,
    String? content,
    String? senderId,
    String? senderName,
    String? senderUsername,
    String? senderAvatarUrl,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    Map<String, ReactionType>? reactions,
    List<String>? mentions,
    String? imageUrl,
    Map<String, dynamic>? achievementData,
    Map<String, dynamic>? workoutData,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderUsername: senderUsername ?? this.senderUsername,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      reactions: reactions ?? this.reactions,
      mentions: mentions ?? this.mentions,
      imageUrl: imageUrl ?? this.imageUrl,
      achievementData: achievementData ?? this.achievementData,
      workoutData: workoutData ?? this.workoutData,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
    );
  }

  /// Gets formatted timestamp for display
  /// 
  /// @return Formatted time string (e.g., "now", "5m ago", "Yesterday 3:21 PM")
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return 'Yesterday $hour:$minute';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekday = weekdays[timestamp.weekday - 1];
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$weekday $hour:$minute';
    } else {
      final month = timestamp.month.toString().padLeft(2, '0');
      final day = timestamp.day.toString().padLeft(2, '0');
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
  }

  /// Gets the appropriate icon for the message type
  /// 
  /// @return IconData representing the message type
  IconData get typeIcon {
    switch (type) {
      case MessageType.text:
        return Icons.message;
      case MessageType.image:
        return Icons.image;
      case MessageType.achievement:
        return Icons.emoji_events;
      case MessageType.system:
        return Icons.info_outline;
      case MessageType.workout:
        return Icons.fitness_center;
    }
  }

  /// Gets the display color for the message type
  /// 
  /// @return Color representing the message type
  Color get typeColor {
    switch (type) {
      case MessageType.text:
        return Colors.grey;
      case MessageType.image:
        return Colors.blue;
      case MessageType.achievement:
        return Colors.amber;
      case MessageType.system:
        return Colors.grey;
      case MessageType.workout:
        return Colors.green;
    }
  }

  /// Checks if the message contains mentions
  /// 
  /// @return True if message has mentions
  bool get hasMentions => mentions.isNotEmpty;

  /// Checks if the message has reactions
  /// 
  /// @return True if message has reactions
  bool get hasReactions => reactions.isNotEmpty;

  /// Gets the total number of reactions
  /// 
  /// @return Count of all reactions
  int get reactionCount => reactions.length;

  /// Checks if the message is a reply
  /// 
  /// @return True if message is replying to another message
  bool get isReply => replyToMessageId != null;

  /// Gets reaction emoji for display
  /// 
  /// @param reactionType The reaction type
  /// @return Emoji string for the reaction
  static String getReactionEmoji(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.like:
        return '👍';
      case ReactionType.fire:
        return '🔥';
      case ReactionType.strong:
        return '💪';
      case ReactionType.celebrate:
        return '🎉';
    }
  }

  /// Parses message type from string
  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'achievement':
        return MessageType.achievement;
      case 'system':
        return MessageType.system;
      case 'workout':
        return MessageType.workout;
      default:
        return MessageType.text;
    }
  }

  /// Parses reaction type from string
  static ReactionType _parseReactionType(String? reaction) {
    switch (reaction) {
      case 'fire':
        return ReactionType.fire;
      case 'strong':
        return ReactionType.strong;
      case 'celebrate':
        return ReactionType.celebrate;
      default:
        return ReactionType.like;
    }
  }

  @override
  List<Object?> get props => [
        id,
        content,
        senderId,
        senderName,
        senderUsername,
        senderAvatarUrl,
        timestamp,
        type,
        isRead,
        reactions,
        mentions,
        imageUrl,
        achievementData,
        workoutData,
        replyToMessageId,
        replyToContent,
        replyToSenderName,
      ];
}

/// Service for managing chat messages (mock implementation for development)
class ChatService {
  static final List<ChatMessage> _messages = [];
  static int _messageIdCounter = 1;

  /// Get all messages for a challenge
  /// 
  /// @param challengeId The challenge ID
  /// @return List of messages sorted by timestamp
  static List<ChatMessage> getMessages(String challengeId) {
    // In real implementation, this would filter by challengeId
    return List.from(_messages)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Send a new message
  /// 
  /// @param challengeId The challenge ID
  /// @param senderId The sender's user ID  
  /// @param senderName The sender's display name
  /// @param senderUsername The sender's username
  /// @param content The message content
  /// @param type The message type
  /// @param senderAvatarUrl Optional sender avatar URL
  /// @param replyToMessageId Optional message ID being replied to
  /// @return The created ChatMessage
  static ChatMessage sendMessage({
    required String challengeId,
    required String senderId,
    required String senderName,
    required String senderUsername,
    required String content,
    MessageType type = MessageType.text,
    String? senderAvatarUrl,
    String? replyToMessageId,
    Map<String, dynamic>? achievementData,
    Map<String, dynamic>? workoutData,
  }) {
    // Find reply message if replying
    ChatMessage? replyMessage;
    if (replyToMessageId != null) {
      try {
        replyMessage = _messages.firstWhere((msg) => msg.id == replyToMessageId);
      } catch (e) {
        // Reply message not found, ignore
      }
    }

    final message = ChatMessage(
      id: _messageIdCounter.toString(),
      content: content,
      senderId: senderId,
      senderName: senderName,
      senderUsername: senderUsername,
      senderAvatarUrl: senderAvatarUrl,
      timestamp: DateTime.now(),
      type: type,
      mentions: _extractMentions(content),
      achievementData: achievementData,
      workoutData: workoutData,
      replyToMessageId: replyToMessageId,
      replyToContent: replyMessage?.content,
      replyToSenderName: replyMessage?.senderName,
    );

    _messages.add(message);
    _messageIdCounter++;
    
    return message;
  }

  /// Add reaction to a message
  /// 
  /// @param messageId The message ID
  /// @param userId The user ID adding the reaction
  /// @param reactionType The type of reaction
  /// @return Updated ChatMessage or null if not found
  static ChatMessage? addReaction(String messageId, String userId, ReactionType reactionType) {
    final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return null;

    final message = _messages[messageIndex];
    final updatedReactions = Map<String, ReactionType>.from(message.reactions);
    updatedReactions[userId] = reactionType;

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    _messages[messageIndex] = updatedMessage;
    
    return updatedMessage;
  }

  /// Remove reaction from a message
  /// 
  /// @param messageId The message ID
  /// @param userId The user ID removing the reaction
  /// @return Updated ChatMessage or null if not found
  static ChatMessage? removeReaction(String messageId, String userId) {
    final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return null;

    final message = _messages[messageIndex];
    final updatedReactions = Map<String, ReactionType>.from(message.reactions);
    updatedReactions.remove(userId);

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    _messages[messageIndex] = updatedMessage;
    
    return updatedMessage;
  }

  /// Mark message as read
  /// 
  /// @param messageId The message ID
  /// @return Updated ChatMessage or null if not found
  static ChatMessage? markAsRead(String messageId) {
    final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return null;

    final message = _messages[messageIndex];
    final updatedMessage = message.copyWith(isRead: true);
    _messages[messageIndex] = updatedMessage;
    
    return updatedMessage;
  }

  /// Extract mentions from message content
  /// 
  /// @param content The message content
  /// @return List of mentioned user IDs (without @ symbol)
  static List<String> _extractMentions(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Add mock data for development and testing
  static void addMockData(String challengeId) {
    final now = DateTime.now();
    
    // Add system message
    sendMessage(
      challengeId: challengeId,
      senderId: 'system',
      senderName: 'System',
      senderUsername: 'system',
      content: 'Welcome to the Summer Shred Challenge chat! 💪',
      type: MessageType.system,
    );

    // Add some mock messages
    sendMessage(
      challengeId: challengeId,
      senderId: 'user1',
      senderName: 'Alex Chen',
      senderUsername: 'alexc',
      content: 'Ready to crush this challenge! Who\'s with me? 🔥',
    );

    sendMessage(
      challengeId: challengeId,
      senderId: 'user2',
      senderName: 'Jordan Smith',
      senderUsername: 'jsmith',
      content: '@alexc Count me in! Just finished a killer leg workout',
    );

    sendMessage(
      challengeId: challengeId,
      senderId: 'user3',
      senderName: 'Taylor Brown',
      senderUsername: 'tbrown',
      content: 'Great job everyone! The competition is heating up 🏆',
    );

    // Add achievement message
    sendMessage(
      challengeId: challengeId,
      senderId: 'user1',
      senderName: 'Alex Chen',
      senderUsername: 'alexc',
      content: 'Just hit a new PR!',
      type: MessageType.achievement,
      achievementData: {
        'achievementType': 'personal_record',
        'exercise': 'Bench Press',
        'value': '225 lbs',
        'previous': '215 lbs',
      },
    );

    // Add workout share
    sendMessage(
      challengeId: challengeId,
      senderId: 'user2',
      senderName: 'Jordan Smith',
      senderUsername: 'jsmith',
      content: 'Completed today\'s workout!',
      type: MessageType.workout,
      workoutData: {
        'workoutName': 'Upper Body Strength',
        'duration': '45 minutes',
        'exercises': 8,
        'points': 150,
      },
    );

    // Add recent messages with reactions
    final recentMessage = sendMessage(
      challengeId: challengeId,
      senderId: 'user4',
      senderName: 'Casey Davis',
      senderUsername: 'cdavis',
      content: 'This challenge is pushing me to new limits! Love the competition',
    );

    // Add reactions to the recent message
    addReaction(recentMessage.id, 'user1', ReactionType.fire);
    addReaction(recentMessage.id, 'user2', ReactionType.strong);
    addReaction(recentMessage.id, 'user3', ReactionType.like);
  }

  /// Clear all messages (for testing)
  static void clearMessages() {
    _messages.clear();
    _messageIdCounter = 1;
  }
}