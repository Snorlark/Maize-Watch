/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Montserrat', 'sans-serif'],
      },
      colors: {
        'custom-green': '#DFE8D1',
        'dgreen': 'var(--color-dgreen)',
        'lgreen': 'var(--color-lgreen)',
      },
    },
  },
  plugins: [],
}
