class ContentTools.StylePalette

    # The `StylesPalette` class stores a list of styles available to the content
    # editor application. A list of styles is usually defined and added to the
    # palette as part of initializing the application.

    @_styles = []

    # Class methods

    @add: (styles) ->
        # Add a list of styles to the palette
        @_styles = @_styles.concat(styles)

    @styles: (tagName) ->
        # Return the styles (optional only those applicable for the specified
        # tag name).

        # If no tag name is specified return a copy of the stlyes list
        if tagName is undefined
            return @_styles.slice()

        # Filter the styles
        return @_styles.filter (style) ->
            if not style._applicableTo
                return true

            return style._applicableTo.indexOf(tagName) != -1


class ContentTools.Style

    # The `Style` class is used to define styles (CSS classes) for use in the
    # editor.

    constructor: (name, cssClass, applicableTo) ->

        # A user friendly name
        @_name = name

        # The CSS class name
        @_cssClass = cssClass

        # A list of tag names the style is applicable to, if not defined the
        # style will be applicable to all elements.
        if applicableTo
            @_applicableTo = applicableTo
        else
            @_applicableTo = null

    # Read-only properties

    applicableTo: () ->
        # Return the tag names this style is applicable to, no value means the
        # style is applicable to any tag.
        return @_applicableTo

    cssClass: () ->
        # Return the CSS class name for the style
        return @_cssClass

    name: () ->
        # Return the name of the style
        return @_name