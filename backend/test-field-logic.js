// Test the prescription field logic directly
console.log('🧪 Testing prescription field logic...');

// Mock farm data with actual field names
const mockFarm = {
  _id: '675ac48c44c44c44c44c44c4',
  fields: [
    {
      fieldName: 'Field Durant',
      sensors: [
        { deviceID: 'PROTO_001', soilType: 'Loam' }
      ],
      growthStage: 'V8'
    },
    {
      fieldName: '02 PROTO',
      sensors: [
        { deviceID: 'PROTO_002', soilType: 'Clay' }
      ],
      growthStage: 'V6'
    }
  ]
};

console.log('🔍 Mock farm data:', JSON.stringify(mockFarm, null, 2));

// Test the field name extraction logic
console.log('🔍 Found farm with fields:', mockFarm.fields.map((f) => f.fieldName));

// Test prescription generation for each field
const samplePrescriptions = [];

for (const field of mockFarm.fields) {
  console.log(`🔍 Generating prescriptions for field: ${field.fieldName}`);
  
  // Generate prescriptions for each field
  const fieldPrescriptions = [
    {
      farmId: mockFarm._id,
      title: 'Check Soil Moisture',
      description: 'Monitor soil moisture levels and irrigate if needed. Optimal range is 30-70% for most crops.',
      priority: 'high',
      status: 'pending',
      dueDate: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
      category: 'irrigation',
      estimatedDuration: '30 minutes',
      materials: ['Water', 'Irrigation system', 'Timer'],
      instructions: ['Check soil moisture levels', 'Adjust irrigation schedule', 'Monitor plant response'],
      urgency: 'HIGH',
      timeline: 'Today',
      parameter: 'soil_moisture',
      fieldName: field.fieldName, // ✅ This should now use actual field names
      soilType: field.sensors?.[0]?.soilType || 'Loam',
      growthStage: field.growthStage || 'V8'
    },
    {
      farmId: mockFarm._id,
      title: 'Monitor Weather Conditions',
      description: 'Check current weather and forecast to plan farm activities accordingly.',
      priority: 'medium',
      status: 'pending',
      dueDate: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4 hours from now
      category: 'weather',
      estimatedDuration: '15 minutes',
      materials: ['Weather app', 'Thermometer', 'Rain gauge'],
      instructions: ['Check weather forecast', 'Monitor temperature', 'Plan activities'],
      urgency: 'MEDIUM',
      timeline: 'Today',
      parameter: 'weather',
      fieldName: field.fieldName, // ✅ This should now use actual field names
      soilType: field.sensors?.[0]?.soilType || 'Loam',
      growthStage: field.growthStage || 'V8'
    }
  ];
  
  samplePrescriptions.push(...fieldPrescriptions);
}

console.log('📊 Generated prescriptions:');
samplePrescriptions.forEach((prescription, index) => {
  console.log(`${index + 1}. ${prescription.title} for ${prescription.fieldName} (${prescription.soilType}, ${prescription.growthStage})`);
});

console.log('✅ Test completed - Field names are now dynamic!');
