angular.module('app.directive').directive "movingBackground", ['$timeout', ($timeout)->
    restrict: "A"
    replace: false
    scope:
        gap: "="
        timeout: "="
        offset: "="
    link: (scope, element, attrs) ->
        nextLogoFrame = ->
            step = element.data("step") or 1
            # Slide the logo background
            element.css "background-position", (-1 * step * scope.gap) + 1*scope.offset
            # Record the next step
            element.data "step", step + 1
            # Next call
            $timeout nextLogoFrame, scope.timeout
        # First timeout
        $timeout nextLogoFrame, scope.timeout
]