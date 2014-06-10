angular.module("app.service").factory("Trainings", [
    '$http',
    '$rootScope',
    'icons',
    'Filters',
    ($http, $rootScope, icons, Filters)->
        new class Trainings
            tree     : []
            details: []
            degress  : []
            markers  : {}
            # ─────────────────────────────────────────────────────────────────
            # Public method
            # ─────────────────────────────────────────────────────────────────
            constructor:->
                $http.get('data/degree-places.json').success (data)=> @degrees = data
                $http.get('data/degree-details.json').success @generateTree
                $http.get('data/rne-coord.json').success @generateMarkers
                # Watch changes on filters
                $rootScope.$watch (=>Filters), @updateMarkers, yes
                # watch changes for data related to each marker
                $rootScope.$watch @isReady, @crossData, yes


            # True when both dataset are loaded
            isReady: => !_.isEmpty(@markers) and !_.isEmpty(@tree) and !_.isEmpty(@degrees)

            # Associate data to the right markers and places to the right degree
            crossData: (isLoaded)=>
                # Only if the data are loaded
                if isLoaded
                    # Look into each marker
                    angular.forEach @markers.all, (marker, rne)=>
                        # Filter to only keep degrees related to this place
                        marker.degrees = _.where @degrees, rne: rne
                        # Extract individuals (sector, level, filiere)
                        # for this places and according its degrees
                        angular.forEach marker.degrees, (degree)=>
                            # Find details of the given degree
                            details = _.findWhere @details, id: degree.id
                            # Records individuals
                            unless _.contains(marker.sectors, details.sector)
                                marker.sectors.push(details.sector)
                            unless _.contains(marker.filieres, details.filiere)
                                marker.filieres.push(details.filiere)
                            unless _.contains(marker.levels, details.level)
                                marker.levels.push(details.level)

            # Update the marker array with the
            updateMarkers: =>
                console.log @Filters

            # Creates every markers
            generateMarkers: (data)=>
                all = {}

                angular.forEach data, (place)=>
                    all[place.rne] =
                        lat   : 1*place.lat
                        lng   : 1*place.lng
                        icon  : icons.default
                        # Meta data bind to the marker
                        rne     : place.rne
                        degrees : []
                        sectors : []
                        filieres: []
                        levels  : []


                angular.extend @markers,
                    all     : all
                    filtered: all

            # Generates a tree of trainings sectors, filieres and levels
            generateTree: (data)=>
                @details = data
                sectors   = _.uniq(_.pluck(data, 'sector'))
                # First level: sector
                for sector in sectors
                    # Create a sector object
                    sectorObj    = name: sector, filieres: []
                    dataBySector = _.where(data, 'sector': sector)
                    filieres     = _.uniq(_.pluck(dataBySector, 'filiere'))
                    # Second level: filiere
                    for filiere in filieres
                        filiereObj    = name: filiere, levels: []
                        dataByFiliere = _.where(data, 'filiere': filiere)
                        levels        = _.uniq(_.pluck(dataByFiliere, 'level'))
                        # Third level: level
                        for level in levels
                            filiereObj.levels.push name: level
                        sectorObj.filieres.push filiereObj
                    @tree.push sectorObj
])
