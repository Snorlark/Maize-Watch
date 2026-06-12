# MongoDB Atlas Setup for Maize-Watch

## 🗄️ Quick Setup Guide

This guide will help you set up MongoDB Atlas (free tier) for your Maize-Watch application.

## 📋 Step-by-Step Setup

### Step 1: Create MongoDB Atlas Account
1. **Go to [MongoDB Atlas](https://cloud.mongodb.com)**
2. **Click "Try Free"**
3. **Sign up with Google, GitHub, or email**

### Step 2: Create a Cluster
1. **Choose "Shared" (Free tier)**
2. **Select a region close to you**
3. **Name your cluster**: `maize-watch-cluster`
4. **Click "Create Cluster"**

### Step 3: Create Database User
1. **Go to "Database Access" in the left menu**
2. **Click "Add New Database User"**
3. **Choose "Password" authentication**
4. **Username**: `maize-watch-user`
5. **Password**: Generate a secure password (save it!)
6. **Database User Privileges**: "Read and write to any database"
7. **Click "Add User"**

### Step 4: Configure Network Access
1. **Go to "Network Access" in the left menu**
2. **Click "Add IP Address"**
3. **Choose "Allow Access from Anywhere" (0.0.0.0/0)**
4. **Click "Confirm"**

### Step 5: Get Connection String
1. **Go to "Clusters" in the left menu**
2. **Click "Connect" on your cluster**
3. **Choose "Connect your application"**
4. **Driver**: Node.js
5. **Version**: 4.1 or later
6. **Copy the connection string**

### Step 6: Update Connection String
Replace the placeholder values in your connection string:

```
mongodb+srv://maize-watch-user:<password>@maize-watch-cluster.xxxxx.mongodb.net/maizewatch?retryWrites=true&w=majority
```

**Replace:**
- `<password>` with your actual password
- `maizewatch` with your database name

### Step 7: Test Connection
You can test the connection using MongoDB Compass or any MongoDB client:

```
mongodb+srv://maize-watch-user:YOUR_PASSWORD@maize-watch-cluster.xxxxx.mongodb.net/maizewatch
```

## 🔧 Environment Variable

Add this to your Render environment variables:

```bash
MONGO_URI=mongodb+srv://maize-watch-user:YOUR_PASSWORD@maize-watch-cluster.xxxxx.mongodb.net/maizewatch
```

## 📊 Database Collections

Your application will automatically create these collections:
- `users` - User accounts
- `farms` - Farm information
- `sensors` - Sensor devices
- `sensorreadings` - Sensor data
- `fields` - Field information

## 🔒 Security Notes

1. **Keep your password secure**
2. **Don't commit connection strings to Git**
3. **Use environment variables**
4. **Regularly rotate passwords**

## 🆓 Free Tier Limits

- **Storage**: 512MB
- **Connections**: 100 concurrent
- **Backup**: 2GB
- **Perfect for development and small production apps**

## 🎉 You're Ready!

Once you have your MongoDB Atlas connection string, you can deploy your Maize-Watch application to Render with confidence!

## 📞 Need Help?

- **MongoDB Atlas Documentation**: [docs.atlas.mongodb.com](https://docs.atlas.mongodb.com)
- **MongoDB Community**: [community.mongodb.com](https://community.mongodb.com)
