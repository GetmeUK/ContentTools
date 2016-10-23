class ContentTools.StylePalette

    # The `StylesPalette` class stores a list of styles available to the content
    # editor application. A list of styles is usually defined and added to the
    # palette as part of initializing the application.

    @_styles = []

    # Class methods

    @add: (styles) ->
        # Add a list of styles to the palette
        @_styles = @_styles.concat(styles)

    @styles: (element) ->
        # If no element is specified return a copy of the stlyes list
        if element is undefined
            return @_styles.slice()
        
        # Return the styles (optional only those applicable for the specified
        # tag name).
        tagName = element.tagName()

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

        # The `applicableTo` value by default will contain a list of class names
        # the style can be applied to however if the `StylePalette.styles`
        # method is overridden then the value of applicable to maybe any
        # construct required to support the overridden styles method.
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