# Utility functions

describe 'ContentTools.getEmbedVideoURL()', () ->

    it 'should return a valid video embbed URL from a youtube URL', () ->

        # Embed URL
        embedURL = 'https://www.youtube.com/embed/t4gjl-uwUHc'
        expect(ContentTools.getEmbedVideoURL(embedURL)).toBe embedURL

        # Share URL
        shareURL = 'https://youtu.be/t4gjl-uwUHc'
        expect(ContentTools.getEmbedVideoURL(shareURL)).toBe embedURL

        # Page URL
        pageURL = 'https://www.youtube.com/watch?v=t4gjl-uwUHc'
        expect(ContentTools.getEmbedVideoURL(pageURL)).toBe embedURL

        # Cater for HTTP (convert to HTTPS)
        insecureURL = 'http://www.youtube.com/watch?v=t4gjl-uwUHc'
        expect(ContentTools.getEmbedVideoURL(insecureURL)).toBe embedURL

    it 'should return a valid video embbed URL from a vimeo URL', () ->

        # Embed URL
        embedURL = 'https://player.vimeo.com/video/1084537'
        expect(ContentTools.getEmbedVideoURL(embedURL)).toBe embedURL

        # Page/Share URL
        pageURL = 'https://vimeo.com/1084537'
        expect(ContentTools.getEmbedVideoURL(pageURL)).toBe embedURL

        # Cater for HTTP (convert to HTTPS)
        insecureURL = 'http://vimeo.com/1084537'
        expect(ContentTools.getEmbedVideoURL(insecureURL)).toBe embedURL