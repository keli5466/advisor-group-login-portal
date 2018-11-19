<!--
Countdown timer
-->

<template lang='pug'>

.countdown-timer
	span Time Remaining: {{ display }}

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
format = require 'date-fns/format'
module.exports =

	props:
		expires: Number # The expiration time as a unix timestmap in seconds

	# Seed with current time
	data: -> now: new Date

	created: -> @timer = setInterval @update, 1000
	detroyed: -> clearInterval @timer

	computed:

		# The displayed time
		display: -> format @diff, 'mm:ss'

		# The difference between now and expiration, in seconds
		diff: -> @expiresDate - @now

		# Get expiration date object
		expiresDate: -> new Date @expires * 1000

	methods:

		# Update the current time
		update: -> @now = new Date;

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<style lang='stylus'>

.countdown-timer
	padding-top 40px
	margin 0 auto
	span
		font regular,18px, white
		line-height 3
		display inline-block
		height rem(56px)
		&.time//-make time bolder
			font-weight 700

	&:after//Background shape
		background-color primary-blue
		box-shadow primary-box-shadow
		transform skew(-20deg) translateX(-50%)
		position absolute
		left 50%
		z-index -2
		content ""
		height rem(56px)
		width rem(275px)

</style>
