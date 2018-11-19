<!--
Add supplemental fields around an input element
-->

<template lang='pug'>

.validating-input
	slot(@focus='onFocus' @blur='onBlur')
	span.input-verified(v-if='!disableVerified')
	transition(name='fade')
		.error-tooltip(
			v-if='!disablePopup && focused && name && errors.has(name)'
			v-html='message')

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =

	# Get parent's validation state
	inject: ['$validator']

	props:
		disablePopup: Boolean
		disableVerified: Boolean
	data: ->
		name: null
		focused: false

	# Helper to get the message to display
	computed: message: -> @errors.first @name

	# Get the name from the slotted input
	mounted: ->
		@$input = @$el.querySelector 'input'
		@name = @$input.getAttribute('name')
		@$input.addEventListener 'focus', @onFocus
		@$input.addEventListener 'blur', @onBlur

	destroyed: ->
			@$input.removeEventListener 'focus', @onFocus
			@$input.removeEventListener 'blur', @onBlur

	methods:

		# Toggle focus state
		onFocus: -> @focused = true
		onBlur: -> @focused = false

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>
//Needed for the password feild to match other inputs
.validating-input
	position relative
	input
		padding-right 10%
		&.invalid
			&.touched, &:focus
				border solid error-red 2px
			&:focus
				box-shadow input-box-shadow-size rgba(252, 21, 21, 0.1)
		&.valid ~ .input-verified
			opacity 1
			transform translate(0, -50%)

	// The little verified badge
	.input-verified
		display inline-block
		// Add the icon
		center-align(vertical)
		right 5%
		font icon, 20px, primary-blue
		&:after
			content icon-android-checkmark-circle
		// Only show when verified
		opacity 0
		transform translate(5px, -50%)
		transition opacity .3s, transform .3s ease-out

	// The error popup
	.error-tooltip
		box-shadow 8px 9px 45px 0 rgba(25, 25, 38, 0.3)
		font regular, 16px, white
		letter-spacing 0.5px
		text-align left
		position: absolute
		background error-red
		padding: rem(25px) rem(20px) rem(25px) rem(35px)
		z-index 2000

		@media (min-width desktop)
			left 100%
			max-width rem(310px)
			width 16vw
			center-align(vertical)
			margin-left popupwidth + 5px
			&:after
				position absolute
				left 50%
				content ''
				border-width popupwidth
				border-style solid
				border-color transparent error-red transparent
				top 50%
				transform translateY(-50%)
				left -(popupwidth)
				border-left-width 0


		@media (max-width tablet-landscape)
			position absolute
			width: 100%
			top 120%
			right 0
			margin-left popupwidth + 5px
			background error-red
			&:after
				position absolute
				right 0
				bottom 100%
				content ''
				border-width popupwidth
				border-style solid
				border-color error-red transparent
				border-top-width 0

		// Lists in errors
		> ul.errorlist
			padding 0
			margin-top rem(16px)
			li
				line-height 2
				letter-spacing 0.2px
				font regular, 12px, white
				position relative

				// Add Check Circle on Li
				&.ok
					&:before
						content icon-android-checkmark-circle
						font icon, 14px, white
						position absolute
						left rem(-20px)
						top 50%
						line-height 2
						transform translateY(-50%)

</style>
