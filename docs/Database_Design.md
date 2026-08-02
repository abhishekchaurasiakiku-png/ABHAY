# Database Design

SafeHer-AI uses a NoSQL database (**MongoDB**) managed through **Mongoose**, prioritizing flexibility, scalability, and fast read/write speeds which are critical during emergencies.

## 1. User Model (`User.js`)
The core entity representing an individual using the SafeHer-AI app. It stores profile data, authentication secrets, nested configurations, and emergency contacts.

### Fields:
- **`name`** (String): Full name of the user.
- **`phone`** (String): Primary contact number.
- **`email`** (String): Unique identifier and email address for communication.
- **`profileImage`** (String): URL or path to the user's avatar.
- **`passwordHash`** (String): Bcrypt encrypted password.
- **`fcmToken`** (String): Firebase Cloud Messaging token for push notifications.

### Embedded Sub-Documents:
**A. `emergencyContactSchema`**
Used to store the list of Trusted Guardians. By embedding this inside the User document, we ensure that retrieving a user profile instantly fetches their contacts without expensive joins.
- `name` (String)
- `phone` (String)
- `email` (String)
- `relationship` (String)
- `notifyOnSos` (Boolean)

**B. `aiSettingsSchema`**
Stores the individual thresholds and settings for the AI Guardian engine.
- `voiceSensitivity` (Number: 0-1)
- `motionSensitivity` (Number: 0-1)
- `voiceDetectionEnabled` (Boolean)
- `motionDetectionEnabled` (Boolean)
- `distressKeywords` (Array of Strings)

## 2. Incident/SOS Models (Future / Ongoing)
*While the core app revolves around the User model, future scaling incorporates dedicated collections for Incident tracking.*
- Logs each SOS trigger event.
- Records `startTime`, `resolvedTime`, `triggerMethod` (Manual vs AI).
- Stores references to any media evidence uploaded (audio/video).

## Why MongoDB?
- **Speed:** Reading a single user document pulls all emergency contacts and AI settings instantly, which is crucial when an SOS is triggered.
- **Flexibility:** Adding new AI settings or contact fields requires minimal schema migrations.
