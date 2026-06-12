import dotenv from 'dotenv';
dotenv.config({ path: '.env' });

import { logger } from '../utils/logger';
import thingSpeakService from '../services/thingspeakService';

async function main() {
  try {
    logger.info('Starting ThingSpeak full backfill...');
    const saved = await thingSpeakService.backfillAll();
    logger.info(`ThingSpeak backfill completed. Saved ${saved} new records.`);
    process.exit(0);
  } catch (error: any) {
    logger.error('ThingSpeak backfill failed', { message: error?.message });
    process.exit(1);
  }
}

main();


