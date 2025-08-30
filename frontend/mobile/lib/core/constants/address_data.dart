/// Address data for cascading dropdowns
class AddressData {
  static const Map<String, List<String>> regionProvinces = {
    "CALABARZON (Region IV-A)": ["Cavite"],
    // Add more regions and their provinces as needed
  };

  static const Map<String, List<String>> provinceMunicipalities = {
    "Cavite": ["Amadeo"],
    // Add more provinces and their municipalities as needed
  };

  static List<String> getProvincesForRegion(String region) {
    return regionProvinces[region] ?? [];
  }

  static List<String> getMunicipalitiesForProvince(String province) {
    return provinceMunicipalities[province] ?? [];
  }
}
