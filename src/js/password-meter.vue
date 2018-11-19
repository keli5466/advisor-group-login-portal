<!--
Show password quality progress
-->

<template lang='pug'>

.password-meter: .step(
	v-for='i in 4'
	:class='stepClass(i)')

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
filter = require 'lodash/filter'
module.exports =

	# Get parent's validation state
	inject: ['$validator']

	computed:

		# Get the current progress
		progress: ->

			# If there is an error, parse JSON in an HTML comment in the password
			# message to get where the failures are
			# https://regex101.com/r/31qB9B/1
			if msg = @errors.firstByRule 'password', 'password'
				checks = JSON.parse msg.match(/<!-- (.*) -->/)[1]
				filter(checks, (val) -> !!val).length

			# If valid, treat as complete
			else if @fields.password?.valid then 4

			# Else treat as empty/untouched
			else 0

	methods:

		# Determine the class to apply to a step
		stepClass: (i) -> switch
			when @progress == 4 then 'complete'
			when @progress >= i then 'ok'

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>

.password-meter
	display inline-flex
	position absolute
	right 30px
	top 50%
	transform translateY(-50%)



	// Make a progress step
	.step
		rectangle rem(40px), rem(4px), #e4e6e7
		@media (max-width mobile)
			rectangle rem(30px), rem(3px), #e4e6e7
		&:not(:first-child)
			margin-left rem(8px)

		// This step is cleared
		transition background .2s ease-in-out
		&.ok
			background validate-yellow
		&.complete
			background #16d02d

</style>
