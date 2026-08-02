# System Architecture

SafeHer-AI leverages a robust client-server architecture designed for reliability, speed, and real-time responsiveness.

## 1. Frontend Architecture (Flutter)
- **Framework:** Developed in Dart using Flutter for high-performance, cross-platform compatibility (Android/iOS).
- **State Management:** Utilizes the `Provider` pattern for responsive state handling across multiple services (`AuthProvider`, `SosProvider`, `LocationProvider`).
- **Hardware Integration:** Deep integration with native APIs for direct calling, GPS sensors, and background task execution.
- **UI/UX Design:** Implements a modern, glassmorphic design system focused on high contrast and intuitive navigation under stress.

## 2. Backend Architecture (Node.js & Express)
- **Runtime Environment:** Node.js with Express framework to handle RESTful APIs.
- **Authentication:** JWT (JSON Web Tokens) for secure, stateless user sessions.
- **Controllers & Routing:**
  - `authController`: Manages user registration, login, and secure token issuance.
  - `userController`: Handles profile management and synchronizes Trusted Emergency Contacts.
  - `sosController` & `safetyController`: Core logic for managing SOS states, logging incidents, and calculating real-time safety scores.
- **Real-Time Communication:** Uses WebSockets (`websocketService.js`) for persistent, low-latency live location streaming.

## 3. Database Layer (MongoDB)
- **Primary Database:** MongoDB (NoSQL) for flexible schema design and rapid read/write operations.
- **ORM:** Mongoose is used for object modeling.
- **Data Security:** User passwords are encrypted using bcrypt hashing before storage.
- **Data Structure:** User profiles contain embedded arrays for Emergency Contacts (storing name, phone, email, and relationships), ensuring fast retrieval during critical moments.

## 4. Third-Party Integrations
- **Firebase Cloud Messaging (FCM):** Used to deliver high-priority push notifications to guardians, ensuring they are alerted even when the app is backgrounded.
- **Google Maps API:** Used for reverse geocoding and generating live tracking URLs during an SOS event.
