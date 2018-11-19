<!--
The security-question drop down for selecting a question
-->

<template lang='pug'>


.select-question(:class='{ populated: !!choice, touched: touched }')

	//- The slotted hidden input
	slot

	//- The button that launches the menu
	a.btn-select-question(@click='open = !open' :class="{ active: open }")
		| {{ choice ? options[choice] : 'Choose a question...' }}

	//- The menu
	transition(name='fade')
		ul.select-question-dropdown(v-show='open' ref='clickOutside')
			.select-question-option(
				v-for='label,value of options'
				@click='onClick(value)')
				| {{ label}}

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =

	mixins: [
		require './mixins/close-on-click-outside'
	]

	# Take in the list of options
	props: options: Object

	data: ->
		choice: ''
		open: false
		touched: false

	# Capture hidden reference on mount
	mounted: -> @$hidden = @$el.querySelector 'input[type="hidden"]'

	watch:

		# Mirror user's choice to the slotted hidden field
		choice: ->
			if @$hidden
				@$hidden.value = @choice
				@$hidden.dispatchEvent new Event 'input' # validating-input uses this

		# Store that the input was touched
		open: ->
			@touched = true if @open

			# Tell validating input about focus state.  Apparently you can't send
			# events through a slot
			# https://github.com/vuejs/vue/issues/4332#issuecomment-263444492
			@$parent.focused = @open

	methods:

		# Capture the users selection
		onClick: (val) ->
				@choice = val
				@open = false

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>

.select-question
	position: relative

	ul.select-question-dropdown
		margin 0
		padding 0
		position absolute
		top 96%
		border none
		width 100%
		z-index 2
		border-top-width 0px
		border solid #0000001f 2px
		border-radius 6px
		background-color #ffffff
		box-shadow: 0 33px 50px 0 rgba(65, 80, 87, 0.25)

		.select-question-option
			border none
			text-align left
			display flex
			align-items center
			box-shadow none
			padding 10px 0 10px form-input-padding
			background white
			width 100%
			font bold, 16px, dark-grey

			&:hover
				opacity: 0.7
				transition opacity 200ms ease

// The buutton
.btn-select-question
	font regular, 16px, light-grey
	position relative
	box-shadow primary-box-shadow
	margin-bottom rem(32px)
	text-align left
	height 62px
	background white
	border-radius 6px
	border solid #0000001f 2px
	padding-left form-input-padding
	display flex
	align-items center
	box-shadow none

	&:before
		content icon-arrow-down-b
		font icon, 10px, primary-blue
		center-align(vertical)
		transition all 300ms ease
		right form-input-padding
	&.active
		&:before
			transform rotateZ(180deg)
			transform-origin 50% 30%
	.populated &
		font-weight 700
	&:hover
		border: solid 2px #3ba6ef

	// Show error state
	.touched .invalid + &
		border 2px solid error-red
</style>
