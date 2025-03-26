module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'available': '#E8FFF3',
        'maintenance': '#FFF2F2',
        'booking': '#F5F8FF',
      },
    },
  },
  plugins: [],
} 