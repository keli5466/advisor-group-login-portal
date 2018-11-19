###
This file exports the webpack configuration object.  It is designed to be
imported into the app's webpack.config.coffee where it can be hacked if changes
are needed.
###

# Dependencies
_ = require 'lodash'
AssetsPlugin = require 'assets-webpack-plugin'
autoprefixer = require 'autoprefixer'
Clean = require 'clean-webpack-plugin'
Dashboard = require 'webpack-dashboard/plugin'
ExtractText = require 'extract-text-webpack-plugin'
fs = require 'fs'
moment = require 'moment'
Notify = require 'webpack-notifier'
path = require 'path'
webpack = require 'webpack'

# ##############################################################################
# Environment
# ##############################################################################

# Vars concerned with the env
hmr = process.argv[1].includes 'webpack-dev-server'
minify = process.env.NODE_ENV == 'production'

# Get the port number after the `--port` flag, if it exists, to serve HMR assets
port = 8080 # webpack dev server default
port = process.argv[process.argv.indexOf('--port')+1] if '--port' in process.argv

# Autoprefixer config
# https://github.com/ai/browserslist#queries
autoprefixer = autoprefixer browsers: [
	'last 2 versions'
	'ie >= 9'
]

# ##############################################################################
# Defaults and overrides
# ##############################################################################

# Export a closure that receives options that will override the hardcoded
# configuration
module.exports = (options) ->

	# If options is a function, run it to get the options object, passing in
	# details infered from the environment that may be used to configure it
	if _.isFunction options
		options = options
			hmr: hmr
			minify: minify
			port: port
			autoprefixer: autoprefixer

	# Do a first merge to set the value of shared vars
	options = _.defaultsDeep options,
		context: path.resolve process.cwd(), 'resources/assets'
		output: path: path.resolve process.cwd(), 'public/dist'

	# Apply configuration as the defaults for the passed in options, allowing
	# anything to be overridden
	return _.defaultsDeep options,

	# ############################################################################
	# Entry and Output
	# ############################################################################

	# Set the dir to look for entry files
	context: null # Set in defaults

	# Build one bundle for public site and one for admin. If additional front end
	# entry points are added, consider using CommonsChunkPlugin to move shared
	# dependencies out.  This checks if the files actually exist before adding
	# them so that the build doesn't break if different.
	entry: ( ->
		defaults =
			app:   './boot.coffee'
			admin: './admin/app.coffee'
			error: './error.styl'
		_.pickBy defaults, (file, key) -> # Test if files exist
			fs.existsSync path.resolve options.context, file
	)()

	# Save the entry points to the public/dist directory.  And give any chunks
	# hashed names when minifying so they can be long term cashed.  The entry
	# JS doesn't need this as it gets unique URLs via PHP.
	output:
		path:          null # Set in defaults
		publicPath:    if hmr then 'http://localhost:'+port+'/dist/' else '/dist/'
		filename:      if minify then '[name].[hash:8].js' else '[name].js'
		chunkFilename: if minify then '[id].[hash:8].js' else '[id].js'

	# Configure what shows up in the terminal output
	stats:
		children:     false # Hides the "extract-text-webpack-plugin" messages
		assets:       true
		colors:       true
		version:      false
		hash:         false
		timings:      true
		chunks:       false
		chunkModules: false
		modules:      false # Just the outputted files

	# Generate source maps.  If using HMR, the sourcemap can be cheaper (less
	# CPU required) and should be inline.  Othwerise, generate external, full
	# sourcemaps.
	devtool: if hmr then 'inline-cheap-module-eval-source-map' else 'source-map'

	# Allow dev server to be on a different host than test domain
	# https://github.com/webpack/webpack-dev-server/issues/533
	devServer:
		hot: hmr
		quiet: true
		headers: 'Access-Control-Allow-Origin': '*'

	# Fix errors with node modules when building to a web target
	node:
		fs: 'empty'
		net: 'empty'

	# ############################################################################
	# Resolve - Where to find files
	# ############################################################################
	resolve:

		# Look for modules in the vendor directory as well as npm's directory.  The
		# vendor directory is used for third party modules that are committed to the
		# repo, like things that can't be installed via npm.  For example, Modernizr.
		modules: [
			options.context
			path.resolve options.context, 'workbench'
			path.resolve options.context, 'vendor'
			'node_modules'
		]

		# Use `main` before `modules` in package definitions so that we use the CJS
		# rather than the ES6 module spec which often requires doing something like:
		# require('vue').default.
		mainFields: ['main', 'modules']

		# Add coffee to the list of optional extensions
		extensions: ['.js', '.coffee', '.vue']

		# Aliases for common libraries
		alias:
			velocity: 'velocity-animate'
			underscore: 'lodash'
			'vue$': 'vue/dist/vue.common.js'

	# ############################################################################
	# Loaders - File transmogrifying
	# ############################################################################
	module: rules: [

		# Coffeescript #
		{ test: /\.coffee$/, use: 'coffee-loader' }

		# Pug #
		{ test: /\.(pug|jade)$/, use: 'pug-loader?doctype=html' }

		# Images #
		# If files are smaller than the limit, becomes a data-url.  Otherwise,
		# copies the files into dist and returns the hashed URL.  Also runs imagemin.
		{
			test: /\.(png|gif|jpe?g|svg)(\?\S*)?$/
			use: [
				{ # Make URLs to images
					loader: 'url-loader'
					options:
						limit: 10000
						name: 'img/[hash:8].[ext]'
				}
				{ # Minify images
					loader: 'img-loader'
					options:
						enabled: minify
						mozjpeg: progressive: true
				}
			]
		}

		# Fonts #
		# Not using the url-loader because serving multiple formats of a font would
		# mean inlining multiple formats that are unncessary for a given user.
		{
			test: /\.(eot|ttf|otf|woff|woff2)(\?\S*)?$/
			use: 'file-loader?name=fonts/[hash:8].[ext]'
		}

		# CSS #
		{
			test: /\.css$/
			use:
				if hmr
				then [
					{
						loader: 'style-loader'
						options: sourceMap: true
					}
					{
						loader: 'css-loader'
						options: sourceMap: true
					}
					{
						loader: 'postcss-loader'
						options:
							sourceMap: true
							plugins: (loader) -> [ autoprefixer ]
					}
				]
				else ExtractText.extract use: [
					{
						loader: 'css-loader'
						options:
							sourceMap: true
							minimize: minify
					}
					{
						loader: 'postcss-loader'
						options:
							sourceMap: true
							plugins: (loader) -> [ autoprefixer ]
					}
				]
		}

		# Stylus #
		# This also uses the ExtractText to generate a new CSS file, rather
		# than writing script tags to the DOM. This was required to get the CSS
		# sourcemaps exporting dependably. Note the "postcss" loader, that is
		# adding autoprefixer in.
		{
			test: /\.styl$/
			use:
				if hmr
				then [
					{
						loader: 'style-loader'
						options: sourceMap: true
					}
					{
						loader: 'css-loader'
						options: sourceMap: true
					}
					{
						loader: 'postcss-loader'
						options:
							sourceMap: true
							plugins: (loader) -> [ autoprefixer ]
					}
					{
						loader: 'stylus-loader'
						options:
							sourceMap: true
							preferPathResolver: 'webpack' # Faster
					}
					{
						loader: 'sass-resources-loader'
						options: resources: path.resolve options.context, 'definitions.styl'
					}
				]
				else ExtractText.extract use: [
					{
						loader: 'css-loader'
						options:
							sourceMap: true
							minimize: minify
					}
					{
						loader: 'postcss-loader'
						options:
							sourceMap: true
							plugins: (loader) -> [ autoprefixer ]
					}
					{
						loader: 'stylus-loader'
						options:
							sourceMap: true
							preferPathResolver: 'webpack' # Faster
					}
					{
						loader: 'sass-resources-loader'
						options: resources: path.resolve options.context, 'definitions.styl'
					}
				]
		}

		# jQuery #
		# This adds jquery to window globals so that it's useable from the console
		# but also so that it can be found by jQuery plugins, like Velocity. This
		# "test" syntax is used to find the file in node_modules, the "expose"
		# loader's examples ("require.resolve") don't work because node is looking
		# in the app node_modules.
		# { test: /jquery\.js$/, use: 'expose-loader?$!expose?jQuery' }

		# jQuery plugins #
		# Make sure jQuery is loaded before Velocity
		{
			test: /(velocity|redactor\/redactor)\.js$/,
			use: 'imports-loader?$=jquery'
		}

		# Vue #
		{
			test: /\.vue$/
			loader: 'vue-loader'
			options:

				# Export common JS friendly modules
				esModule: false

				# Passthrough autoprefixer rules:
				postcss: [ autoprefixer ]

				# Support extractking css CSS
				extractCSS: !hmr

				# Set the doctype to html so that boolean attributes work as expected
				# https://pugjs.org/language/attributes.html#boolean-attributes
				# https://github.com/vuejs/vue-loader/issues/55#issuecomment-272837311
				template: doctype: 'html'

				# Support the css precompilers being explicitly defined.  This should be
				# identical to the webpack loaders EXCEPT with postcss removed, because
				# the Vue loader is doing that automatically.  Also, the prepending needs
				# to be explicity done here because there is no matching test on filetype.
				# https://github.com/hedefalk/atom-vue/issues/5
				loaders: stylus:
					if hmr
					then [
						{
							loader: 'style-loader'
							options: sourceMap: true
						}
						{
							loader: 'css-loader'
							options: sourceMap: true
						}
						{
							loader: 'stylus-loader'
							options:
								sourceMap: true
								preferPathResolver: 'webpack' # Faster
						}
						{
							loader: 'sass-resources-loader'
							options: resources: path.resolve options.context, 'definitions.styl'
						}
					]
					else ExtractText.extract use: [
						{
							loader: 'css-loader'
							options:
								sourceMap: true
								minimize: minify
						}
						{
							loader: 'stylus-loader'
							options:
								sourceMap: true
								preferPathResolver: 'webpack' # Faster
						}
						{
							loader: 'sass-resources-loader'
							options: resources: path.resolve options.context, 'definitions.styl'
						}
					]
		}
	]

	# Modernizr should be inlined into the layout file, so load it externally.
	# https://github.com/Modernizr/Modernizr/issues/1204#issuecomment-142143094
	# https://webpack.github.io/docs/library-and-externals.html#applications-and-externals
	externals:
		modernizr: 'Modernizr'

	# ############################################################################
	# Plugins - Register extra functionality
	# ############################################################################
	plugins: ( ->

		# Common plugins
		plugins = [

			# Output JSON config if the compiled files which is parsed by Laravel to
			# create script and link tags.
			new AssetsPlugin
				filename:    'manifest.json'
				path:        options.output.path
				prettyPrint: true

			# Provide common utils to all modules so they don't need to be expliclity
			# required.
			new webpack.ProvidePlugin
				$:         'jquery'
				jquery:    'jquery'
				_:         'lodash'
				Vue:       'vue'
				Modernizr: 'modernizr'
				Velocity:  'velocity'
				axios:     'axios'

			# Notify MacOS
			new Notify alwaysNotify: !hmr

			# Empty the build directory whenever webpack starts up, but doesn't run on
			# watch updates.  Has the added benefit of clearing out the dist directory
			# when running the dev server.
			new Clean [ options.output.path+'/*' ],
				root: process.cwd()
				verbose: false
		]

		# Non HMR plugins
		if not hmr then plugins = plugins.concat [

			# Extract CSS for all chunks
			new ExtractText
				filename: if minify then 'css/[name].[hash:8].css' else 'css/[name].css'
				allChunks: true

		]

		# HMR only plugins
		if hmr then plugins = plugins.concat [

			# Add HMR
			new webpack.HotModuleReplacementPlugin()

			# Add webpack dashboard
			new Dashboard()

			# Show the name of changed modules in the console
			new webpack.NamedModulesPlugin()
		]

		# Minify only plugins
		if minify then plugins = plugins.concat [

			# Add some branding to all compiled JS files
			new webpack.BannerPlugin "📝 Bukwild 💾 #{moment().format('M.D.YY')} 👍"

			# Turn off warnings during minifcation.  They aren't particularly helpfull.
			new webpack.optimize.UglifyJsPlugin compress: warnings: false

			# Put Vue in production mode
			new webpack.DefinePlugin
				'process.env': NODE_ENV: JSON.stringify('production')

			# Improve browser execution time
			new webpack.optimize.ModuleConcatenationPlugin()
		]

		# Return the final list of plugins
		return plugins
	)()
