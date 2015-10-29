# ContentTools

[![Build Status](https://travis-ci.org/GetmeUK/ContentTools.svg?branch=master)](https://travis-ci.org/GetmeUK/ContentTools)
[![Join the chat at https://gitter.im/GetmeUK/ContentTools](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/GetmeUK/ContentTools?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> A JS library for building WYSIWYG editors for HTML content.

<a href="http://getcontenttools.com"><img width="728" src="http://getcontenttools.com/images/github-splash.png" alt="Demo"></a>

## Building
To build the library you'll need to use Grunt. First install the required node modules ([grunt-cli](http://gruntjs.com/getting-started) must be installed):
```
git clone https://github.com/GetmeUK/ContentTools.git
cd ContentTools
npm install
```

Install Sass (if not already installed):
```
gem install sass
```

Then run `grunt build` to build the project.

## Testing
To test the library you'll need to use Jasmine. First install Jasmine:
```
git clone https://github.com/pivotal/jasmine.git
mkdir ContentTools/jasmine
mv jasmine/dist/jasmine-standalone-2.0.3.zip ContentTools/jasmine
cd ContentTools/jasmine
unzip jasmine-standalone-2.0.3.zip
```

Then open `ContentTools/SpecRunner.html` in a browser to run the tests.

Alternatively you can use `grunt jasmine` to run the tests from the command line.

## Documentation
Full documentation is available at http://getcontenttools.com/api/content-tools

## Browser support
The current aim is for all the libraries to support IE9+, Chrome and Firefox. Test suites are complete for all the libraries except ContentTools and I'm using Jasmine to check that the tests pass in those browsers.

There will be some visual differences for ContentTools in IE9 as I use CSS animations for some of the UI feedback.

## Helpful organizations
ContentTools is developed using a number of tools & services provided for free by nice folks at organizations committed to supporting open-source projects including [BrowserStack](http://www.browserstack.com), [GitHub](https://github.com) and [Travis CI](https://travis-ci.org).
