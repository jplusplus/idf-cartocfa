angular.module("app.animation").animation ".slide", ['animations', (animations)->
    beforeAddClass: (element, className, done)->
        if className is "ng-hide"
            jQuery(element).show().slideUp(animations.slideDuration, done)
        return null

    removeClass: (element, className, done)->
        if className is "ng-hide"
            jQuery(element).hide().slideDown(animations.slideDuration, done)
        return null
]