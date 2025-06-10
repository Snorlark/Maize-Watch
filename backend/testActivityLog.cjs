const mongoose = require('mongoose');
const ActivityLog = require('./models/ActivityLog');

// Test the activity log functionality
async function testActivityLog() {
  try {
    console.log('Testing Activity Log functionality...');
    
    // Connect to MongoDB
    await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/iot_monitoring_db?retryWrites=true&w=majority&appName=maizewatch-db');
    console.log('Connected to MongoDB');
    
    // Get recent activity logs
    const recentLogs = await ActivityLog.find()
      .sort({ timestamp: -1 })
      .limit(10)
      .populate('userId', 'name email role');
    
    console.log(`\nFound ${recentLogs.length} recent activity logs:`);
    
    recentLogs.forEach((log, index) => {
      console.log(`\n${index + 1}. ${log.action} - ${log.resource}`);
      console.log(`   User: ${log.userId?.name || 'Unknown'} (${log.userEmail})`);
      console.log(`   Role: ${log.userRole}`);
      console.log(`   Timestamp: ${log.timestamp}`);
      console.log(`   IP: ${log.ipAddress}`);
      if (log.details && Object.keys(log.details).length > 0) {
        console.log(`   Details: ${JSON.stringify(log.details, null, 2)}`);
      }
    });
    
    // Test role filtering
    console.log('\n\nTesting role filtering:');
    
    const userLogs = await ActivityLog.find({ userRole: 'user' }).countDocuments();
    const adminLogs = await ActivityLog.find({ userRole: 'admin' }).countDocuments();
    const superAdminLogs = await ActivityLog.find({ userRole: 'super_admin' }).countDocuments();
    
    console.log(`Logs with role 'user' (farmer): ${userLogs}`);
    console.log(`Logs with role 'admin': ${adminLogs}`);
    console.log(`Logs with role 'super_admin': ${superAdminLogs}`);
    
    // Test action filtering
    console.log('\n\nTesting action filtering:');
    
    const loginLogs = await ActivityLog.find({ action: 'login' }).countDocuments();
    const logoutLogs = await ActivityLog.find({ action: 'logout' }).countDocuments();
    const createLogs = await ActivityLog.find({ action: 'create' }).countDocuments();
    const updateLogs = await ActivityLog.find({ action: 'update' }).countDocuments();
    const deleteLogs = await ActivityLog.find({ action: 'delete' }).countDocuments();
    
    console.log(`Login logs: ${loginLogs}`);
    console.log(`Logout logs: ${logoutLogs}`);
    console.log(`Create logs: ${createLogs}`);
    console.log(`Update logs: ${updateLogs}`);
    console.log(`Delete logs: ${deleteLogs}`);
    
    console.log('\nActivity log test completed successfully!');
    
  } catch (error) {
    console.error('Error testing activity log:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

// Run the test
testActivityLog(); 