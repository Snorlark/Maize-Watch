lib/
├── core/
│ ├── constants/ # API endpoints, string constants
│ ├── error/ # Custom exceptions and failure classes
│ ├── network/ # Shared network client (e.g., Dio, http)
│ ├── themes/ # App-wide themes and styles
│ └── utils/ # Helper functions, formatters, etc.
│
├── features/
│ ├── authentication/
│ │ ├── domain/
│ │ │ ├── entities/ # User entity
│ │ │ ├── repositories/ # Authentication repository interface
│ │ │ └── usecases/ # Login, register, logout use cases
│ │ ├── data/
│ │ │ ├── datasources/ # Remote and local data sources
│ │ │ ├── models/ # Data transfer objects (DTOs)
│ │ │ └── repositories/ # Authentication repository implementation
│ │ └── presentation/
│ │ ├── bloc/
│ │ ├── pages/ # Login, register pages
│ │ └── widgets/ # Custom UI components for this feature
│ │
│ ├── live_monitoring/
│ │ ├── domain/
│ │ │ ├── entities/ # SensorReading, CornField entities
│ │ │ ├── repositories/ # Sensor data repository interface
│ │ │ └── usecases/ # GetLiveSensorData use case
│ │ ├── data/
│ │ │ ├── datasources/ # Sensor API data source
│ │ │ ├── models/ # Sensor data models
│ │ │ └── repositories/ # Sensor data repository implementation
│ │ └── presentation/
│ │ ├── bloc/
│ │ ├── pages/ # Dashboard, sensor detail pages
│ │ └── widgets/ # Sensor data widgets, charts
│ │
│ └── prescriptions/
│ ├── domain/
│ │ ├── entities/ # Prescription, ActionPlan entities
│ │ ├── repositories/ # Prescription repository interface
│ │ └── usecases/ # GetPrescriptions, GeneratePrescriptiveAction use cases
│ ├── data/
│ │ ├── datasources/ # Prescription API data source
│ │ ├── models/ # Prescription data models
│ │ └── repositories/ # Prescription repository implementation
│ └── presentation/
│ ├── bloc/
│ ├── pages/ # Prescriptive list page, detail page
│ └── widgets/ # Prescription widgets
│
├── main.dart
│
└── di_container.dart # Dependency injection setup for the app
