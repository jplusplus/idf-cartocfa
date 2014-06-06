class MainCtrl
    @$inject: ['$scope', '$http', 'Trainings']
    constructor: (@scope, @http, @Trainings)->
        @icons = 
            default:
                iconUrl:  '/images/pointeur-general.png'
                iconSize: [27, 36]
                shadowSize: [0, 0]
                iconAnchor: [27/2, 36]
            
        # ──────────────────────────────────────────────────────────────────────
        # Attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        # Default center
        @scope.center =
            lat: 48.856583
            lng: 2.3510745
            zoom: 11         
        # Default markers objects
        @scope.markers   = all: {}, filtered: {}
        @scope.trainings = []
        # ──────────────────────────────────────────────────────────────────────
        # Methods available within the scope
        # ──────────────────────────────────────────────────────────────────────
        

        # ──────────────────────────────────────────────────────────────────────
        # Initial data
        # ──────────────────────────────────────────────────────────────────────
        @http.get('data/rne-coord.json').success (data)=>            
            markers = {}
            angular.forEach data, (place)=> 
                markers[place.rne] = 
                    lat : 1*place.lat
                    lng : 1*place.lng
                    icon: @icons.default

            angular.extend @scope.markers,
                all     : markers
                filtered: markers

        @http.get('data/training.json').success (data)=> 
            # Save trainings
            angular.extend @scope, trainings: data
            # Extract sectors from trainings
            @scope.sectors = _.uniq(_.pluck(data, 'sector'))
            @scope.sectors.sort()
            # Extract levels from tainings
            @scope.levels = _.uniq(_.pluck(data, 'level'))
            @scope.levels.sort()
            # Extract filieres from trainings
            @scope.filieres = _.uniq(_.pluck(data, 'filiere'))
            @scope.filieres.sort()


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




angular.module('app.controller').controller "MainCtrl", MainCtrl