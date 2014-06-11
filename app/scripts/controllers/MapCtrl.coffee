class MapCtrl
    @$inject: ['$scope', '$http', 'Dataset', 'Filters']
    constructor: (@scope, @http, @Dataset, @Filters)->
        # ──────────────────────────────────────────────────────────────────────
        # Attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        # Default center
        @scope.center = @Filters.centers.default
        # Default markers objects
        @scope.markers = @Dataset.markers
        # ──────────────────────────────────────────────────────────────────────
        # Watchers
        # ──────────────────────────────────────────────────────────────────────
        @scope.$watch 'markers.filtered', @updateBounds
        @scope.$watch (=>@Filters.centers.manual), @updateCenter, yes

    updateBounds: =>
        # Bounds need this format
        bounds = _.map @scope.markers.filtered, (m)-> [m.lat, m.lng]
        # Update the bounds from the scope
        angular.extend @scope, bounds: new L.LatLngBounds(bounds)

    updateCenter: (center)=>
        # Update the map center if one is given
        angular.extend @scope, center: center if center?





angular.module('app.controller').controller "MapCtrl", MapCtrl