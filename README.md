# 💰 FinanceFlow AI

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Groq](https://img.shields.io/badge/Groq_AI-FF6B6B?style=for-the-badge&logo=openai&logoColor=white)

**Smart Personal Finance & Expense Analyzer with AI-Powered Insights**

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Usage](#-usage) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 📱 Overview

FinanceFlow AI is a modern, intelligent personal finance management application built with Flutter. It leverages AI to provide personalized financial insights, automatic transaction categorization, and smart budgeting recommendations. Track your expenses, set savings goals, and get AI-powered tips to improve your financial health.

## ✨ Features

### 🏦 Core Features
- **Transaction Management** - Track income and expenses with automatic categorization
- **Multi-Category Support** - 12+ spending categories with custom icons and colors
- **Goals Tracking** - Set and monitor savings goals with progress visualization
- **Analytics Dashboard** - Beautiful charts and spending breakdowns

### 🤖 AI-Powered Features
- **Smart Categorization** - AI automatically categorizes your transactions
- **Financial Insights** - Get personalized spending analysis and recommendations
- **AI Chatbot** - Interactive financial assistant for advice and tips
- **Smart Saving Tips** - AI-generated tips based on your spending patterns

### 📊 Analytics & Reports
- **Interactive Charts** - Pie charts, line graphs, and bar charts
- **Spending Trends** - Weekly, monthly, and yearly analysis
- **PDF Reports** - Generate and download financial reports
- **Financial Health Score** - Track your overall financial wellness

### 🔐 Security & Authentication
- **Firebase Authentication** - Secure email/password and Google Sign-In
- **Cloud Sync** - Real-time data sync across devices
- **Secure Storage** - All data stored securely in Firebase Firestore

### 🎨 UI/UX
- **Modern Design** - Beautiful gradient themes and animations
- **Dark/Light Mode** - Theme support for user preference
- **Responsive Layout** - Works on mobile, tablet, and web
- **Smooth Animations** - Lottie animations and transitions



## 🚀 Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.0.0)
- [Dart SDK](https://dart.dev/get-dart) (>=3.0.0)
- [Firebase Account](https://firebase.google.com/)
- [Groq API Key](https://console.groq.com/) (Free)
- Android Studio / VS Code with Flutter extensions

### Step-by-Step Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/chumarhassan/Finance_Flow_Ai.git
cd Finance_Flow_Ai
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Firebase Setup

1. Create a new project in [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Email/Password and Google Sign-In)
3. Enable **Cloud Firestore** database
4. Enable **Firebase Cloud Messaging** (optional, for notifications)

##### Android Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

Or manually:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Copy `lib/firebase_options.template.dart` to `lib/firebase_options.dart`
4. Fill in your Firebase configuration values

##### iOS Setup
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory
3. Update the `lib/firebase_options.dart` with iOS credentials

##### Web Setup
1. Get your Firebase web configuration from Firebase Console
2. Update `web/index.html` with your Firebase config
3. Update `lib/firebase_options.dart` with web credentials

#### 4. Groq AI Setup

1. Sign up for free at [Groq Console](https://console.groq.com/)
2. Generate an API key from [API Keys page](https://console.groq.com/keys)
3. Open `lib/services/ai_service.dart`
4. Replace `YOUR_GROQ_API_KEY_HERE` with your actual API key:

```dart
static const String _apiKey = 'gsk_your_actual_api_key_here';
```

#### 5. Google Sign-In Setup (Optional)

For Google Sign-In on Web:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 Client ID (Web application)
3. Add authorized JavaScript origins and redirect URIs
4. Update the client ID in `web/index.html`:

```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

#### 6. Run the Application

```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on Windows
flutter run -d windows
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root (optional):

```env
GROQ_API_KEY=your_groq_api_key
FIREBASE_API_KEY=your_firebase_api_key
```

### Firebase Configuration Files

| File | Location | Description |
|------|----------|-------------|
| `firebase_options.dart` | `lib/` | Flutter Firebase config |
| `google-services.json` | `android/app/` | Android Firebase config |
| `GoogleService-Info.plist` | `ios/Runner/` | iOS Firebase config |

### Template Files

Template files are provided for sensitive configurations:

- `lib/firebase_options.template.dart` → Copy to `firebase_options.dart`
- `android/app/google-services.template.json` → Copy to `google-services.json`
- `lib/services/ai_service.template.dart` → Reference for AI service setup

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── config/
│   ├── colors.dart          # App color schemes
│   └── theme.dart           # Theme configuration
├── models/
│   ├── category_model.dart  # Category data model
│   ├── goal_model.dart      # Savings goal model
│   ├── transaction_model.dart # Transaction model
│   └── user_model.dart      # User profile model
├── providers/
│   ├── auth_provider.dart   # Authentication state
│   ├── theme_provider.dart  # Theme state
│   └── transaction_provider.dart # Transaction state
├── screens/
│   ├── auth/               # Login/Register screens
│   ├── home/               # Dashboard screen
│   ├── analytics/          # Analytics & charts
│   ├── goals/              # Goals management
│   ├── profile/            # User profile
│   └── transactions/       # Transaction list
├── services/
│   ├── ai_service.dart     # Groq AI integration
│   ├── auth_services.dart  # Firebase Auth
│   ├── firestore_service.dart # Firestore database
│   └── notification_service.dart # Push notifications
└── widgets/                 # Reusable UI components
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **Backend** | Firebase (Auth, Firestore, Messaging) |
| **AI/ML** | Groq API (Llama 3.3 70B) |
| **State Management** | Provider |
| **Charts** | fl_chart |
| **PDF Generation** | pdf package |
| **Animations** | Lottie, Animations |

## 📖 Usage

### Adding a Transaction

1. Tap the **+** button on the dashboard
2. Enter amount and description
3. AI will auto-categorize or select manually
4. Choose income or expense
5. Save transaction

### Creating a Savings Goal

1. Navigate to **Goals** tab
2. Tap **Create New Goal**
3. Enter goal name, target amount, and deadline
4. Track progress and add money as you save

### Generating Reports

1. Go to **Analytics** screen
2. Tap **Download Report** button
3. PDF will be generated and downloaded

### Using AI Chatbot

1. Navigate to **AI Insights** screen
2. Ask questions about your finances
3. Get personalized advice and tips

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful commit messages
- Add comments for complex logic
- Write tests for new features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Chumar Hassan**

- GitHub: [@chumarhassan](https://github.com/chumarhassan)

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) for the amazing framework
- [Firebase](https://firebase.google.com/) for backend services
- [Groq](https://groq.com/) for fast AI inference
- [fl_chart](https://pub.dev/packages/fl_chart) for beautiful charts

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

Made with ❤️ and Flutter

</div>
