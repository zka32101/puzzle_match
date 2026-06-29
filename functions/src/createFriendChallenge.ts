import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface CreateChallengeRequest {
  createdBy: string;
  targetUserId: string;
  puzzleId: string;
  creatorTime: number;
}

interface CreateChallengeResponse {
  challengeId: string;
  shareLink: string;
  qrData?: string;
}

export const createFriendChallenge = functions
  .region('asia-northeast1')
  .https.onCall(
    async (data: CreateChallengeRequest, context): Promise<CreateChallengeResponse> => {
      if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
      }

      const { createdBy, targetUserId, puzzleId, creatorTime } = data;

      if (!targetUserId || !puzzleId) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
      }

      const challengeId = db.collection('friend_duels').doc().id;
      const shareLink = `https://puzzle-match.app/duel/${challengeId}`;

      await db.collection('friend_duels').doc(challengeId).set({
        createdBy,
        targetUserId,
        puzzleId,
        creatorTime,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'pending',
        shareLink,
      });

      return {
        challengeId,
        shareLink,
      };
    }
  );

export const recordDuelResult = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
    }

    const { challengeId, targetTime, targetUserId } = data;

    await db.collection('friend_duels').doc(challengeId).update({
      targetTime,
      status: 'completed',
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  });
