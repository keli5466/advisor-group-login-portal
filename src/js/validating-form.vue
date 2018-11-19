<!--
Wrap a form element with some behavior to prevent submit until it's validated
-->

<script lang='coffee'>
axios = require 'axios'
find = require 'lodash/find'
module.exports =

	components:
		'password-meter': require './password-meter'

	data: ->
		validatedForSubmit: false
		submitting: false
		terms: false
		radiobutton: null

	created: ->
		@updateDictionary()
		@addUniqueValidator()
		@addPasswordValidator()
		@addMaskValidator()

	# Validate immediately, to set the button state
	mounted: -> @$validator.validateAll()

	methods:

		# Add unique error messages to the validator dictionary
		updateDictionary: -> @$validator.localize 'en',
			attributes:
				password_confirmation: 'password'
				phone: 'phone number'
				account_number: 'account number'
			custom:
				username: unique: 'This username is already taken. If you are already
				registered, <a href="/login" style="color:white; text-decoration: underline;"><b>Login</b></a>.<br>
				<br>
				If you are using a shared email address, you must enter a unique username.'
				phone: min: 'You must enter a complete phone number.'
				account_number: min: 'You must enter a complete account number.'

		# Add the username validator
		addUniqueValidator: -> @$validator.extend 'unique',
			getMessage: (field) -> "The #{field} is not unique."
			validate: (value, args) ->

				# Add instructions error message
				return console.error 'You must supply a GET endpoint to the unique
					validator.  This URL will be requested with the entered value to
					validate unqiueness. The format of the URL is:
					"https://domain.com/path?value=%s".  The server should respond
					with a 200 HTTP code if the value is unique and 400 if the
					value is already in use.' unless args.length

				# Return promise that, on a 200 HTTP respone returns valid
				url = args[0].replace '%s', value
				axios.get url
				.then -> true
				.catch -> false

		# Add the password validator
		addPasswordValidator: -> @$validator.extend 'password',

			# Make a message showing which requirements are failing.  Also, include
			# a JSON representation of the checks that can be parsed by the
			# password-meter component.
			getMessage: (field, args, checks) ->
				"<!-- #{JSON.stringify(checks)} -->
				Your password must meet the following requirements:

				<ul class='errorlist'>
					<li class='#{if checks.length then 'ok' else 'fail'}'>
						Be at least 8 characters long
					</li>
					<li class='#{if checks.letter then 'ok' else 'fail'}'>
						Contain at least 1 letter
					</li>
					<li class='#{if checks.number then 'ok' else 'fail'}'>
						Contain at least 1 number
					</li>
					<li class='#{if checks.symbol then 'ok' else 'fail'}'>
						Contain at least 1 special character
					</li>
				</ul>"

			# Check the password for a number of properties
			validate: (value) ->
				checks =
					length: !!(value.length >= 8)      # >= 8 characters
					letter: !!value.match /[a-z]/i     # Has letter
					number: !!value.match /[0-9]/      # Has number
					symbol: !!value.match /[^a-z0-9]/i # Has symbol
				valid: find(checks, (val) -> val == false) == undefined
				data: checks

		# Require the full mask to be complete
		addMaskValidator: -> @$validator.extend 'mask',
			getMessage: (field) -> "You must complete the #{field}."
			validate: (value, [pattern]) -> value.length == pattern.length

		# Check for validation errors before allowing submitting
		onSubmit: (e) ->
			if @validatedForSubmit then @submitting = true
			else
				e.preventDefault()
				@$validator.validateAll().then (valid) => if valid
					@validatedForSubmit = true
					e.target.submit()

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>

//Terms and Conditions Check Box
#terms::-ms-clear
	display none
#terms::-ms-check
	border none
	font icon, 20px, primary-blue
	content icon-check !important

#terms
	width 20px
	height 20px
	border-radius 6px
	border none !important
	margin-right 5px
	font icon, 20px, primary-blue
	&:after
		opacity 0
		content icon-check !important
		transition opacity .2s ease-in-out
	&.checked
		background-color transparent
		&:after
			opacity 1 !important
			content icon-check !important
	&:focus
		border none !important

</style>
