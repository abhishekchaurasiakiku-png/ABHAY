# SafeHer-AI Features

SafeHer-AI is a comprehensive safety companion tailored to empower individuals with robust tools and actionable insights.

## Core Emergency Features

1. **One-Tap SOS Alert System**
   - Instantly triggers an emergency sequence with a single tap.
   - Bypasses standard menus to ensure immediate action in critical situations.

2. **Real-Time GPS Location Tracking**
   - Captures real-time geographical coordinates upon SOS activation.
   - Generates live tracking Google Maps links automatically sent to Trusted Guardians via email or SMS.

3. **Trusted Guardian Auto-Dialer (Zero Delay)**
   - Allows users to designate Trusted Emergency Contacts (with Name, Phone, and Email).
   - "Call Trusted Contact" functionality utilizes native direct-dialer integration (`flutter_phone_direct_caller`), skipping the OS dial-pad screen for instantaneous calling.

4. **Background Media Capture**
   - Silently records audio, snaps photos, and records video during an active SOS to preserve crucial evidence.

## Advanced AI-Powered Features

5. **AI Guardian Mode**
   - Continuously monitors the user's environment in the background using device sensors.
   - Employs voice keyword detection (e.g., listening for distress phrases like "help me") and irregular motion detection to autonomously trigger an SOS without manual input.

6. **Dynamic Safety Score**
   - Calculates a real-time safety metric (out of 100) based on location context, time of day, and environmental data.
   - Helps users stay aware of their surroundings visually via the dashboard.

## Convenience and Preparedness

7. **Emergency Contacts Management**
   - Easy-to-use profile section to add, modify, and delete Trusted Emergency Contacts.
   - Automatically syncs with a secure cloud backend (MongoDB) across devices.
   
8. **Live Alert Email Integration**
   - When an SOS is triggered, an email draft is automatically compiled with the user's live location and distress message, seamlessly opening the user's preferred mail app to alert all guardians simultaneously.
