<template lang='pug'>

.login-slider

	//- Insert slides
	slot

	.slide-nav(v-if='slides.length > 1'): a.tab(
		v-for='i in slides.length'
		:key='i'
		:class='{ active: i == page }'
		@click='page = i') {{ i }}

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =

	props:
		message: String

	data:->
		page: null
		slides: [] # Will contain vnodes
		pages: null

	mounted: -> @$nextTick ->
		return unless @$slots.default

		# Get just the children that are slides
		@slides = @$slots.default.filter (vnode) ->
			vnode.data?.staticClass == 'slide'

		# Trigger the intial page
		@page = 1

	watch:

		# Set the page
		page: (now, old) ->
			@slides[now - 1].elm.classList.add 'active'
			@slides[old - 1].elm.classList.remove 'active' if old

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>

.login-slider

	// An individual slide
	.slide
		background-position center center
		background-size cover
		background-repeat no-repeat
		height 100%
		position absolute
		width 100%

		// Needed for IE to prevent pushing the area too wide
		overflow hidden
		&:before
			content ''
			position absolute
			top 0
			right 0
			bottom 0
			left 0
			background-image linear-gradient(to bottom, rgba(0, 0, 0, 0), #000000)//-Bottom fade

		// Toggle between active pages
		transition opacity .7s
		opacity 0
		&.active
			opacity 1

	// Pagination
	.slide-nav
		center-align(horizontal)
		bottom 0
		z-index 4
		margin-bottom rem(50px)
		a
			margin 0 auto
			padding 0 20px
			padding-bottom rem(7px)
			font regular, 16px, white
			display inline-block
			&:hover
				opacity .4
				transition opacity .2s

		a.active //- underlined for active slide
			line(40px, white, bottom, 2px)

	// The copy content
	.content
		width 80%
		margin 0 auto
		position absolute
		bottom 15% //Eyeballed
		text-align center
		left 50%
		transform translateX(-50%)

		h2
			font extra-bold, 40px, white
			margin-bottom rem(27px)

		p
			font regular, 18px, white
			line-height 1.94
</style>
