class MapCtrl
    @$inject: ['$scope', '$http', '$compile', '$location', 'Dataset', 'Filters', 'leafletData']
    constructor: (@scope, @http, @compile, @location, @Dataset, @Filters, @leafletData)->
        # Load marker template
        @markerPopupHtml = '<div ng-include="\'partials/map.popup.html\'"></div>'
        # ──────────────────────────────────────────────────────────────────────
        # Attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        # Default markers objects
        @scope.markers = @Dataset.markers
        # Selected filters
        @scope.filters = @Filters
        # Map options
        @scope.defaults =
            minZoom        : 9
            maxZoom        : 14
            zoomControl    : yes
            scrollWheelZoom: no

        # ──────────────────────────────────────────────────────────────────────
        # Watchers and events
        # ──────────────────────────────────────────────────────────────────────
        @scope.$watch 'markers.filtered', @updateBounds, yes
        @scope.$watch (=>@Filters.centers.manual), @updateCenter, yes
        # Watch location to update selectedCfa
        @scope.$watch (=> @location.search().rne), (rne)=>
            if rne?
                # Get the CFA asynchronously
                @Dataset.getCfa(rne).then (cfa)=> @Filters.selectedCfa = cfa
            else
                # Reset data
                @Filters.selectedCfa = null

        # Reset selection when clicking on the map
        @scope.$on 'leafletDirectiveMap.click', => @location.search('rne', null)
        # Catch click on a marker
        @scope.$on 'leafletDirectiveMarker.popupopen', (ev, el)=>
            rne = el.markerName
            # Create the popup view when is opened
            scope = @scope.$new()
            @Dataset.getCfa(rne)
            # Add cfa to the new
            @Dataset.getCfa(rne).then (cfa)-> angular.extend scope, cfa: cfa
            # Get popup node
            content = angular.element el.leafletEvent.popup._contentNode
            content.html @markerPopupHtml
            # Compile template with the new scope
            @compile(content)(scope)
            # Close current pane
            @Filters.selectedCfa = null unless @Filters.selectedCfa.rne is rne

    updateBounds: =>
        active = @Filters.get()[1]
        # Bounds need this format
        bounds = _.map @scope.markers.filtered, (m)-> [m.lat, m.lng]
        # Do not update bounds if not needed
        if bounds.length and active isnt 'place'
            # New bounds !
            @leafletData.getMap("map").then (m)-> m.fitBounds(bounds)
        else
            @updateCenter @Filters.centers.manual

    updateCenter: (center)=>
        # Use set view to avoid conflicts with fit bounds
        @leafletData.getMap("map").then (m)-> m.setView(center, center.zoom)





angular.module('app.controller').controller "MapCtrl", MapCtrl
