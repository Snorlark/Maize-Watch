/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./web-public/**/*.{html,js,jsx,ts,tsx}",
    "./web-admin/**/*.{html,js,jsx,ts,tsx}",
    "./shared/**/*.{html,js,jsx,ts,tsx}",
    "./index.html"
  ],
  theme: {
    extend: {
      // Your custom colors from the CSS theme
      colors: {
        // Main brand colors
        'maize-white': '#DFE8D1',
        'maize-rwhite': '#FBFFF5', 
        'maize-lgreen': '#72AB50',
        'maize-llgreen': '#a4dd83',
        'maize-green': '#45843A',
        'maize-dgreen': '#2C4C2B',
        'maize-red': '#c94343',
        'maize-lred': '#ebc6c6',
        'maize-bermuda': '#78dcca',
        
        // Semantic colors for different contexts
        primary: {
          50: '#f0f9f0',
          100: '#dcf2dc',
          200: '#a4dd83', // llgreen
          300: '#72AB50', // lgreen  
          400: '#45843A', // green
          500: '#45843A', // green (main)
          600: '#2C4C2B', // dgreen
          700: '#1f3a1f',
          800: '#152815',
          900: '#0f1f0f',
        },
        
        // Admin-specific colors
        admin: {
          bg: '#f8f9fa',
          sidebar: '#2C4C2B',
          text: '#333333',
          accent: '#45843A',
          border: '#e9ecef',
          danger: '#c94343',
          success: '#72AB50',
        },
        
        // Public site colors  
        public: {
          bg: '#FBFFF5',
          text: '#2C4C2B',
          accent: '#45843A',
          hover: '#72AB50',
        }
      },
      
      // Custom spacing for your design
      spacing: {
        '18': '4.5rem',
        '75': '18.75rem',
        '100': '25rem',
        '180': '45rem',
        '197': '49.25rem',
        '250': '62.5rem',
      },
      
      // Custom font sizes
      fontSize: {
        'xxs': '0.625rem',
        '2.5xl': '1.75rem',
      },
      
      // Custom border radius
      borderRadius: {
        'xl': '0.75rem',
        '2xl': '1rem',
        '3xl': '1.5rem',
        '31': '31px', // Your custom radius
      },
      
      // Custom shadows for different applications
      boxShadow: {
        'admin': '0 2px 10px rgba(0, 0, 0, 0.1)',
        'public': '0 4px 20px rgba(44, 76, 43, 0.1)',
        'public-hover': '0 8px 30px rgba(44, 76, 43, 0.15)',
      },
      
      // Animation customizations
      animation: {
        'bounce-slow': 'bounce 2s infinite',
        'fade-in': 'fadeIn 0.5s ease-in-out',
      },
      
      // Custom keyframes
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        }
      },
      
      // Custom font families
      fontFamily: {
        'montserrat': ['Montserrat', 'system-ui', 'sans-serif'],
      },
      
      // Custom transitions
      transitionDuration: {
        '250': '250ms',
        '350': '350ms',
      }
    },
  },
  plugins: [
    // Add any plugins you need
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
  ],
  
  // Different purge strategies for production
  purge: {
    enabled: process.env.NODE_ENV === 'production',
    content: [
      "./web-public/**/*.{html,js,jsx,ts,tsx}",
      "./web-admin/**/*.{html,js,jsx,ts,tsx}",
      "./shared/**/*.{html,js,jsx,ts,tsx}",
    ],
    options: {
      safelist: [
        // Preserve dynamic classes that might be missed
        'bg-maize-green',
        'text-maize-white',
        'hover:bg-maize-lgreen',
        // Add other dynamic classes you use
      ]
    }
  }
}