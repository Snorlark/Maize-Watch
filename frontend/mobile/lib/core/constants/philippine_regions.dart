/// Philippine regions enum matching backend validation
class PhilippineRegions {
  static const List<String> regions = [
    "National Capital Region (NCR)",
    "Cordillera Administrative Region (CAR)",
    "Ilocos Region (Region I)",
    "Cagayan Valley (Region II)",
    "Central Luzon (Region III)",
    "CALABARZON (Region IV-A)",
    "MIMAROPA Region (Region IV-B)",
    "Bicol Region (Region V)",
    "Western Visayas (Region VI)",
    "Central Visayas (Region VII)",
    "Eastern Visayas (Region VIII)",
    "Zamboanga Peninsula (Region IX)",
    "Northern Mindanao (Region X)",
    "Davao Region (Region XI)",
    "SOCCSKSARGEN (Region XII)",
    "Caraga (Region XIII)",
    "Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)",
  ];

  static bool isValidRegion(String region) {
    return regions.contains(region);
  }
}
