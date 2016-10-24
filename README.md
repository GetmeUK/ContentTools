# ContentTools

[![Build Status](https://travis-ci.org/GetmeUK/ContentTools.svg?branch=master)](https://travis-ci.org/GetmeUK/ContentTools)
[![Join the chat at https://gitter.im/GetmeUK/ContentTools](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/GetmeUK/ContentTools?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> A JS library for building WYSIWYG editors for HTML content.

<a href="http://getcontenttools.com"><img width="728" src="http://getcontenttools.com/images/github-splash.png" alt="Demo"></a>

## Install

**Using bower**

```
bower install --save ContentTools
```

**Using npm**

```
npm install --save ContentTools
```

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

## ContentTools via jsdelivr

ContentTools is available via the [jsdelivr open source CDN](http://www.jsdelivr.com/), to reference a file from the ContentTools build directory use the following URL format:

`http://cdn.jsdelivr.net/contenttools/{verision}/{file}`

For example to access the current primary JavaScript file the URL would be:

`http://cdn.jsdelivr.net/contenttools/1.3.1/content-tools.min.js`

As the project's CSS uses relative file paths you will need to either role your own version of CSS from the SASS files (recommended) or [override references to fonts/images within your local CSS](https://gist.github.com/anthonyjb/a6aec8ecfbfe6f875d5c6691687ba43d).


## Documentation
Full documentation is available at http://getcontenttools.com/api/content-tools

## Where to post...

- How do I? -- StackOverflow
- I got this error, why? -- StackOverflow
- I got this error and I'm sure it's a bug -- post an issue
- I have an idea/request -- post an issue
- Why do you? -- chat with me on gitter (I may then post it as an issue)
- When will you? -- chat with me on gitter (I may then post it as an issue)
- You suck and I hate you -- contact us privately at pm@piersmorgan.me!
- You're awesome -- please find a megaphone and suitably high rooftop (but seriously any help spreading the word about ContentTools is much appreciated)

> Stolen almost in it's entirety from this [post](http://meta.stackexchange.com/questions/3966/is-it-okay-to-use-stack-overflow-as-the-support-forum-for-a-product-or-project) on meta.stackexchange.com

## Browser support
The current aim is for all the libraries to support IE9+, Chrome and Firefox. Test suites are complete for all the libraries except ContentTools and I'm using Jasmine to check that the tests pass in those browsers.

There will be some visual differences for ContentTools in IE9 as I use CSS animations for some of the UI feedback.

## Helpful organizations
ContentTools is developed using a number of tools & services provided for free by nice folks at organizations committed to supporting open-source projects including [BrowserStack](http://www.browserstack.com), [GitHub](https://github.com) and [jsdelivr](http://www.jsdelivr.com/), [Travis CI](https://travis-ci.org).
