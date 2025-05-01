import { MongoClient } from 'mongodb';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import readline from 'readline';

// Setup dirname for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Function to prompt user for input
const prompt = (question) => {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
};

// Main function
async function setupAdmin() {
  // MongoDB connection
  const client = new MongoClient('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  
  try {
    console.log('\n----- Admin Account Setup -----\n');
    
    // Connect to MongoDB
    await client.connect();
    console.log('Connected to MongoDB successfully');
    
    const db = client.db();
    
    // Check if admin already exists
    const existingAdmin = await db.collection('users').findOne({ role: 'admin' });
    
    if (existingAdmin) {
      console.log('\n⚠️  An admin account already exists with username:', existingAdmin.username);
      const override = await prompt('Do you want to create another admin account anyway? (y/n): ');
      
      if (override.toLowerCase() !== 'y') {
        console.log('\nAdmin setup cancelled.');
        return;
      }
    }
    
    // Get admin information
    console.log('\nPlease enter the admin account details:');
    const username = await prompt('Username: ');
    const password = await prompt('Password: ');
    const fullName = await prompt('Full Name: ');
    const contactNumber = await prompt('Contact Number: ');
    const address = await prompt('Address: ');
    const email = await prompt('Email: ');
    
    // Validate inputs
    if (!username || !password) {
      console.log('\n❌ Username and password are required!');
      return;
    }
    
    // Check if username already exists
    const existingUser = await db.collection('users').findOne({ username });
    if (existingUser) {
      console.log('\n❌ Username already exists! Please choose a different username.');
      return;
    }
    
    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    // Create admin user
    const adminUser = {
      username,
      password: hashedPassword,
      fullName: fullName || 'Administrator',
      contactNumber: contactNumber || 'N/A',
      address: address || 'N/A',
      email: email || 'admin@example.com',
      role: 'admin',
      createdAt: new Date().toISOString()
    };
    
    // Insert admin into database
    const result = await db.collection('users').insertOne(adminUser);
    
    console.log('\n✅ Admin account created successfully!');
    console.log(`Admin ID: ${result.insertedId}`);
    console.log(`Username: ${username}`);
    console.log('\nYou can now log in with these credentials.');
    
  } catch (error) {
    console.error('\n❌ Error setting up admin account:', error);
  } finally {
    // Close MongoDB connection and readline interface
    await client.close();
    rl.close();
  }
}

// Run the setup
setupAdmin();