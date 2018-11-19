<!--
Make the password field toggleable
-->

<template lang='pug'>

.toggleable-password
	slot
	span.show-password(@click='show = !show' :class = "{ flip : show }")

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =

	data: -> show: false

	# Find the password
	mounted: -> @$password = @$el.querySelector 'input[type="password"]'

	# Switch the type of the form
	watch: show: ->
		if @show
		then @$password.type = 'text'
		else @$password.type = 'password'

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>


.show-password
	button()
	display inline-block
	// Add the icon
	center-align(vertical)
	right 5%
	z-index 3
	font icon, 20px, primary-blue
	opacity 0.6
	&:after
		content icon-eye
	transform translate(5px, -50%)
	transition opacity .3s, transform .3s ease-out
	&.flip
		color dark-grey
		transition color 300ms ease
	&:hover
		opacity 1

</style>
