#!/bin/bash

echo "🔧 Twilio Credentials Update Script"
echo "=================================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    exit 1
fi

echo "📋 Current Twilio Configuration:"
echo "================================"
grep -i twilio .env
echo ""

echo "🔑 Please enter your NEW Twilio credentials:"
echo ""

# Get new credentials
read -p "Enter NEW Twilio Account SID: " NEW_ACCOUNT_SID
read -p "Enter NEW Twilio Auth Token: " NEW_AUTH_TOKEN
read -p "Enter NEW Twilio Verify Service ID: " NEW_VERIFY_SERVICE_ID

# Validate inputs
if [ -z "$NEW_ACCOUNT_SID" ] || [ -z "$NEW_AUTH_TOKEN" ] || [ -z "$NEW_VERIFY_SERVICE_ID" ]; then
    echo "❌ All fields are required!"
    exit 1
fi

echo ""
echo "🔄 Updating Twilio credentials..."

# Backup current .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Update Twilio credentials
sed -i.tmp "s/TWILIO_ACCOUNT_SID=.*/TWILIO_ACCOUNT_SID=$NEW_ACCOUNT_SID/" .env
sed -i.tmp "s/TWILIO_AUTH_TOKEN=.*/TWILIO_AUTH_TOKEN=$NEW_AUTH_TOKEN/" .env
sed -i.tmp "s/TWILIO_VERIFY_SERVICE_ID=.*/TWILIO_VERIFY_SERVICE_ID=$NEW_VERIFY_SERVICE_ID/" .env

# Clean up temp file
rm .env.tmp

echo "✅ Twilio credentials updated successfully!"
echo ""
echo "📋 New Twilio Configuration:"
echo "============================"
grep -i twilio .env
echo ""

echo "🚀 Restarting backend server..."
pkill -f "ts-node-dev" 2>/dev/null || true
npm run dev &

echo "✅ Backend restarted with new Twilio credentials!"
echo ""
echo "🧪 Test the forgot password feature with any phone number now!"
