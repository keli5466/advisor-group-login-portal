<!--
Wrap the vue-popper component with extra functionality to track open/close state
-->

<template lang='pug'>
.whoops-modal
	.whoops-modal-mask(v-if='showModal')
		.whoops-modal-wrapper
			.whoops-modal-container
				img.btn-close(@click="showModal = false" src="../styles/img/Close.svg")
				.header-content
					img.headline-img(src="../styles/img/whoops.svg")
					h1.headline Whoops!
					h2.sub-headline Looks like we got our wires crossed.
				.whoops-modal-body
					p Let us resolve this issue for you. <br>Please contact the eQuipt Client Portal customer service teams:
				.whoops-modal-footer
					h3 Contact Us
					.contact-footer
						a.action.phone(href="") (415) 555 - 5555
						a.action.email(href="") eQuipt@advisorgroup.com

</template>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->

<script lang='coffee'>
module.exports =
	data: ->
		showModal: true

</script>

<!-- ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– -->


<style lang='stylus'>
.whoops-modal
	.whoops-modal-mask
			position fixed
			z-index 9998
			top 0
			left 0
			width 100%
			height 100%
			background-color rgba(0, 0, 0, .75)
			display flex
			justify-items center
			align-items center
	.whoops-modal-wrapper
			border-radius 6px
			background-color white
			border solid 1px #f5f5f5
			max-height: rem(673px)
			@media (max-width mobile)
				max-height 90vh
			transition all .3s ease
			margin 0 auto
			max-width rem(736px)
			width 90%
	.whoops-modal-container
			padding rem(60px) 5%
			position relative

	//Close Button
	.btn-close
		position absolute
		right 5%
		top 5%

	//Middle Copy
	.whoops-modal-body
			margin rem(23px) auto 5vh
			p
				line-height 2

	.whoops-modal-header
		.headline-img
				max-width rem(86px)

	//Contact Footer
	.whoops-modal-footer
		h3
			font bold, 24px, dark-grey

		.contact-footer
			display flex
			flex-flow row wrap
			justify-content: center
			margin rem(30px) auto

			//Contact Icons
			.phone:before
					content icon-phone
			.email:before
					content icon-email

			.action
				font regular, 18px, dark-grey
				display flex
				padding 1.5% 10px
				@media (min-width tablet)
					line(1px , #979797, line, 39px)
					padding 0 40px
					&:first-child
						padding-left 0
					&:last-child
						padding-right 0
						&:after
							visibility hidden
				&:before //icon style
					font icon, 25px, primary-blue
					margin-right 12.5px


</style>
