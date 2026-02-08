#!/bin/bash

# Create a directory for the test images
mkdir -p QR_Tests
cd QR_Tests

echo "Generating QR Code Test Suite..."

# 1. WIFI (Hidden password test)
qrencode -o 01_wifi.png "WIFI:S:TestNetwork;T:WPA;P:SecretPass123;;"
echo "Generated: WiFi"

# 2. URL (VirusTotal & Visit test)
qrencode -o 02_url.png "https://www.google.com"
echo "Generated: URL"

# 3. CONTACT (vCard parser test)
VCARD_DATA="BEGIN:VCARD
VERSION:3.0
N:Diederik;Bram;;;
FN:Bram Diederik
ORG:Testing Solutions
TEL;TYPE=WORK,VOICE:+31600000000
END:VCARD"
echo "$VCARD_DATA" | qrencode -o 03_vcard.png
echo "Generated: vCard"

# 4. PHONE (Call action test)
qrencode -o 04_phone.png "tel:+31612345678"
echo "Generated: Phone"

# 5. EMAIL (Mailto test)
qrencode -o 05_email.png "mailto:test@example.com?subject=RegressionTest"
echo "Generated: Email"

# 6. GEO (Maps test)
qrencode -o 06_geo.png "geo:52.3874,4.6462"
echo "Generated: Geo Location"

# 7. CRYPTO (Bitcoin test)
qrencode -o 07_crypto_btc.png "bitcoin:1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
echo "Generated: Bitcoin"

# 8. DEEP LINK (App intent test)
qrencode -o 08_deeplink.png "whatsapp://send?text=Testing"
echo "Generated: Deep Link"

# 9. SMS (Messaging test)
qrencode -o 09_sms.png "sms:+31600000000?body=Hello"
echo "Generated: SMS"

# 10. PLAIN TEXT (Base case test)
qrencode -o 10_text.png "Just a plain text note for the tester."
echo "Generated: Plain Text"

echo "--------------------------------------"
echo "DONE! All images are in the 'QR_Tests' folder."
ls -1
