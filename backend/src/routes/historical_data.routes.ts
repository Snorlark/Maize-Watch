import { Router } from 'express';
import { getHistoricalData } from '../controllers/historical_data.controller';

const router = Router();

console.log('[HISTORICAL ROUTES] Loading historical data routes...'); // ✅ Add this for debugging

/**
 * Simple debug endpoint to test if routes are working
 * GET /api/historical-data/debug
 */
router.get('/debug', (req, res) => {
  console.log('[HISTORICAL ROUTES] Debug endpoint hit');
  res.json({
    success: true,
    message: 'Historical data routes are working!',
    timestamp: new Date().toISOString(),
    requestInfo: {
      method: req.method,
      url: req.url,
      query: req.query,
      headers: {
        authorization: req.headers.authorization ? 'Present' : 'Missing'
      }
    }
  });
});

/**
 * Main historical data endpoint
 * GET /api/historical-data?period=daily&limit=7
 */
router.get('/', (req, res, next) => {
  console.log(`[HISTORICAL ROUTES] Main endpoint hit with query:`, req.query);
  getHistoricalData(req, res, next);
});

/**
 * Period-specific routes
 * GET /api/historical-data/daily?limit=7
 * GET /api/historical-data/weekly?limit=30
 * GET /api/historical-data/monthly?limit=12
 */
router.get('/:period', (req, res, next) => {
  console.log(`[HISTORICAL ROUTES] Period endpoint hit: ${req.params.period}`);
  // Inject param into query so controller logic is reused
  req.query.period = req.params.period;
  return getHistoricalData(req, res, next);
});

console.log('[HISTORICAL ROUTES] Historical data routes loaded successfully'); // ✅ Add this for debugging

export default router;