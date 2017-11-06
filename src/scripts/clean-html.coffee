
class HTMLCleaner

    # A class for cleaning (sanitizing) HTML.
    #
    # This class is specifically designed for cleaning HTML so that it can be
    # safely convert to ContentEdit elements, it use outside of ContentTools/
    # Edit is probably limited.
    #
    # The class itself was inspired by Alok Menghrajani's code snippet for
    # sanitizing HTML which can be found here:
    #
    # ~ https://www.quaxio.com/html_white_listed_sanitizer/

    constructor: () ->

        # @@ list of tags we can accept
        # @@ table of tags that we remap to other tags (so they can be
        #    converted to HTML elements).
        # @@ Table of attributes accepted against tag types

    clean: (html) ->
        # Return a clean version of the given string of HTML