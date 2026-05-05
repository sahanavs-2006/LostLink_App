# 🔗 LostLink - Smart Lost & Found Recovery

![LostLink Banner](https://img.shields.io/badge/LostLink-Smart%20Recovery-blue?style=for-the-badge&logo=flutter)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)

**LostLink** is an intelligent, modern, and cross-platform mobile application designed to revolutionize how we recover lost items in public transit systems (Metros, Trains, Buses). Built for our Hackathon, it bridges the gap between commuters who lose items and station officers who find them.

---

## ✨ Key Features

- **🔍 Smart Matching Algorithm:** Automatically cross-references reported lost items with found inventory using heuristic-based matching (category, color, transport type).
- **📸 Image Upload & Gallery:** Users can upload photos of their lost items or found items. The app natively supports both cloud storage and an offline-fallback mode for lightning-fast demo purposes.
- **📊 Public Analytics Dashboard:** A live explore tab showing real-time metrics of lost vs. recovered items across all transit stations.
- **👮 Role-Based Dashboards:** 
  - **Commuter/Finder:** Report lost items, browse the network for found items, and claim belongings.
  - **Station Officer/Admin:** Review matches, verify claims with QR/OTP, and manage station inventory.
- **🎨 Beautiful UI/UX:** Built with a highly polished, responsive Flutter design system featuring dynamic color theming, glassmorphism, and smooth animations.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend & Auth:** Firebase Authentication
- **Database:** Cloud Firestore (NoSQL)
- **Storage:** Firebase Cloud Storage
- **State Management:** Provider

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`>=3.0.0`)
- Android Studio / VS Code
- A connected Firebase Project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/sahanavs-2006/LostLink_App.git
   ```
2. Navigate to the directory:
   ```bash
   cd LostLink_App
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 💡 Hackathon "Quick Demo" Mode

For fast evaluation by judges, we have built a **Quick Demo Login** system:
- On the login screen, click the **Commuter** or **Admin** demo buttons to bypass Firebase authentication.
- In Demo Mode, image uploads intelligently fall back to your device's local storage, ensuring offline capabilities work flawlessly during the pitch!


