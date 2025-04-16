![MAIZE WATCH](https://github.com/user-attachments/assets/55088bfb-4cbb-469c-a148-11fa4654b44a)


# MAIZE WATCH: IoT-Driven Corn Monitoring and Prescriptive Analytics System

**MAIZE WATCH** is a real-time, IoT-powered monitoring and analytics system developed to support corn farmers in optimizing crop yield, improving sustainability, and making data-driven agricultural decisions. It collects field data through sensors and provides actionable insights using machine learning.

## Project Overview

MAIZE WATCH utilizes a network of environmental sensors to monitor real-time field conditions such as:

- Temperature and Humidity (DHT11)
- Soil Moisture (YL-69)
- Light Intensity (LDR)
- Soil pH (Analog Soil pH Sensor)

Sensor data is transmitted via a SIM-enabled microcontroller to the cloud using **Firebase**. This data is processed and visualized in real-time through a **mobile application (Flutter)** for farmers and a **web dashboard (React)** for administrators. A **Random Forest** model powers the prescriptive analytics system, offering recommendations to enhance farm productivity.

## Key Features

- **Real-time Sensor Monitoring**  
  View live environmental data from the field.

- **Prescriptive Analytics**  
  Get data-driven insights and farming recommendations powered by machine learning.

- **Multi-Platform Access**  
  Use the mobile app for on-site monitoring and the web dashboard for advanced analytics.

- **Role-Based Access Control**  
  Farmers and admin users have separate access levels using Firebase Authentication.

- **Data Export**  
  Export reports in CSV and PDF formats for further analysis and documentation.

## System Architecture

1. **Hardware Layer**  
   Arduino-compatible microcontroller connected to DHT11, YL-69, LDR, and Soil pH sensors.

2. **Data Transmission**  
   Microcontroller sends data via SIM-based HTTP requests or MQTT to Firebase.

3. **Cloud Backend**  
   Firebase Firestore stores real-time data. Firebase Cloud Functions handle analytics and data transformation.

4. **Analytics Layer**  
   A Random Forest model (trained in Python) provides recommendations based on sensor readings.

5. **Frontend Layer**  
   - **Flutter Mobile App**: Used by farmers to monitor crops.
   - **React Web Dashboard**: Used by admin (e.g., PhilMaize staff) for data visualization and export.

## Tech Stack

| Layer            | Technology Used                                    |
|------------------|----------------------------------------------------|
| Frontend (Web)   | React, Tailwind CSS                                |
| Frontend (Mobile)| Flutter                                            |
| Backend          | Node.js, Express, Firebase Functions               |
| Cloud Services   | Firebase Authentication, Firestore, Firebase Hosting |
| Hardware         | Arduino-compatible board, DHT11, YL-69, LDR, pH sensor |
| ML/Analytics     | Python, Scikit-learn (Random Forest)               |
| IoT Middleware   | Node-RED, MQTT                                     |

## Installation and Setup

### Prerequisites

- Node.js and npm
- Firebase CLI
- Flutter SDK
- Python 3.x
- Arduino IDE

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/maize-watch.git
cd maize-watch
```

### 2. Web Dashboard

```bash
cd web-dashboard
npm install
npm run dev
```

### 3. Mobile App

```bash
cd mobile-app
flutter pub get
flutter run
```


