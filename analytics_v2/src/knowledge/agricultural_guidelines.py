#!/usr/bin/env python3
"""
Agricultural Guidelines and Best Practices
Based on Department of Agriculture Philippines (DA) and International Standards
"""

import json
from typing import Dict, List, Optional
from datetime import datetime, timedelta

class AgriculturalGuidelines:
    """Comprehensive agricultural knowledge base for corn farming in the Philippines"""
    
    def __init__(self):
        """Initialize with DA Philippines guidelines and best practices"""
        self.guidelines = self._load_guidelines()
        
    def _load_guidelines(self) -> Dict:
        """Load comprehensive agricultural guidelines"""
        return {
            "growth_stages": {
                "VE": {
                    "name": "Emergence",
                    "duration_days": 7,
                    "critical_requirements": {
                        "soil_temperature": {"min": 10, "optimal": [15, 25], "max": 30},
                        "soil_moisture": {"min": 60, "optimal": [70, 85], "max": 90},
                        "ph": {"min": 5.5, "optimal": [6.0, 7.0], "max": 7.5},
                        "light": {"min": 15000, "optimal": [20000, 30000], "max": 50000}
                    },
                    "management_practices": [
                        "Ensure proper seed depth (2-3 cm for heavy soils, 3-4 cm for light soils)",
                        "Maintain consistent soil moisture - avoid waterlogging",
                        "Protect from birds and rodents",
                        "Monitor for soil crusting that may prevent emergence",
                        "Apply pre-emergence herbicide if needed"
                    ],
                    "fertilizer_requirements": {
                        "starter_fertilizer": "NPK 14-14-14 at 2-3 bags/ha",
                        "application_method": "Band application 5 cm to the side and 5 cm below seed",
                        "timing": "At planting"
                    },
                    "pest_management": [
                        "Monitor for cutworms and armyworms",
                        "Check for seed corn maggot damage",
                        "Apply insecticide if pest pressure is high"
                    ],
                    "disease_prevention": [
                        "Use treated seeds",
                        "Avoid planting in waterlogged areas",
                        "Maintain proper drainage"
                    ]
                },
                "V2-V4": {
                    "name": "Early Vegetative (2-4 leaves)",
                    "duration_days": 14,
                    "critical_requirements": {
                        "soil_temperature": {"min": 15, "optimal": [20, 28], "max": 32},
                        "soil_moisture": {"min": 60, "optimal": [70, 80], "max": 85},
                        "ph": {"min": 5.5, "optimal": [6.0, 7.0], "max": 7.5},
                        "light": {"min": 20000, "optimal": [30000, 45000], "max": 60000}
                    },
                    "management_practices": [
                        "Begin side-dressing with nitrogen fertilizer",
                        "Thin plants to recommended spacing (20-25 cm between plants)",
                        "Control weeds through cultivation or herbicide application",
                        "Monitor plant population density",
                        "Check for nutrient deficiencies"
                    ],
                    "fertilizer_requirements": {
                        "nitrogen": "Urea 46-0-0 at 1-2 bags/ha",
                        "phosphorus": "TSP 0-46-0 at 1 bag/ha if soil test shows deficiency",
                        "potassium": "Muriate of Potash 0-0-60 at 1 bag/ha if needed",
                        "application_method": "Side-dress 10-15 cm from plant base",
                        "timing": "When plants have 3-4 leaves"
                    },
                    "pest_management": [
                        "Monitor for fall armyworm, corn earworm, and corn borer",
                        "Check for aphids and leafhoppers",
                        "Apply appropriate insecticide if threshold is reached",
                        "Use pheromone traps for monitoring"
                    ],
                    "disease_prevention": [
                        "Monitor for downy mildew and rust",
                        "Apply fungicide preventively if weather conditions favor disease",
                        "Remove infected plants immediately"
                    ]
                },
                "V5-VT": {
                    "name": "Mid Vegetative (5-8 leaves to Tasseling)",
                    "duration_days": 21,
                    "critical_requirements": {
                        "soil_temperature": {"min": 18, "optimal": [22, 30], "max": 35},
                        "soil_moisture": {"min": 65, "optimal": [75, 85], "max": 90},
                        "ph": {"min": 5.5, "optimal": [6.0, 7.0], "max": 7.5},
                        "light": {"min": 30000, "optimal": [40000, 55000], "max": 70000}
                    },
                    "management_practices": [
                        "Complete side-dressing applications",
                        "Monitor for lodging and provide support if needed",
                        "Ensure adequate water supply for rapid growth",
                        "Control weeds to reduce competition",
                        "Monitor plant height and leaf development"
                    ],
                    "fertilizer_requirements": {
                        "nitrogen": "Urea 46-0-0 at 2-3 bags/ha",
                        "complete_fertilizer": "NPK 16-16-16 at 2 bags/ha",
                        "application_method": "Side-dress or broadcast",
                        "timing": "Before tasseling (V8-VT stage)"
                    },
                    "pest_management": [
                        "Intensive monitoring for corn borer and armyworm",
                        "Check for spider mites and aphids",
                        "Apply Bt (Bacillus thuringiensis) for caterpillar control",
                        "Use integrated pest management approach"
                    ],
                    "disease_prevention": [
                        "Monitor for leaf blight and rust",
                        "Apply fungicide if disease pressure is high",
                        "Ensure good air circulation"
                    ]
                },
                "R1-R3": {
                    "name": "Reproductive (Silking to Early Grain Fill)",
                    "duration_days": 14,
                    "critical_requirements": {
                        "soil_temperature": {"min": 20, "optimal": [24, 32], "max": 38},
                        "soil_moisture": {"min": 75, "optimal": [80, 90], "max": 95},
                        "ph": {"min": 5.5, "optimal": [6.0, 7.0], "max": 7.5},
                        "light": {"min": 40000, "optimal": [50000, 65000], "max": 80000}
                    },
                    "management_practices": [
                        "CRITICAL: Maintain consistent soil moisture - this is the most critical period",
                        "Avoid water stress during pollination",
                        "Monitor kernel development",
                        "Check for ear development and pollination success",
                        "Minimize field traffic to avoid root damage"
                    ],
                    "fertilizer_requirements": {
                        "nitrogen": "Final nitrogen application if not done earlier",
                        "potassium": "Potassium sulfate for grain filling",
                        "application_method": "Foliar application if needed",
                        "timing": "Early reproductive stage"
                    },
                    "pest_management": [
                        "Monitor for corn earworm and corn borer in ears",
                        "Check for aphids and thrips",
                        "Apply appropriate insecticide for ear protection",
                        "Use biological control methods when possible"
                    ],
                    "disease_prevention": [
                        "Monitor for ear rot and stalk rot",
                        "Apply fungicide for ear protection",
                        "Ensure proper drainage to prevent root diseases"
                    ]
                },
                "R4-R5": {
                    "name": "Maturing (Dough to Dent Stage)",
                    "duration_days": 21,
                    "critical_requirements": {
                        "soil_temperature": {"min": 18, "optimal": [22, 30], "max": 35},
                        "soil_moisture": {"min": 60, "optimal": [70, 80], "max": 85},
                        "ph": {"min": 5.5, "optimal": [6.0, 7.0], "max": 7.5},
                        "light": {"min": 35000, "optimal": [45000, 60000], "max": 75000}
                    },
                    "management_practices": [
                        "Gradually reduce irrigation as kernels mature",
                        "Monitor kernel moisture content",
                        "Check for lodging and provide support if needed",
                        "Prepare for harvest planning",
                        "Monitor for premature dry-down"
                    ],
                    "fertilizer_requirements": {
                        "nitrogen": "No additional nitrogen needed",
                        "potassium": "Foliar potassium if deficiency symptoms appear",
                        "application_method": "Foliar spray",
                        "timing": "Only if deficiency symptoms are visible"
                    },
                    "pest_management": [
                        "Monitor for storage pests",
                        "Check for bird damage",
                        "Apply bird repellent if needed",
                        "Monitor for late-season insects"
                    ],
                    "disease_prevention": [
                        "Monitor for stalk rot and ear rot",
                        "Ensure good air circulation",
                        "Remove infected plants to prevent spread"
                    ]
                },
                "R6": {
                    "name": "Maturity and Harvest",
                    "duration_days": 14,
                    "critical_requirements": {
                        "soil_temperature": {"min": 15, "optimal": [20, 28], "max": 32},
                        "soil_moisture": {"min": 50, "optimal": [60, 70], "max": 80},
                        "ph": {"min": 5.5, "optimal": [6.0, 7.0], "max": 7.5},
                        "light": {"min": 30000, "optimal": [40000, 55000], "max": 70000}
                    },
                    "management_practices": [
                        "Stop irrigation 2-3 weeks before harvest",
                        "Monitor kernel moisture content (target: 20-25%)",
                        "Check for harvest readiness using black layer test",
                        "Prepare harvesting equipment",
                        "Plan post-harvest storage and handling"
                    ],
                    "harvest_guidelines": {
                        "moisture_content": "20-25% for optimal harvest",
                        "harvest_method": "Combine harvester or manual",
                        "timing": "When black layer forms at kernel base",
                        "storage": "Dry to 14% moisture for storage"
                    },
                    "post_harvest": [
                        "Dry corn to 14% moisture content",
                        "Store in clean, dry, well-ventilated area",
                        "Monitor for storage pests",
                        "Test for aflatoxin if conditions were favorable",
                        "Prepare field for next season"
                    ]
                }
            },
            "soil_management": {
                "soil_types": {
                    "sandy": {
                        "characteristics": "Low water holding capacity, fast drainage",
                        "management": [
                            "Increase organic matter content",
                            "Apply frequent light irrigation",
                            "Use mulch to conserve moisture",
                            "Apply fertilizer in split applications"
                        ],
                        "ph_adjustment": {
                            "lime_requirement": "2-4 tons/ha for pH 5.0-5.5",
                            "sulfur_requirement": "1-2 tons/ha for pH > 7.0"
                        }
                    },
                    "loam": {
                        "characteristics": "Ideal soil type, good water holding capacity",
                        "management": [
                            "Maintain organic matter at 2-3%",
                            "Practice crop rotation",
                            "Use cover crops",
                            "Apply balanced fertilization"
                        ],
                        "ph_adjustment": {
                            "lime_requirement": "1.5-3 tons/ha for pH 5.0-5.5",
                            "sulfur_requirement": "0.5-1 ton/ha for pH > 7.0"
                        }
                    },
                    "clay": {
                        "characteristics": "High water holding capacity, slow drainage",
                        "management": [
                            "Improve drainage with subsoiling",
                            "Add organic matter to improve structure",
                            "Avoid compaction",
                            "Use raised beds in wet areas"
                        ],
                        "ph_adjustment": {
                            "lime_requirement": "3-6 tons/ha for pH 5.0-5.5",
                            "sulfur_requirement": "1-3 tons/ha for pH > 7.0"
                        }
                    }
                },
                "ph_management": {
                    "optimal_range": [6.0, 7.0],
                    "lime_application": {
                        "timing": "3-6 months before planting",
                        "method": "Broadcast and incorporate",
                        "materials": ["Agricultural lime", "Dolomitic lime", "Quicklime"]
                    },
                    "sulfur_application": {
                        "timing": "2-3 months before planting",
                        "method": "Broadcast and incorporate",
                        "materials": ["Elemental sulfur", "Gypsum", "Aluminum sulfate"]
                    }
                }
            },
            "fertilizer_management": {
                "nutrient_requirements": {
                    "nitrogen": {
                        "total_requirement": "120-180 kg/ha",
                        "application_schedule": [
                            "30% at planting (starter)",
                            "40% at V4-V6 stage (side-dress)",
                            "30% at V8-VT stage (side-dress)"
                        ],
                        "sources": ["Urea 46-0-0", "Ammonium sulfate 21-0-0", "NPK 16-16-16"]
                    },
                    "phosphorus": {
                        "total_requirement": "60-90 kg/ha",
                        "application_schedule": [
                            "50% at planting",
                            "50% at V4-V6 stage"
                        ],
                        "sources": ["TSP 0-46-0", "DAP 18-46-0", "NPK 14-14-14"]
                    },
                    "potassium": {
                        "total_requirement": "80-120 kg/ha",
                        "application_schedule": [
                            "50% at planting",
                            "50% at V4-V6 stage"
                        ],
                        "sources": ["Muriate of Potash 0-0-60", "Sulfate of Potash 0-0-50"]
                    }
                },
                "micronutrients": {
                    "zinc": "5-10 kg/ha zinc sulfate",
                    "boron": "1-2 kg/ha borax",
                    "manganese": "5-10 kg/ha manganese sulfate",
                    "application_timing": "At planting or early vegetative stage"
                }
            },
            "irrigation_management": {
                "critical_periods": [
                    "Germination and emergence (0-10 days)",
                    "Tasseling and silking (R1-R2 stage)",
                    "Grain filling (R3-R5 stage)"
                ],
                "irrigation_scheduling": {
                    "vegetative_stage": "Every 3-5 days, 25-30 mm",
                    "reproductive_stage": "Every 2-3 days, 30-40 mm",
                    "grain_filling": "Every 3-4 days, 25-30 mm"
                },
                "water_quality": {
                    "ph": "6.0-8.0",
                    "ec": "< 1.5 dS/m",
                    "sodium": "< 3 meq/L",
                    "chloride": "< 10 meq/L"
                }
            },
            "pest_management": {
                "major_pests": {
                    "fall_armyworm": {
                        "damage": "Feeds on leaves and ears",
                        "control": [
                            "Use Bt (Bacillus thuringiensis)",
                            "Apply spinosad or chlorantraniliprole",
                            "Use pheromone traps for monitoring",
                            "Practice crop rotation"
                        ],
                        "threshold": "5% plants with damage"
                    },
                    "corn_borer": {
                        "damage": "Tunnels in stalks and ears",
                        "control": [
                            "Plant Bt corn varieties",
                            "Apply appropriate insecticides",
                            "Destroy crop residues",
                            "Use biological control"
                        ],
                        "threshold": "10% plants with damage"
                    },
                    "aphids": {
                        "damage": "Suck sap and transmit viruses",
                        "control": [
                            "Use beneficial insects",
                            "Apply neonicotinoids if needed",
                            "Avoid excessive nitrogen",
                            "Use resistant varieties"
                        ],
                        "threshold": "50% plants infested"
                    }
                },
                "integrated_pest_management": [
                    "Use resistant varieties",
                    "Practice crop rotation",
                    "Monitor pest populations",
                    "Use biological control",
                    "Apply pesticides only when necessary",
                    "Follow proper application timing"
                ]
            },
            "disease_management": {
                "major_diseases": {
                    "downy_mildew": {
                        "symptoms": "Yellow streaks on leaves, stunted growth",
                        "control": [
                            "Use resistant varieties",
                            "Apply fungicides preventively",
                            "Improve drainage",
                            "Practice crop rotation"
                        ],
                        "favorable_conditions": "High humidity, cool temperatures"
                    },
                    "rust": {
                        "symptoms": "Orange pustules on leaves",
                        "control": [
                            "Use resistant varieties",
                            "Apply fungicides",
                            "Remove infected debris",
                            "Improve air circulation"
                        ],
                        "favorable_conditions": "High humidity, moderate temperatures"
                    },
                    "ear_rot": {
                        "symptoms": "Moldy kernels, reduced quality",
                        "control": [
                            "Harvest at proper moisture",
                            "Dry quickly after harvest",
                            "Store at proper conditions",
                            "Test for aflatoxin"
                        ],
                        "favorable_conditions": "High humidity, warm temperatures"
                    }
                }
            },
            "harvest_management": {
                "harvest_timing": {
                    "maturity_indicators": [
                        "Black layer formation at kernel base",
                        "Kernel moisture content 20-25%",
                        "Leaves turn brown and dry",
                        "Ears droop downward"
                    ],
                    "optimal_moisture": "20-25% for harvest, 14% for storage"
                },
                "harvest_methods": {
                    "manual": {
                        "advantages": "Selective harvesting, lower cost",
                        "disadvantages": "Labor intensive, slower",
                        "suitable_for": "Small farms, high-value corn"
                    },
                    "mechanical": {
                        "advantages": "Fast, efficient, less labor",
                        "disadvantages": "Higher cost, less selective",
                        "suitable_for": "Large farms, commercial production"
                    }
                },
                "post_harvest": {
                    "drying": {
                        "target_moisture": "14%",
                        "methods": ["Sun drying", "Mechanical drying", "Natural air drying"],
                        "temperature": "Maximum 60°C for mechanical drying"
                    },
                    "storage": {
                        "conditions": "Clean, dry, well-ventilated",
                        "temperature": "Below 25°C",
                        "humidity": "Below 70%",
                        "pest_control": "Fumigation if necessary"
                    }
                }
            },
            "references": {
                "da_philippines": {
                    "source": "Department of Agriculture Philippines",
                    "publications": [
                        "Corn Production Guide",
                        "Integrated Pest Management for Corn",
                        "Soil Fertility Management",
                        "Post-Harvest Handling Guidelines"
                    ],
                    "website": "https://www.da.gov.ph"
                },
                "international_standards": {
                    "sources": [
                        "FAO (Food and Agriculture Organization)",
                        "IRRI (International Rice Research Institute)",
                        "CIMMYT (International Maize and Wheat Improvement Center)",
                        "USDA Agricultural Research Service"
                    ]
                },
                "local_research": {
                    "institutions": [
                        "Philippine Rice Research Institute (PhilRice)",
                        "University of the Philippines Los Baños (UPLB)",
                        "Central Luzon State University (CLSU)",
                        "Visayas State University (VSU)"
                    ]
                }
            }
        }
    
    def get_growth_stage_guidelines(self, stage: str) -> Dict:
        """Get comprehensive guidelines for a specific growth stage"""
        return self.guidelines["growth_stages"].get(stage, {})
    
    def get_soil_management_guidelines(self, soil_type: str) -> Dict:
        """Get soil management guidelines for specific soil type"""
        return self.guidelines["soil_management"]["soil_types"].get(soil_type, {})
    
    def get_fertilizer_recommendations(self, growth_stage: str, soil_type: str) -> Dict:
        """Get fertilizer recommendations based on growth stage and soil type"""
        stage_guidelines = self.get_growth_stage_guidelines(growth_stage)
        soil_guidelines = self.get_soil_management_guidelines(soil_type)
        
        return {
            "growth_stage": stage_guidelines.get("fertilizer_requirements", {}),
            "soil_specific": soil_guidelines.get("fertilizer_requirements", {}),
            "general_requirements": self.guidelines["fertilizer_management"]
        }
    
    def get_pest_management_plan(self, growth_stage: str) -> List[str]:
        """Get pest management plan for specific growth stage"""
        stage_guidelines = self.get_growth_stage_guidelines(growth_stage)
        return stage_guidelines.get("pest_management", [])
    
    def get_disease_prevention_plan(self, growth_stage: str) -> List[str]:
        """Get disease prevention plan for specific growth stage"""
        stage_guidelines = self.get_growth_stage_guidelines(growth_stage)
        return stage_guidelines.get("disease_prevention", [])
    
    def get_irrigation_guidelines(self, growth_stage: str) -> Dict:
        """Get irrigation guidelines for specific growth stage"""
        stage_guidelines = self.get_growth_stage_guidelines(growth_stage)
        return {
            "stage_specific": stage_guidelines.get("critical_requirements", {}),
            "general_guidelines": self.guidelines["irrigation_management"]
        }
    
    def get_harvest_guidelines(self) -> Dict:
        """Get comprehensive harvest guidelines"""
        return self.guidelines["harvest_management"]
    
    def get_references(self) -> Dict:
        """Get all reference sources"""
        return self.guidelines["references"]

# Global instance
agricultural_guidelines = AgriculturalGuidelines()
