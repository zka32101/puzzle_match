import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const CACHE_DURATION_MIN = 5;

export const computeCountryStats = functions
  .region('asia-northeast1')
  .pubsub.schedule(`every ${CACHE_DURATION_MIN} minutes`)
  .onRun(async (context) => {
    try {
      const today = new Date().toISOString().split('T')[0];
      const leaderboardRef = db.collection('leaderboards').doc(`puzzle_${today}_global`);
      const leaderboardDoc = await leaderboardRef.get();

      if (!leaderboardDoc.exists) {
        functions.logger.info('No leaderboard found');
        return;
      }

      const entries = leaderboardDoc.data()?.entries || [];
      const countryMap = new Map<string, { times: number[]; count: number }>();

      for (const entry of entries) {
        const country = entry.country || '🌍';
        if (!countryMap.has(country)) {
          countryMap.set(country, { times: [], count: 0 });
        }
        const stats = countryMap.get(country)!;
        stats.times.push(entry.timeSeconds);
        stats.count++;
      }

      const countries = Array.from(countryMap.entries())
        .map(([country, stats]) => {
          const avgTime =
            stats.times.reduce((a, b) => a + b, 0) / stats.times.length;
          return { country, avgTime, participants: stats.count };
        })
        .sort((a, b) => a.avgTime - b.avgTime)
        .map((c, i) => ({ ...c, rank: i + 1 }));

      await db.collection('country_stats_cache').doc(today).set({
        countries,
        computedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Computed stats for ${countries.length} countries`);
    } catch (error) {
      functions.logger.error('Error computing country stats:', error);
    }
  });

export const getCountryStats = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    const today = new Date().toISOString().split('T')[0];
    const doc = await db.collection('country_stats_cache').doc(today).get();
    if (!doc.exists) return { countries: [] };
    return doc.data();
  });
