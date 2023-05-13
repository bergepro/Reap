module.exports = {
  theme: {
    extend: {
      colors: {
        'tastyWhite': '#F4EDE3',
        'cream': '#F0E7DB',
      },
      minWidth: {
        '6': '6em',
        'custom50': '50rem',
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
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ]
}
