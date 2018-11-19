<!--
A large, multi-digit passcode input
-->

<template lang='pug'>

.passcode.form-wrapper
	//- The list of inputs
	.form-field-passcode(v-for='i in digits' :key='i')
		input.tile(
			ref='inputs'
			type='text'
			placeholder='–'
			maxlength='1'
			:tabindex='i'
			v-model='nums[i - 1]'
			@input='onChange(i)')

	//- Element that get written to
	slot

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =

	props:

		# How many digits to display
		digits:
			type: Number
			default: 6

	data: ->

		# Users choices
		nums: []

	# Capture hidden reference on mount
	mounted: -> @$hidden = @$el.querySelector 'input[type="hidden"]'

	computed:

		# Assemble the users choices into a string
		passcode: -> @nums.join ''

	watch:

		# Update the input when the passcode changes
		passcode: -> @$hidden?.value = @passcode

	methods:

		# Switch to next tab. Refs is 0-indexed while i is 1-indexed
		onChange: (i) ->
			return unless @nums[i-1] # Don't advance if we're deleting
			if i < @digits
			then @$refs.inputs[i].select()
			else @$refs.inputs[i - 1].blur()


</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>

// Override some form-wrapper stuff
.passcode
	flex-flow row nowrap
	padding-top 0
	margin 0 auto
	display flex

//Inputs
.form-field-passcode
	margin-right rem(36px)
	@media (max-width mobile)
		margin-right rem(10px)
	&:last-child
		margin-right 0

	// The actual input fields
	input
		text-align center
		max-width rem(86px)

		// Typography
		font-size 30px

		// Placeholder dash
		&::placeholder
			transition opacity .2s

		// On focus, hide the placeholder
		&:focus::placeholder
			opacity 0


</style>
