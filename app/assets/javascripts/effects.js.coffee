# David Bassett - 2014

# JQuery plugins

# create a floating marker to highlight important or
#  selected elements without disturbing the document flow
$.fn.mark = (opts) ->
  opts = $.extend true, {}, $.fn.mark.options, opts

  this.each ->
    elem = $(this)

    # get these now before the marker is placed
    top  = elem.position().top + opts.offset.top
    left = elem.position().left + opts.offset.left

    newElem = $("<span/>", {
      class: [opts.markerClass, 'sc-mark'].join ' '
    }).insertBefore elem

    newElem.zIndex(999)

    top  -= opts.markerHeight * 1.3
    left += (elem.outerWidth() - newElem.outerWidth()) / 2

    newElem.css {
      position: 'absolute'
      top:      Math.round(top)
      left:     Math.round(left)
    }

$.fn.mark.options = {
  type:        'top' # not yet used
  markerClass: 'mark'
  markerHeight: 7
  offset: {
    top:    0
    left:   0
  }
}

# remove any marker elements
$.fn.unmark = -> 
  $(this).prev('.sc-mark').remove()

# Draws a horizontal rule in the provided element
#  marking the current time for today
$.fn.drawTimeline = (opts) ->
  opts = $.extend true, {}, $.fn.drawTimeline.options, opts
  elem = $(this)
  d    = new Date
  timeOffset  = (d.getHours()*60 + d.getMinutes()) * opts.pxPerMin

  top  = opts.offset.top + timeOffset
  left = opts.offset.left

  newElem = $("<hr/>", {
    class: opts.class
  }).prependTo elem

  newElem.zIndex(999)

  newElem.css {
    position: 'absolute'
    top:      0
    left:     Math.round(left)
  }

  # todo: refactor this
  setTimeout( ->
   newElem.css {
    top: Math.round(top)
  }, 1)

$.fn.drawTimeline.options = {
  class:    'timeline'
  pxPerMin: 0.8
  offset: {
    top:    0
    left:   0
  }
}

# hacky method for calculating the width of an elements
#  rendered text
# Note: It looks like it is at least a few pixels off
$.fn.textWidth = ->
  html_org = $(this).html()
  html_calc = '<span>' + html_org + '</span>'
  $(this).html(html_calc)
  width = $(this).find('span:first').width()
  $(this).html(html_org)
  width