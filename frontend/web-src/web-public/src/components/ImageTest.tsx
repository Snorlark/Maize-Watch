import React from 'react';

const ImageTest: React.FC = () => {
  return (
    <div style={{ padding: '20px', border: '2px solid red', margin: '20px' }}>
      <h2>Image Test Component</h2>
      
      <div style={{ margin: '10px 0' }}>
        <h3>Direct path reference:</h3>
        <img 
          src="/images/logo.png" 
          alt="Logo" 
          style={{ border: '2px solid blue', maxWidth: '200px' }}
          onLoad={() => console.log('Logo loaded successfully')}
          onError={(e) => console.error('Logo failed to load:', e)}
        />
      </div>
      
      <div style={{ margin: '10px 0' }}>
        <h3>Background image:</h3>
        <div 
          style={{
            backgroundImage: 'url(/images/background.png)',
            width: '300px',
            height: '200px',
            border: '2px solid green',
            backgroundSize: 'cover'
          }}
        />
      </div>
      
      <div style={{ margin: '10px 0' }}>
        <h3>Small logo:</h3>
        <img 
          src="/images/smalllogo.png" 
          alt="Small Logo" 
          style={{ border: '2px solid purple', maxWidth: '100px' }}
          onLoad={() => console.log('Small logo loaded successfully')}
          onError={(e) => console.error('Small logo failed to load:', e)}
        />
      </div>
    </div>
  );
};

export default ImageTest;
