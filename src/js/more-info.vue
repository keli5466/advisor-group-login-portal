<!--
Wrap the vue-popper component with extra functionality to track open/close state
-->

<template lang='pug'>

span
	//- The popper
	transition(name='fade')
		.tool-tip(
			v-show='open'
			ref='clickOutside'
			:class='placement'): slot

	//- Text links
	a(
		v-if='!!label'
		@click= 'open = !open'
		:class='{ open: open }') {{ label }}

	//- Icon links
	.more-info(v-else
		@click= 'open = !open'
		:class='{ open: open }')

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =

	mixins: [
		require './mixins/close-on-click-outside'
	]

	props:
		label: String
		placement:
			type: String
			default: 'right'

	data: -> open: false

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>
.more-info-tool-tip
	span
		position relative

.more-info
	display inline-block
	// Add the icon
	font icon, 20px, light-grey
	&:after
		content icon-Info-Default
	// As an example
	&.open
		position relative
		&:before
			content icon-Info-Active-path1
			color primary-blue
			z-index -2
			position absolute
		&:after
			content icon-Info-Active-path2
			color white


.tool-tip
	font regular, 16px, white
	letter-spacing 0.5px
	box-shadow 8px 9px 45px 0 rgba(25, 25, 38, 0.3)
	text-align left
	position absolute
	z-index 2000
	padding rem(25px) rem(20px) rem(25px) rem(35px)
	margin-left popupwidth + 5px
	background primary-blue
	//-arrow
	&:after
		border-width popupwidth
		border-style solid
		content ''
		position absolute
	//bottom placement
	&.bottom
		top 120%
		width 70vw
		margin-left 0
		text-align center
		max-width rem(664px)
		margin-top rem(10px)
		center-align(horizontal)
		&:after
			center-align(horizontal)
			bottom 100%
			border-color primary-blue transparent
			border-top-width 0
		@media (max-width mobile)
			width 90vw
			max-width rem(400px)
	//right placement
	&.right
		@media (min-width desktop)
			left 100%
			width 18vw
			max-width rem(310px)
			center-align(vertical)
			&:after
				left 50%
				border-color transparent primary-blue transparent
				top 50%
				transform translateY(-50%)
				left -(popupwidth)
				border-left-width 0


		@media (max-width tablet-landscape)
			bottom 120%
			width rem(310px)
			margin-bottom rem(10px)
			right 0
			&:after
				position absolute
				right 0
				top 100%
				border-color primary-blue transparent
				border-bottom-width 0
	//right placement that move to bottom for smaller screens
	&.right-bottom
		@media (min-width desktop)
			margin-left popupwidth + 5px
			left 100%
			width 30vw
			max-width rem(310px)
			center-align(vertical)
			&:after
				left 50%
				border-color transparent primary-blue transparent
				top 50%
				transform translateY(-50%)
				left -(popupwidth)
				border-left-width 0

		@media (max-width tablet-landscape)
			bottom 130%
			width rem(310px)
			margin 0
			text-align center
			center-align(horizontal)
			&:after
				center-align(horizontal)
				bottom -10px
				border-color primary-blue transparent
				border-bottom-width 0

</style>
