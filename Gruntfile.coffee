module.exports = (grunt) ->

    require('es6-promise').polyfill()

    # Project configuration
    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json')

        coffee:
            options:
                join: true

            build:
                files:
                    'src/tmp/content-tools.js': [
                        'src/scripts/namespace.coffee'

                        # UI
                        'src/scripts/ui/ui.coffee'
                        'src/scripts/ui/events.coffee'
                        'src/scripts/ui/flashes.coffee'
                        'src/scripts/ui/ignition.coffee'
                        'src/scripts/ui/inspector.coffee'
                        'src/scripts/ui/modal.coffee'
                        'src/scripts/ui/toolbox.coffee'

                        # UI - Dialogs
                        'src/scripts/ui/dialogs/dialogs.coffee'
                        'src/scripts/ui/dialogs/image.coffee'
                        'src/scripts/ui/dialogs/link.coffee'
                        'src/scripts/ui/dialogs/properties.coffee'
                        'src/scripts/ui/dialogs/table.coffee'
                        'src/scripts/ui/dialogs/video.coffee'

                        # Other
                        'src/scripts/editor.coffee'
                        'src/scripts/history.coffee'
                        'src/scripts/styles.coffee'
                        'src/scripts/tools.coffee'
                    ]

            sandbox:
                files:
                    'sandbox/sandbox.js': [
                        'src/sandbox/image-uploader.coffee'
                        'src/sandbox/sandbox.coffee'
                        ]

            spec:
                files:
                    'spec/spec-helper.js': 'src/spec/spec-helper.coffee'
                    'spec/content-tools-spec.js': [
                        'src/spec/namespace.coffee'

                        # UI
                        'src/spec/ui/ui.coffee'
                        'src/spec/ui/events.coffee'
                        'src/spec/ui/flashes.coffee'
                        'src/spec/ui/ignition.coffee'
                        'src/spec/ui/inspector.coffee'
                        'src/spec/ui/modal.coffee'
                        'src/spec/ui/toolbox.coffee'

                        # UI - Dialogs
                        'src/spec/ui/dialogs/dialogs.coffee'
                        'src/spec/ui/dialogs/image.coffee'
                        'src/spec/ui/dialogs/link.coffee'
                        'src/spec/ui/dialogs/properties.coffee'
                        'src/spec/ui/dialogs/table.coffee'
                        'src/spec/ui/dialogs/video.coffee'

                        # Other
                        'src/spec/editor.coffee'
                        'src/spec/history.coffee'
                        'src/spec/tools.coffee'
                        'src/spec/styles.coffee'
                        ]

        sass:
            options:
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> by <%= pkg.author.name %> <<%= pkg.author.email %>> (<%= pkg.author.url %>) */'
                sourcemap: 'none'

            build:
                files:
                    'build/content-tools.min.css':
                        'src/styles/content-tools.scss'

            sandbox:
                files:
                    'sandbox/sandbox.css': 'src/sandbox/sandbox.scss'

        cssnano:
            options:
                sourcemap: false

            build:
                files:
                    'build/content-tools.min.css':
                        'build/content-tools.min.css'

        uglify:
            options:
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> by <%= pkg.author.name %> <<%= pkg.author.email %>> (<%= pkg.author.url %>) */\n'
                mangle: true

            build:
                src: 'build/content-tools.js'
                dest: 'build/content-tools.min.js'

        concat:
            build:
                src: [
                    'external/scripts/content-edit.js'
                    'src/tmp/content-tools.js'
                ]
                dest: 'build/content-tools.js'

        clean:
            build: ['src/tmp']

        jasmine:
            build:
                src: ['build/content-tools.js']
                options:
                    specs: 'spec/content-tools-spec.js'
                    helpers: 'spec/spec-helper.js'

        watch:
            build:
                files: [
                    'src/scripts/**/*.coffee',
                    'src/styles/**/*.scss'
                    ]
                tasks: ['build']

            sandbox:
                files: [
                    'src/sandbox/*.coffee',
                    'src/sandbox/*.scss'
                    ]
                tasks: ['sandbox']

            spec:
                files: ['src/spec/**/*.coffee']
                tasks: ['spec']
    })

    # Plug-ins
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-jasmine'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-cssnano'

    # Tasks
    grunt.registerTask 'build', [
        'coffee:build'
        'sass:build'
        'cssnano:build'
        'concat:build'
        'uglify:build'
        'clean:build'
    ]

    grunt.registerTask 'sandbox', [
        'coffee:sandbox'
        'sass:sandbox'
    ]

    grunt.registerTask 'spec', [
        'coffee:spec'
    ]

    grunt.registerTask 'watch-build', ['watch:build']
    grunt.registerTask 'watch-sandbox', ['watch:sandbox']
    grunt.registerTask 'watch-spec', ['watch:spec']