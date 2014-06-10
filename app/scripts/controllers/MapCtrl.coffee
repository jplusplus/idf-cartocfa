class MapCtrl
    @$inject: ['$scope', '$http', 'Dataset']
    constructor: (@scope, @http, @Dataset)->
        # ──────────────────────────────────────────────────────────────────────
        # Attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        # Default center
        @scope.center =
            lat: 48.856583
            lng: 2.3510745
            zoom: 11
        # Default markers objects
        @scope.markers = @Dataset.markers
        # ──────────────────────────────────────────────────────────────────────
        # Methods available within the scope
        # ──────────────────────────────────────────────────────────────────────

        # ──────────────────────────────────────────────────────────────────────
        # Watchers
        # ──────────────────────────────────────────────────────────────────────
        @scope.$watch 'markers.filtered', @updateBounds

    updateBounds: =>
        # Bounds need this format
        bounds = _.map @scope.markers.filtered, (m)-> [m.lat, m.lng]
        # Update the bounds from the scope
        angular.extend @scope,
            bounds: new L.LatLngBounds(bounds)




angular.module('app.controller').controller "MapCtrl", MapCtrl