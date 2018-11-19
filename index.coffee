# Polyfills and global plugins
require('core-js/fn/promise')

# Import base styles
require './src/styles/index.styl'

# Import view files that will get transpiled to HTML
require './src/pages/index.pug'
require './src/pages/enroll.pug'
require './src/pages/convert.pug'
require './src/pages/something-different.pug'
require './src/pages/spfview-login-API.pug'
require './src/pages/loading-page.pug'
require './src/pages/loading-page-congrats.pug'
require './src/pages/login.pug'
require './src/pages/register.pug'
require './src/pages/create-account-whoops.pug'
require './src/pages/create-account.pug'
require './src/pages/security-questions.pug'
require './src/pages/security-setup.pug'
require './src/pages/forgot-password.pug'
require './src/pages/forgot-password-passcode.pug'

# Create Vue
Vue = require('vue')

# Install Vue plugins
Vue.use require('vee-validate'), classes: true
Vue.use require('vue-the-mask').default

# Shared components
Vue.component 'more-info', require './src/js/more-info'
Vue.component 'select-dropdown', require './src/js/select-dropdown'
Vue.component 'whoops-modal', require './src/js/whoops-modal'
Vue.component 'login-slider', require './src/js/login-slider'
Vue.component 'countdown', require './src/js/countdown'
Vue.component 'passcode', require './src/js/passcode'
Vue.component 'validating-form', require './src/js/validating-form'
Vue.component 'validating-input', require './src/js/validating-input'
Vue.component 'toggleable-password', require './src/js/toggleable-password'

# Boot root component
new Vue el: '#app'
