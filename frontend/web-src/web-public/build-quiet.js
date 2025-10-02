// Quiet build script that suppresses warnings
const { execSync } = require('child_process');

console.log('🔨 Building with suppressed warnings...');

try {
  // Run the build and filter out the warnings
  const result = execSync('npm run build', { 
    encoding: 'utf8',
    stdio: 'pipe'
  });
  
  // Filter out the warning lines
  const lines = result.split('\n');
  const filteredLines = lines.filter(line => 
    !line.includes('Module level directives cause errors when bundled') &&
    !line.includes('"use client"') &&
    !line.includes('was ignored')
  );
  
  console.log(filteredLines.join('\n'));
  console.log('\n✅ Build completed successfully!');
  
} catch (error) {
  console.error('❌ Build failed:', error.message);
  process.exit(1);
}
