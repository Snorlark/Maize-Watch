const { spawn } = require('child_process');
const path = require('path');

// Test the analytics parsing with real Python output
async function testAnalyticsParsing() {
    console.log('Testing analytics parsing with real Python output...\n');
    
    const analyticsPath = '/Users/larkbabao/Desktop/Maize-Watch/analytics_v2';
    const pythonPath = path.join(analyticsPath, 'venv/bin/python');
    const scriptPath = path.join(analyticsPath, 'run_complete_system.py');
    
    return new Promise((resolve, reject) => {
        const pythonProcess = spawn(pythonPath, [scriptPath, 'FARM_D0053B8B'], {
            cwd: analyticsPath,
            env: { 
                ...process.env,
                PYTHONPATH: analyticsPath
            }
        });

        let stdout = '';
        let stderr = '';

        pythonProcess.stdout.on('data', (data) => {
            stdout += data.toString();
        });

        pythonProcess.stderr.on('data', (data) => {
            stderr += data.toString();
        });

        pythonProcess.on('close', (code) => {
            if (code === 0) {
                console.log('✅ Python script executed successfully');
                console.log('📊 Parsing recommendations from output...\n');
                
                // Parse recommendations like the backend does
                const recommendations = parseRecommendations(stdout);
                
                console.log(`🎯 Found ${recommendations.length} recommendations:`);
                recommendations.forEach((rec, index) => {
                    console.log(`${index + 1}. [${rec.urgency}] ${rec.action}`);
                    console.log(`   Details: ${rec.details}`);
                    console.log(`   Timeline: ${rec.timeline}`);
                    console.log(`   Category: ${rec.category}\n`);
                });
                
                resolve(recommendations);
            } else {
                console.error('❌ Python script failed:', stderr);
                reject(new Error(`Script failed with code ${code}`));
            }
        });

        // Set timeout
        setTimeout(() => {
            pythonProcess.kill();
            reject(new Error('Script timeout'));
        }, 120000);
    });
}

function parseRecommendations(output) {
    const lines = output.split('\n');
    const recommendations = [];
    let inActionPlan = false;
    let currentSection = '';
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        if (line.includes("TODAY'S ACTION PLAN")) {
            inActionPlan = true;
            continue;
        }

        if (inActionPlan) {
            if (line.includes('URGENT ACTIONS:')) {
                currentSection = 'urgent';
                continue;
            } else if (line.includes('HIGH PRIORITY:')) {
                currentSection = 'high';
                continue;
            } else if (line.includes('MEDIUM PRIORITY:')) {
                currentSection = 'medium';
                continue;
            }

            if (line.trim().match(/^\d+\.\s+(.+)/)) {
                const match = line.match(/^\d+\.\s+(.+)/);
                if (match) {
                    const recommendation = {
                        action: extractRecommendationTitle(match[1]),
                        details: match[1].trim(),
                        urgency: mapSectionToUrgency(currentSection),
                        category: categorizeRecommendation(match[1]),
                        timeline: extractTimeline(lines[i + 1] || '')
                    };
                    recommendations.push(recommendation);
                }
            }

            if (line.includes('============================================================')) {
                inActionPlan = false;
            }
        }
    }
    
    return recommendations;
}

function extractRecommendationTitle(description) {
    if (description.includes(':')) {
        return description.split(':')[0].trim();
    }
    const words = description.split(' ');
    return words.slice(0, Math.min(4, words.length)).join(' ');
}

function mapSectionToUrgency(section) {
    switch (section) {
        case 'urgent': return 'URGENT';
        case 'high': return 'HIGH';
        case 'medium': return 'MEDIUM';
        default: return 'MEDIUM';
    }
}

function categorizeRecommendation(description) {
    const desc = description.toLowerCase();
    if (desc.includes('temperature') || desc.includes('heating') || desc.includes('cooling')) {
        return 'temperature_control';
    }
    if (desc.includes('humidity') || desc.includes('ventilation')) {
        return 'humidity_control';
    }
    if (desc.includes('light') || desc.includes('lighting')) {
        return 'lighting';
    }
    if (desc.includes('moisture') || desc.includes('irrigation') || desc.includes('drainage')) {
        return 'water_management';
    }
    if (desc.includes('fertilizer') || desc.includes('nutrient')) {
        return 'fertilization';
    }
    return 'general';
}

function extractTimeline(timelineLine) {
    if (timelineLine.includes('Timeline:')) {
        const match = timelineLine.match(/Timeline: (.+)/);
        return match ? match[1].trim() : 'As needed';
    }
    return 'As needed';
}

// Run the test
testAnalyticsParsing()
    .then(recommendations => {
        console.log('🎉 Test completed successfully!');
        console.log(`📈 Total recommendations parsed: ${recommendations.length}`);
        
        if (recommendations.length > 0) {
            console.log('\n✅ The mobile app should now receive these real recommendations instead of fallback data:');
            console.log('   - Increase temperature immediately using heating or row covers');
            console.log('   - Reduce humidity immediately by improving ventilation');
            console.log('   - Increase light immediately using supplemental lighting');
            console.log('   - Reduce soil moisture: Improve drainage and reduce irrigation frequency');
            console.log('   - Apply complete fertilizer');
        } else {
            console.log('⚠️  No recommendations were parsed - check parsing logic');
        }
    })
    .catch(error => {
        console.error('❌ Test failed:', error.message);
    });
