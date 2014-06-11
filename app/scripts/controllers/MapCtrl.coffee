class MapCtrl
    @$inject: ['$scope', '$http', '$location', 'Dataset', 'Filters']
    constructor: (@scope, @http, @location, @Dataset, @Filters)->
        # ──────────────────────────────────────────────────────────────────────
        # Attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        # Default center
        @scope.center = @Filters.centers.default
        # Default markers objects
        @scope.markers = @Dataset.markers
        # Selected filters
        @scope.filters = @Filters
        # ──────────────────────────────────────────────────────────────────────
        # Watchers and events
        # ──────────────────────────────────────────────────────────────────────
        @scope.$watch 'markers.filtered', @updateBounds
        @scope.$watch (=>@Filters.centers.manual), @updateCenter, yes
        # Watch location to update selectedCfa
        @scope.$watch (=> @location.search().rne), (rne)=>
            if rne?
                # Get the CFA asynchronously
                @Dataset.getCfa(rne).then (cfa)=> @Filters.selectedCfa = cfa
            else
                # Reset data
                @Filters.selectedCfa = null

        # Catch click on a marker
        @scope.$on 'leafletDirectiveMarker.click', (ev, el)=>
            rne = el.markerName
            # Is the CFA already selected?
            if @Filters.selectedCfa? and @Filters.selectedCfa.rne is rne
                # Unset the current value
                @location.search('rne', null)
            else
                # Retreive CFA and set a filter attribute
                @location.search('rne', rne)

    updateBounds: =>
        # Bounds need this format
        bounds = _.map @scope.markers.filtered, (m)-> [m.lat, m.lng]
        # Update the bounds from the scope
        angular.extend @scope, bounds: new L.LatLngBounds(bounds)

    updateCenter: (center)=>
        # Update the map center if one is given
        angular.extend @scope, center: center if center?





angular.module('app.controller').controller "MapCtrl", MapCtrl