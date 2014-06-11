angular.module("app.service").factory("Dataset", [
    '$http',
    '$rootScope',
    '$q';
    'icons',
    'Filters',
    'Slug',
    ($http, $rootScope, $q, icons, Filters, Slug)->
        new class Dataset
            tree     : []
            details  : []
            degress  : []
            markers  : {}
            # ─────────────────────────────────────────────────────────────────
            # Public method
            # ─────────────────────────────────────────────────────────────────
            constructor:->
                # Create a promise to be resolve when all data are loaded
                @deferred = do $q.defer
                # Load datasets
                $http.get('data/degree-places.json').success (data)=> @degrees = data
                $http.get('data/degree-details.json').success @generateTree
                $http.get('data/rne-coord.json').success @generateMarkers
                # Watch changes on filters
                $rootScope.$watch (=>Filters.get()), @updateFilteredMarkers, yes
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
                        degrees = _.where @degrees, rne: rne
                        # Extract address from the first degreee
                        angular.extend marker, degrees[0]
                        # Only keep degree id
                        marker.degrees = _.pluck degrees, "id"
                        if degrees.length
                            marker.name = degrees[0].name
                            marker.message = marker.name
                            marker.slug = Slug.slugify(marker.name)
                        # Extract individuals (sector, level, filiere)
                        # for this places and according its degrees
                        angular.forEach marker.degrees, (degree)=>
                            # Find details of the given degree
                            details = _.findWhere @details, id: degree
                            # Records individuals
                            unless _.contains(marker.sectors, details.sector)
                                marker.sectors.push(details.sector)
                            unless _.contains(marker.filieres, details.filiere)
                                marker.filieres.push(details.filiere)
                            unless _.contains(marker.levels, details.level)
                                marker.levels.push(details.level)
                    # Resolve the promise
                    do @deferred.resolve

            # Update the marker array with the
            updateFilteredMarkers: =>
                [filters, active] = Filters.get()
                for own key, val of filters
                    if val is null
                        delete filters[key]
                # Reset all marker
                if _.isEmpty(filters)
                    @markers.filtered = @markers.all
                # Filters markers
                else
                    @markers.filtered = {}
                    for own rne, marker of @markers.all
                        pass = yes
                        # Test every filver
                        for own key, val of filters
                            # Filter by sector
                            if active is 'sector' and _.contains Filters.KEYS.SECTOR, key
                                pass and= _.contains marker[key + "s"], val
                            # Filter by name
                            if active is 'name' and _.contains Filters.KEYS.NAME, key
                                pass and= -1 isnt marker.slug.indexOf Slug.slugify(val)
                        # Add the marker only if every filters are OK
                        @markers.filtered[rne] = marker if pass

            # Get CFA that matches with the given RNE
            getCfa: (rne)=>
                deferred = do $q.defer
                if @markers.all? and @markers.all.length
                    cfa = _.findWhere @markers.all, rne: rne

                else
                    @deferred.promise.then =>
                        cfa = _.findWhere @markers.all, rne: rne
                        deferred.resolve(cfa)
                return deferred.promise

            # Creates every markers
            generateMarkers: (data)=>
                all = {}

                angular.forEach data, (place)=>
                    all[place.rne] =
                        lat    : 1*place.lat
                        lng    : 1*place.lng
                        icon   : icons.default
                        message: null
                        focus  : no
                        # Meta data bind to the marker
                        rne     : place.rne
                        name    : null
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