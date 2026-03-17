# 🏥 Smart Pharmacy System (ERP Solution)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

A professional, high-performance Pharmacy Management System (ERP) built with **Flutter** and **Firebase**. This system is designed to streamline daily pharmacy operations, from inventory tracking to point-of-sale (POS) and financial analytics.

---

## 🚀 Key Features

### 📦 Smart Inventory Management
- **Categorized Products:** Organize medicines (Antibiotics, Cold & Flu, Cosmetics, etc.).
- **Expiry Tracker:** Visual alerts for expired and near-expiry items (Red/Yellow indicators).
- **Barcode & Images:** Register medicines by scanning barcodes and capturing product photos.
- **Dynamic Updates:** Edit prices, quantities, and details in real-time.

### 💰 Professional POS (Point of Sale)
- **Fast Checkout:** Scan product barcodes to add them to the bill instantly.
- **Quantity Control:** Intuitive `+` and `-` buttons with stock validation.
- **Discount System:** Apply instant discounts on bills.
- **Digital Receipts:** Generate professional PDF invoices.
- **One-Click Sharing:** Share receipts directly via **WhatsApp**.

### 📊 Advanced Analytics & Dashboard
- **Profit Tracking:** Real-time calculation of potential profits and actual sales.
- **Visual Charts:** Interactive Pie charts for inventory distribution and Bar charts for sales performance.
- **Low Stock Radar:** Instant alerts for items with less than 5 units.

### 🔐 Security & Personalization
- **Google & Email Auth:** Secure login using Firebase Authentication.
- **Multi-Tenant Architecture:** Each pharmacist manages their own private database (Isolated uId).
- **Multi-Language:** Fully localized in **Arabic (Default)** and **English**.
- **Dark Mode:** A sleek Black & White professional theme.

---

## 🛠️ Technical Stack

- **Framework:** Flutter (Android/iOS)
- **Architecture:** Clean Architecture (Data, Domain, Presentation layers)
- **State Management:** Flutter BLoC / Cubit
- **Backend:** Firebase (Firestore, Auth, Storage, Messaging)
- **Reporting:** PDF & Printing packages
- **Charts:** FL Chart
- **Scanning:** Mobile Scanner (Camera-based)

---

## 📸 Visual Preview
| Login Screen | Inventory | POS System | Dashboard |
| :---: | :---: | :---: | :---: |
| *[Placeholder]* | *[Placeholder]* | *[Placeholder]* | *[Placeholder]* |

---

## ⚙️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mahmoudhany/pharamcy_system.git
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   - Create a project on [Firebase Console](https://console.firebase.google.com/).
   - Add an Android App with package name `com.example.pharmacy_system_app`.
   - Download `google-services.json` and place it in `android/app/`.
   - Enable **Authentication** (Email & Google).
   - Enable **Firestore** and **Cloud Storage**.

4. **Add SHA-1 for Google Login:**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   *Copy the SHA-1 to your Firebase Project Settings.*

5. **Run the App:**
   ```bash
   flutter run
   ```

---

## 🤝 Contribution
Contributions are welcome! Feel free to open an issue or submit a pull request.

---
*Developed with ❤️ by **Mahmoud Hany***
*For Business Inquiries: [Your Email/LinkedIn]*
