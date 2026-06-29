import * as admin from 'firebase-admin';

admin.initializeApp();

export * from './createFriendChallenge';
export * from './scheduleNotifications';
export * from './saveGhostReplay';
export * from './getRivalMatchup';
export * from './computeCountryStats';
export * from './seasonReset';
