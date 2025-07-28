@echo off
echo Setting up Firebase Cloud Functions for Push Notifications...
echo.

echo Step 1: Installing Firebase CLI...
npm install -g firebase-tools

echo.
echo Step 2: Installing function dependencies...
cd functions
call npm install

echo.
echo Step 3: Login to Firebase (browser window will open)...
call firebase login

echo.
echo Step 4: Deploy Cloud Functions...
call firebase deploy --only functions

echo.
echo ============================================
echo Setup Complete!
echo ============================================
echo.
echo Your push notification system is now ready!
echo.
echo Next steps:
echo 1. Test by placing an order from the user app
echo 2. Check that farmers receive push notifications
echo 3. Test order status updates from farmer app
echo 4. Verify customers receive status notifications
echo.
echo If you encounter issues, check:
echo - Firebase Console ^> Functions
echo - Firebase Console ^> Cloud Messaging
echo - Device notification permissions
echo.
pause
