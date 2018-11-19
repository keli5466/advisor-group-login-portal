###
Close when clicking outside
###
clickOutside = require 'click-outside'
module.exports =

	watch:

		# Close when clicking outside
		open: ->
			if @open
			then @offClickOutside = clickOutside @$refs.clickOutside, => @open = false
			else @offClickOutside?()
