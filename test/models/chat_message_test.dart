/// Comprehensive unit tests for ChatMessage model and ChatService.
/// 
/// This test suite covers all chat message functionality including:
/// - Message creation, serialization, and copying
/// - Time formatting and display properties
/// - Reaction management and validation
/// - Mention extraction and handling
/// - Chat service operations and mock data

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:rivalx/models/chat_message.dart';

void main() {
  group('ChatMessage Model', () {
    late ChatMessage testMessage;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testMessage = ChatMessage(
        id: 'msg_1',
        content: 'Hello @testuser, great workout today! 💪',
        senderId: 'sender_123',
        senderName: 'John Doe',
        senderUsername: 'johndoe',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: MessageType.text,
        isRead: false,
        reactions: {
          'user1': ReactionType.fire,
          'user2': ReactionType.strong,
          'user3': ReactionType.like,
        },
        mentions: ['testuser'],
      );
    });

    group('Basic Properties', () {
      test('should create message with all properties', () {
        expect(testMessage.id, equals('msg_1'));
        expect(testMessage.content, equals('Hello @testuser, great workout today! 💪'));
        expect(testMessage.senderId, equals('sender_123'));
        expect(testMessage.senderName, equals('John Doe'));
        expect(testMessage.senderUsername, equals('johndoe'));
        expect(testMessage.senderAvatarUrl, equals('https://example.com/avatar.jpg'));
        expect(testMessage.type, equals(MessageType.text));
        expect(testMessage.isRead, isFalse);
        expect(testMessage.reactions, hasLength(3));
        expect(testMessage.mentions, equals(['testuser']));
      });

      test('should create message with minimal required properties', () {
        final minimalMessage = ChatMessage(
          id: 'minimal',
          content: 'Simple message',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          timestamp: now,
          type: MessageType.text,
        );

        expect(minimalMessage.senderAvatarUrl, isNull);
        expect(minimalMessage.isRead, isFalse);
        expect(minimalMessage.reactions, isEmpty);
        expect(minimalMessage.mentions, isEmpty);
        expect(minimalMessage.imageUrl, isNull);
        expect(minimalMessage.achievementData, isNull);
        expect(minimalMessage.workoutData, isNull);
        expect(minimalMessage.replyToMessageId, isNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testMessage.toJson();

        expect(json['content'], equals(testMessage.content));
        expect(json['senderId'], equals(testMessage.senderId));
        expect(json['senderName'], equals(testMessage.senderName));
        expect(json['senderUsername'], equals(testMessage.senderUsername));
        expect(json['type'], equals('text'));
        expect(json['isRead'], equals(false));
        expect(json['reactions'], isA<Map<String, String>>());
        expect(json['mentions'], equals(['testuser']));
        expect(json['timestamp'], contains('T')); // ISO format
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'content': 'Test message',
          'senderId': 'user123',
          'senderName': 'Test User',
          'senderUsername': 'testuser',
          'senderAvatarUrl': 'avatar.jpg',
          'timestamp': now.toIso8601String(),
          'type': 'text',
          'isRead': true,
          'reactions': {
            'user1': 'fire',
            'user2': 'strong',
          },
          'mentions': ['user456'],
          'imageUrl': null,
          'achievementData': null,
          'workoutData': null,
          'replyToMessageId': null,
          'replyToContent': null,
          'replyToSenderName': null,
        };

        final message = ChatMessage.fromJson(json, 'test_id');

        expect(message.id, equals('test_id'));
        expect(message.content, equals('Test message'));
        expect(message.senderId, equals('user123'));
        expect(message.isRead, isTrue);
        expect(message.reactions, hasLength(2));
        expect(message.reactions['user1'], equals(ReactionType.fire));
        expect(message.reactions['user2'], equals(ReactionType.strong));
        expect(message.mentions, equals(['user456']));
      });

      test('should handle missing JSON fields with defaults', () {
        final minimalJson = {
          'content': 'Basic message',
        };

        final message = ChatMessage.fromJson(minimalJson, 'basic_id');

        expect(message.id, equals('basic_id'));
        expect(message.content, equals('Basic message'));
        expect(message.senderId, equals(''));
        expect(message.senderName, equals(''));
        expect(message.isRead, isFalse);
        expect(message.reactions, isEmpty);
        expect(message.mentions, isEmpty);
      });

      test('should parse message types correctly', () {
        final types = [
          'text',
          'image',
          'achievement',
          'system',
          'workout',
          'unknown',
        ];

        final expectedTypes = [
          MessageType.text,
          MessageType.image,
          MessageType.achievement,
          MessageType.system,
          MessageType.workout,
          MessageType.text, // Default for unknown
        ];

        for (int i = 0; i < types.length; i++) {
          final json = {'type': types[i]};
          final message = ChatMessage.fromJson(json, 'test_$i');
          expect(message.type, equals(expectedTypes[i]));
        }
      });

      test('should parse reaction types correctly', () {
        final json = {
          'reactions': {
            'user1': 'fire',
            'user2': 'strong',
            'user3': 'celebrate',
            'user4': 'unknown',
          },
        };

        final message = ChatMessage.fromJson(json, 'reactions_test');

        expect(message.reactions['user1'], equals(ReactionType.fire));
        expect(message.reactions['user2'], equals(ReactionType.strong));
        expect(message.reactions['user3'], equals(ReactionType.celebrate));
        expect(message.reactions['user4'], equals(ReactionType.like)); // Default
      });
    });

    group('copyWith Method', () {
      test('should create copy with updated fields', () {
        final updatedMessage = testMessage.copyWith(
          content: 'Updated content',
          isRead: true,
          reactions: {'new_user': ReactionType.celebrate},
        );

        expect(updatedMessage.id, equals(testMessage.id)); // Unchanged
        expect(updatedMessage.senderId, equals(testMessage.senderId)); // Unchanged
        expect(updatedMessage.content, equals('Updated content')); // Changed
        expect(updatedMessage.isRead, isTrue); // Changed
        expect(updatedMessage.reactions, hasLength(1)); // Changed
        expect(updatedMessage.reactions['new_user'], equals(ReactionType.celebrate));
      });

      test('should preserve original when no changes specified', () {
        final copy = testMessage.copyWith();

        expect(copy.id, equals(testMessage.id));
        expect(copy.content, equals(testMessage.content));
        expect(copy.senderId, equals(testMessage.senderId));
        expect(copy.reactions.length, equals(testMessage.reactions.length));
      });
    });

    group('Time Formatting', () {
      test('should format recent time as "now"', () {
        final recentMessage = testMessage.copyWith(
          timestamp: now.subtract(const Duration(seconds: 30)),
        );
        expect(recentMessage.formattedTime, equals('now'));
      });

      test('should format minutes ago correctly', () {
        final minutesAgoMessage = testMessage.copyWith(
          timestamp: now.subtract(const Duration(minutes: 15)),
        );
        expect(minutesAgoMessage.formattedTime, equals('15m ago'));
      });

      test('should format hours ago correctly', () {
        final hoursAgoMessage = testMessage.copyWith(
          timestamp: now.subtract(const Duration(hours: 3)),
        );
        expect(hoursAgoMessage.formattedTime, equals('3h ago'));
      });

      test('should format yesterday with time', () {
        final yesterdayMessage = testMessage.copyWith(
          timestamp: now.subtract(const Duration(days: 1)),
        );
        final formatted = yesterdayMessage.formattedTime;
        expect(formatted, startsWith('Yesterday'));
        expect(formatted, contains(':'));
      });

      test('should format weekday with time', () {
        final weekdayMessage = testMessage.copyWith(
          timestamp: now.subtract(const Duration(days: 3)),
        );
        final formatted = weekdayMessage.formattedTime;
        expect(formatted, matches(RegExp(r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) \d{2}:\d{2}$')));
      });

      test('should format older dates with month/day and time', () {
        final oldMessage = testMessage.copyWith(
          timestamp: now.subtract(const Duration(days: 10)),
        );
        final formatted = oldMessage.formattedTime;
        expect(formatted, matches(RegExp(r'^\d{2}/\d{2} \d{2}:\d{2}$')));
      });
    });

    group('Display Properties', () {
      test('should return correct icon for message types', () {
        final textMessage = testMessage.copyWith(type: MessageType.text);
        expect(textMessage.typeIcon, equals(Icons.message));

        final imageMessage = testMessage.copyWith(type: MessageType.image);
        expect(imageMessage.typeIcon, equals(Icons.image));

        final achievementMessage = testMessage.copyWith(type: MessageType.achievement);
        expect(achievementMessage.typeIcon, equals(Icons.emoji_events));

        final systemMessage = testMessage.copyWith(type: MessageType.system);
        expect(systemMessage.typeIcon, equals(Icons.info_outline));

        final workoutMessage = testMessage.copyWith(type: MessageType.workout);
        expect(workoutMessage.typeIcon, equals(Icons.fitness_center));
      });

      test('should return correct color for message types', () {
        final textMessage = testMessage.copyWith(type: MessageType.text);
        expect(textMessage.typeColor, equals(Colors.grey));

        final imageMessage = testMessage.copyWith(type: MessageType.image);
        expect(imageMessage.typeColor, equals(Colors.blue));

        final achievementMessage = testMessage.copyWith(type: MessageType.achievement);
        expect(achievementMessage.typeColor, equals(Colors.amber));

        final systemMessage = testMessage.copyWith(type: MessageType.system);
        expect(systemMessage.typeColor, equals(Colors.grey));

        final workoutMessage = testMessage.copyWith(type: MessageType.workout);
        expect(workoutMessage.typeColor, equals(Colors.green));
      });
    });

    group('Boolean Properties', () {
      test('should correctly identify messages with mentions', () {
        expect(testMessage.hasMentions, isTrue);

        final noMentionsMessage = testMessage.copyWith(mentions: []);
        expect(noMentionsMessage.hasMentions, isFalse);
      });

      test('should correctly identify messages with reactions', () {
        expect(testMessage.hasReactions, isTrue);
        expect(testMessage.reactionCount, equals(3));

        final noReactionsMessage = testMessage.copyWith(reactions: {});
        expect(noReactionsMessage.hasReactions, isFalse);
        expect(noReactionsMessage.reactionCount, equals(0));
      });

      test('should correctly identify reply messages', () {
        expect(testMessage.isReply, isFalse);

        final replyMessage = testMessage.copyWith(
          replyToMessageId: 'original_msg',
          replyToContent: 'Original message',
          replyToSenderName: 'Original Sender',
        );
        expect(replyMessage.isReply, isTrue);
      });
    });

    group('Static Methods', () {
      test('should return correct emoji for reaction types', () {
        expect(ChatMessage.getReactionEmoji(ReactionType.like), equals('👍'));
        expect(ChatMessage.getReactionEmoji(ReactionType.fire), equals('🔥'));
        expect(ChatMessage.getReactionEmoji(ReactionType.strong), equals('💪'));
        expect(ChatMessage.getReactionEmoji(ReactionType.celebrate), equals('🎉'));
      });
    });

    group('Equatable Properties', () {
      test('should be equal for identical messages', () {
        final identicalMessage = ChatMessage(
          id: testMessage.id,
          content: testMessage.content,
          senderId: testMessage.senderId,
          senderName: testMessage.senderName,
          senderUsername: testMessage.senderUsername,
          senderAvatarUrl: testMessage.senderAvatarUrl,
          timestamp: testMessage.timestamp,
          type: testMessage.type,
          isRead: testMessage.isRead,
          reactions: testMessage.reactions,
          mentions: testMessage.mentions,
        );

        expect(testMessage, equals(identicalMessage));
      });

      test('should not be equal for different messages', () {
        final differentMessage = testMessage.copyWith(content: 'Different content');
        expect(testMessage, isNot(equals(differentMessage)));
      });
    });

    group('Special Message Types', () {
      test('should handle image messages correctly', () {
        final imageMessage = ChatMessage(
          id: 'img_1',
          content: 'Check out this progress pic!',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          timestamp: now,
          type: MessageType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(imageMessage.type, equals(MessageType.image));
        expect(imageMessage.imageUrl, equals('https://example.com/image.jpg'));
        expect(imageMessage.typeIcon, equals(Icons.image));
        expect(imageMessage.typeColor, equals(Colors.blue));
      });

      test('should handle achievement messages correctly', () {
        final achievementMessage = ChatMessage(
          id: 'achievement_1',
          content: 'New personal record!',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          timestamp: now,
          type: MessageType.achievement,
          achievementData: {
            'achievementType': 'personal_record',
            'exercise': 'Bench Press',
            'value': '225 lbs',
            'previous': '215 lbs',
          },
        );

        expect(achievementMessage.type, equals(MessageType.achievement));
        expect(achievementMessage.achievementData, isNotNull);
        expect(achievementMessage.achievementData!['exercise'], equals('Bench Press'));
        expect(achievementMessage.typeIcon, equals(Icons.emoji_events));
        expect(achievementMessage.typeColor, equals(Colors.amber));
      });

      test('should handle workout messages correctly', () {
        final workoutMessage = ChatMessage(
          id: 'workout_1',
          content: 'Completed today\'s workout!',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          timestamp: now,
          type: MessageType.workout,
          workoutData: {
            'workoutName': 'Upper Body Strength',
            'duration': '45 minutes',
            'exercises': 8,
            'points': 150,
          },
        );

        expect(workoutMessage.type, equals(MessageType.workout));
        expect(workoutMessage.workoutData, isNotNull);
        expect(workoutMessage.workoutData!['workoutName'], equals('Upper Body Strength'));
        expect(workoutMessage.workoutData!['points'], equals(150));
        expect(workoutMessage.typeIcon, equals(Icons.fitness_center));
        expect(workoutMessage.typeColor, equals(Colors.green));
      });

      test('should handle system messages correctly', () {
        final systemMessage = ChatMessage(
          id: 'system_1',
          content: 'User joined the challenge',
          senderId: 'system',
          senderName: 'System',
          senderUsername: 'system',
          timestamp: now,
          type: MessageType.system,
        );

        expect(systemMessage.type, equals(MessageType.system));
        expect(systemMessage.typeIcon, equals(Icons.info_outline));
        expect(systemMessage.typeColor, equals(Colors.grey));
      });
    });
  });

  group('ChatService', () {
    setUp(() {
      ChatService.clearMessages();
    });

    group('Message Management', () {
      test('should send text message correctly', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Hello everyone!',
        );

        expect(message.id, isNotEmpty);
        expect(message.content, equals('Hello everyone!'));
        expect(message.senderId, equals('user_123'));
        expect(message.type, equals(MessageType.text));
        expect(message.timestamp, isNotNull);
      });

      test('should send achievement message with data', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'New PR achieved!',
          type: MessageType.achievement,
          achievementData: {
            'exercise': 'Deadlift',
            'weight': '300 lbs',
          },
        );

        expect(message.type, equals(MessageType.achievement));
        expect(message.achievementData, isNotNull);
        expect(message.achievementData!['exercise'], equals('Deadlift'));
      });

      test('should send workout message with data', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Workout completed!',
          type: MessageType.workout,
          workoutData: {
            'duration': '60 minutes',
            'exercises': 6,
            'points': 200,
          },
        );

        expect(message.type, equals(MessageType.workout));
        expect(message.workoutData, isNotNull);
        expect(message.workoutData!['points'], equals(200));
      });

      test('should extract mentions from message content', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Great work @johndoe and @janedoe! @everyone should see this.',
        );

        expect(message.mentions, hasLength(3));
        expect(message.mentions, containsAll(['johndoe', 'janedoe', 'everyone']));
      });

      test('should handle reply messages correctly', () {
        // Send original message
        final originalMessage = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_456',
          senderName: 'Original User',
          senderUsername: 'originaluser',
          content: 'Original message content',
        );

        // Send reply
        final replyMessage = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Reply User',
          senderUsername: 'replyuser',
          content: 'This is a reply',
          replyToMessageId: originalMessage.id,
        );

        expect(replyMessage.isReply, isTrue);
        expect(replyMessage.replyToMessageId, equals(originalMessage.id));
        expect(replyMessage.replyToContent, equals('Original message content'));
        expect(replyMessage.replyToSenderName, equals('Original User'));
      });

      test('should handle reply to non-existent message gracefully', () {
        final replyMessage = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Reply User',
          senderUsername: 'replyuser',
          content: 'This is a reply to nothing',
          replyToMessageId: 'non_existent',
        );

        expect(replyMessage.replyToMessageId, equals('non_existent'));
        expect(replyMessage.replyToContent, isNull);
        expect(replyMessage.replyToSenderName, isNull);
      });
    });

    group('Message Retrieval', () {
      test('should get messages sorted by timestamp', () {
        final now = DateTime.now();
        
        // Send messages in reverse chronological order
        ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_2',
          senderName: 'User 2',
          senderUsername: 'user2',
          content: 'Second message',
        );

        ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_1',
          senderName: 'User 1',
          senderUsername: 'user1',
          content: 'First message',
        );

        final messages = ChatService.getMessages('challenge_1');
        
        expect(messages, hasLength(2));
        // Should be sorted by timestamp ascending
        expect(messages[0].content, equals('Second message'));
        expect(messages[1].content, equals('First message'));
      });

      test('should return empty list for new challenge', () {
        final messages = ChatService.getMessages('new_challenge');
        expect(messages, isEmpty);
      });
    });

    group('Reaction Management', () {
      test('should add reaction to message', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Great workout!',
        );

        final updatedMessage = ChatService.addReaction(
          message.id,
          'reactor_456',
          ReactionType.fire,
        );

        expect(updatedMessage, isNotNull);
        expect(updatedMessage!.reactions, hasLength(1));
        expect(updatedMessage.reactions['reactor_456'], equals(ReactionType.fire));
        expect(updatedMessage.hasReactions, isTrue);
      });

      test('should update existing reaction', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Amazing progress!',
        );

        // Add initial reaction
        ChatService.addReaction(message.id, 'reactor_456', ReactionType.like);
        
        // Update to different reaction
        final updatedMessage = ChatService.addReaction(
          message.id,
          'reactor_456',
          ReactionType.strong,
        );

        expect(updatedMessage, isNotNull);
        expect(updatedMessage!.reactions, hasLength(1));
        expect(updatedMessage.reactions['reactor_456'], equals(ReactionType.strong));
      });

      test('should remove reaction from message', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Good job!',
        );

        // Add reaction
        ChatService.addReaction(message.id, 'reactor_456', ReactionType.celebrate);
        
        // Remove reaction
        final updatedMessage = ChatService.removeReaction(message.id, 'reactor_456');

        expect(updatedMessage, isNotNull);
        expect(updatedMessage!.reactions, isEmpty);
        expect(updatedMessage.hasReactions, isFalse);
      });

      test('should return null for non-existent message reaction operations', () {
        final addResult = ChatService.addReaction('non_existent', 'user', ReactionType.like);
        expect(addResult, isNull);

        final removeResult = ChatService.removeReaction('non_existent', 'user');
        expect(removeResult, isNull);
      });
    });

    group('Read Status Management', () {
      test('should mark message as read', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user_123',
          senderName: 'Test User',
          senderUsername: 'testuser',
          content: 'Unread message',
        );

        expect(message.isRead, isFalse);

        final updatedMessage = ChatService.markAsRead(message.id);

        expect(updatedMessage, isNotNull);
        expect(updatedMessage!.isRead, isTrue);
      });

      test('should return null for non-existent message read operation', () {
        final result = ChatService.markAsRead('non_existent');
        expect(result, isNull);
      });
    });

    group('Mock Data', () {
      test('should add mock data correctly', () {
        ChatService.addMockData('test_challenge');

        final messages = ChatService.getMessages('test_challenge');
        expect(messages, isNotEmpty);
        
        // Should have system message
        expect(messages.any((m) => m.type == MessageType.system), isTrue);
        
        // Should have text messages
        expect(messages.any((m) => m.type == MessageType.text), isTrue);
        
        // Should have achievement message
        expect(messages.any((m) => m.type == MessageType.achievement), isTrue);
        
        // Should have workout message
        expect(messages.any((m) => m.type == MessageType.workout), isTrue);
        
        // Should have messages with reactions
        expect(messages.any((m) => m.hasReactions), isTrue);
        
        // Should have messages with mentions
        expect(messages.any((m) => m.hasMentions), isTrue);
      });

      test('should generate unique message IDs', () {
        ChatService.addMockData('test_challenge_1');
        ChatService.addMockData('test_challenge_2');

        final messages1 = ChatService.getMessages('test_challenge_1');
        final messages2 = ChatService.getMessages('test_challenge_2');

        final allIds = [...messages1.map((m) => m.id), ...messages2.map((m) => m.id)];
        final uniqueIds = allIds.toSet();

        expect(uniqueIds.length, equals(allIds.length)); // All IDs should be unique
      });
    });

    group('Message Counter', () {
      test('should increment message counter for each new message', () {
        final message1 = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'First message',
        );

        final message2 = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'Second message',
        );

        final id1 = int.parse(message1.id);
        final id2 = int.parse(message2.id);

        expect(id2, equals(id1 + 1));
      });

      test('should reset counter when clearing messages', () {
        // Send some messages
        ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'Message',
        );

        ChatService.clearMessages();

        final newMessage = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'New message',
        );

        expect(newMessage.id, equals('1')); // Should reset to 1
      });
    });

    group('Mention Extraction', () {
      test('should extract multiple mentions correctly', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'Hey @alice, @bob, and @charlie! Great work today @everyone.',
        );

        expect(message.mentions, hasLength(4));
        expect(message.mentions, containsAll(['alice', 'bob', 'charlie', 'everyone']));
      });

      test('should handle message with no mentions', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'This message has no mentions',
        );

        expect(message.mentions, isEmpty);
        expect(message.hasMentions, isFalse);
      });

      test('should extract mentions with underscores and numbers', () {
        final message = ChatService.sendMessage(
          challengeId: 'challenge_1',
          senderId: 'user',
          senderName: 'User',
          senderUsername: 'user',
          content: 'Shoutout to @user_123 and @test_user_456!',
        );

        expect(message.mentions, hasLength(2));
        expect(message.mentions, containsAll(['user_123', 'test_user_456']));
      });
    });
  });
}