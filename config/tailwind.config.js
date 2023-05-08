const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      minWidth: {
        '6': '6em',
        'custom45': '45rem',
        'custom35': '35rem',
        'custom25': '25rem',
      },
      width: {
        'custom20': '20rem',
        'custom15': '15rem',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
