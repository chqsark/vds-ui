/* browserify task
   ---------------
   Bundle javascripty things with browserify!

   If the watch task is running, this uses watchify instead
   of browserify for faster bundling using caching.
*/

var browserify   = require('browserify');
var watchify     = require('watchify');
var bundleLogger = require('../util/bundleLogger');
var gulp         = require('gulp');
var handleErrors = require('../util/handleErrors');
var source       = require('vinyl-source-stream');
var uglify       = require('gulp-uglify');
var streamify = require('gulp-streamify');

gulp.task('browserify', function() {

	var bundleMethod = global.isWatching ? watchify : browserify;

	var bundler = bundleMethod({
		// Specify the entry point of your app
		entries: ['./src/javascript/vds-track.coffee'],
		// Add file extentions to make optional in your requires
		extensions: ['.coffee'],
		// Enable source maps!
		debug: true
	});

	var bundle = function() {
		// Log when bundling starts
		bundleLogger.start();

		var stream = bundler
			.bundle()
			// Report compile errors
			.on('error', handleErrors)
			// Use vinyl-source-stream to make the
			// stream gulp compatible. Specifiy the
			// desired output filename here.
			.pipe(source('vds-track.js'));
			if (!global.isWatching) {
			    stream.pipe(streamify(uglify()))
			}
			// Specify the output destination
			stream.pipe(gulp.dest('./build/'))
			// Log when bundling completes!
			.on('end', bundleLogger.end);
	    return stream;
	};

	if(global.isWatching) {
		// Rebundle with watchify on changes.
		bundler.on('update', bundle);
	}

	return bundle();
});
