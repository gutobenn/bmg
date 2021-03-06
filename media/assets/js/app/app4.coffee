#
# Banco Genitalia App
#

window.zoomSettings = {
    targetsize: 0.9,
    preservescroll: true,
    closeclick: true
}

class App
    constructor: (viewport,size) ->
        @size   = size
        [WIDTH,HEIGHT] = [ @size[0], @size[1]]

        @photoJSONList  = []
        @photosDOMList  = []
        @inZoom         = false

        @container = $jQ(viewport)
        @onResize()

    setup: (photoList, loading_cb, loaded_cb) =>
        @photoJSONList    = photoList

        @imgCounter = Math.floor( Math.random() * (@photoJSONList.length - 1) )

        # Setup Events
        window.addEventListener('resize', $jQ.debounce( 100, @onResize ), false)
        $jQ('#wall').on('mouseup', '.tile', (ev,e ) =>
            @onPhotoClick(ev,e) if not @dragged
        )
        $jQ(document).on('mousewheel', @onScrollStart.bind(this))
        #$jQ(document).on('mousewheel DOMMouseScroll', @onScrollStop)

        # start wall
        @wall = new Wall("wall", {
                        "draggable": false,
                        "scrollable": true,
                        "width":    120,
                        "height":   180,
                        "speed":    800,
                        "inertia":  true,
                        "inertiaSpeed": 0.93,
                        "printCoordinates": false,
                        "rangex":   [-100,100],
                        "rangey":   [-100,100],

                        callOnUpdate:  (items) =>
                            return if items.length == 0
                            @createDOMPhotos( items )
                        })

        @wall.initWall()

        # Callbacks for loading
        loading_cb    = loading_cb ? $jQ.noop
        loaded_cb     = loaded_cb ? $jQ.noop

        loadingImages = $jQ('#wall').imagesLoaded() \
        .always( (instance, images) ->
            loaded_cb( instance, images )
        ) \
        .progress( (instance, images) ->
            loading_cb( instance, images )
        )


    # Called when there are photo tiles to be created.
    createDOMPhotos: (items) =>
        items.each( (e,i) =>

            if PHOTO_TILING == 'random'
                @imgCounter = Math.floor( Math.random() * @photoJSONList.length )
            else if PHOTO_TILING == 'sequential'
                @imgCounter = (@photoJSONList.length-1 + @imgCounter++) % @photoJSONList.length

            currPhoto = @photoJSONList[@imgCounter]

            img = new Element("img[src='#{currPhoto.url_small}']")
            img.inject(e.node)

            $jQ(e.node).imagesLoaded( (elem,cb)->
                $jQ(img).addClass('loaded')
            )

            $jQ(img).data('photo_info', currPhoto)
        )

    onScrollStart: (e) =>
      xspeed = e.deltaX * e.deltaFactor;
      yspeed = e.deltaY * e.deltaFactor;
      finX = @wall.wall.getStyle("left").toInt() + (xspeed*-1);
      finY = @wall.wall.getStyle("top").toInt() + yspeed;

      @wall.wall.setStyle("left", finX)
      @wall.wall.setStyle("top", finY)

      @wall.moved++;
      @wall.options.callOnUpdate(@wall.updateWall())
      e.stopPropagation();

      return false;

    # Someone clicked on the photo.
    onPhotoClick: (ev,e) =>
        # Dont zoom if dragging
        @cTarget = $jQ(ev.target)
        if(@cTarget).is('div')
          @cTarget = @cTarget.children()
        if not @inZoom
            @zoomIn( @cTarget )
        else
            if @cTarget.attr('src') == @prevTarget.attr('src')
                @zoomOut()
            else
                @zoomIn( @cTarget )

    zoomIn: (photo_el) =>
        @prevTarget = @cTarget
        @inZoom = true

        $jQ(photo_el).attr('src', $jQ(photo_el).data('photo_info').url )
        $jQ(photo_el).imagesLoaded( =>
            @wall.normalizePosition()
        )

        $jQ(photo_el).zoomTo(window.zoomSettings)
        #$jQ(photo_el).zoomTo({targetSize: 0.75, duration: 600 })

    zoomOut: =>
        @inZoom = false
        $jQ('body').zoomTo(window.zoomSettings)

    onResize: =>
        [WIDTH,HEIGHT] = [window.innerWidth, window.innerHeight]
        $jQ(@container).css({width: WIDTH, height: HEIGHT});
        $jQ('#overlay').css({width: WIDTH, height: HEIGHT});


module.exports = App
