#!/bin/bash

echo "🔄 Syncing all images to main web-src public folder..."

# Copy all images from web-public to main web-src
echo "📁 Copying from web-public..."
cp /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-public/public/images/* /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/images/

# Copy all images from web-admin to main web-src (overwrite if needed)
echo "📁 Copying from web-admin..."
cp /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-admin/public/images/* /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/images/

# Copy root images from web-public
echo "📁 Copying root images from web-public..."
cp /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-public/public/maizewatch.png /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/
cp /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-public/public/maizewatchlogo.png /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/

# Copy root images from web-admin
echo "📁 Copying root images from web-admin..."
cp /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-admin/public/maizewatch.png /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/
cp /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-admin/public/maizewatchlogo.png /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/

# Copy footer images
echo "📁 Copying footer images..."
cp -r /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-public/public/footer/* /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/footer/
cp -r /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/web-admin/public/footer/* /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/footer/

echo "✅ All images synced successfully!"
echo "📊 Checking final count..."
ls /Users/larkbabao/Desktop/Maize-Watch/frontend/web-src/public/images/ | wc -l
echo "images in main web-src/public/images/"
