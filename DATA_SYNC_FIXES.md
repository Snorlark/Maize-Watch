# Data Sync Fixes - ThingSpeak to Mobile App

## Problem
- ThingSpeak shows 25,654 lux for light intensity
- Mobile app shows 14,000 lux (stale cached data)
- Long delay between ThingSpeak updates and mobile app display

## Root Causes
1. **Multiple Caching Layers**: Backend caches ThingSpeak data, analytics caches processed data, mobile app caches final results
2. **No Automatic Sync**: No scheduled tasks to automatically sync data from ThingSpeak
3. **Cache Expiration**: Mobile app caches data for 30 minutes, backend caches for various periods

## Solutions Implemented

### 1. Backend Changes

#### Automatic Sync (server.ts)
- Added cron job that syncs data every 15 seconds
- Runs initial sync 30 seconds after server startup
- Uses `SyncService` to sync all farms' data from ThingSpeak

```typescript
// Sync every 15 seconds
cron.schedule('*/15 * * * * *', async () => {
  await syncService.syncAllFarmsData();
});
```

#### Force Sync Endpoint (analyticsController.ts)
- Added `POST /api/analytics/farms/:farmId/sync` endpoint
- Allows manual triggering of data sync
- Clears analytics cache after sync
- Returns sync status and timestamp

#### Cache Management (cacheService.ts)
- Added `clearFarmAnalyticsCache()` method
- Added `clearThingSpeakCache()` method
- Improved cache invalidation

### 2. Mobile App Changes

#### Force Refresh Button (farm_detail_widget.dart)
- Added refresh button in the header
- Calls force sync endpoint
- Clears local cache before refreshing
- Shows loading state during refresh

#### Cache Clearing (offline_cache_service.dart)
- Added `clearAnalyticsCache()` method
- Added `clearAllCache()` method
- Improved cache management

#### Improved Data Loading
- Always clears cache before loading fresh data
- Better error handling and user feedback
- Immediate UI updates after data refresh

## How to Use

### For Your Presentation

1. **Automatic Sync**: Data will sync every 15 seconds automatically
2. **Manual Refresh**: Tap the refresh button (🔄) in the farm detail screen
3. **Force Sync**: Use the API endpoint to force immediate sync

### API Endpoints

```bash
# Force sync for a specific farm
curl -X POST http://localhost:5000/api/analytics/farms/YOUR_FARM_ID/sync \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get complete analytics data
curl -X GET http://localhost:5000/api/analytics/farms/YOUR_FARM_ID/complete \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Testing

Run the test script to verify data flow:

```bash
# Set your farm ID and token
export TEST_FARM_ID="your-farm-id"
export TEST_TOKEN="your-auth-token"

# Run the test
node test_data_sync.js
```

## Expected Results

- **Immediate Updates**: Refresh button provides instant data updates
- **Automatic Sync**: Data updates every 15 seconds without manual intervention
- **Accurate Data**: Mobile app will show the same values as ThingSpeak
- **Better Performance**: Cached data for faster loading, with easy refresh option

## Debug Information

The system now includes extensive logging:
- `🔄` - Sync operations
- `✅` - Successful operations
- `❌` - Failed operations
- `💾` - Cache operations
- `🌽` - Farm detail operations

Check the backend logs and mobile app console for detailed information about data flow.

## Files Modified

### Backend
- `backend/src/server.ts` - Added cron job
- `backend/src/controllers/analyticsController.ts` - Added force sync endpoint
- `backend/src/services/cacheService.ts` - Added cache clearing methods
- `backend/src/routes/analyticsRoutes.ts` - Added sync route

### Mobile App
- `frontend/mobile/lib/features/live_monitoring/presentation/widgets/farm_detail_widget.dart` - Added refresh button and force sync
- `frontend/mobile/lib/core/services/offline_cache_service.dart` - Added cache clearing methods

### Testing
- `test_data_sync.js` - Test script for data flow verification
