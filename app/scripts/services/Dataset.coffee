angular.module("app.service").factory("Dataset", [
    '$http',
    '$rootScope',
    '$q',
    'icons',
    'Filters',
    ($http, $rootScope, $q, icons, Filters)->
        new class Dataset
            tree     : []
            details  : []
            degrees  : []
            markers  : {}
            # ─────────────────────────────────────────────────────────────────
            # Public method
            # ─────────────────────────────────────────────────────────────────
            constructor:->
                # Create a promise to be resolve when all data are loaded
                @deferred = do $q.defer
                # Load datasets
                $http.get('data/degree-places.json').success (data_1) =>
                    $http.get('data/employers.json').success (data_2) =>
                        @degrees = data_1
                        data_2 = _.indexBy data_2, 'Code RNE'
                        for key of @degrees
                            rne = @degrees[key].rne
                            if data_2[rne]?
                                info = data_2[rne]
                                @degrees[key].phone = info['Téléphone Contact'] if info['Téléphone Contact'] isnt ''
                                @degrees[key].email = info['Email Contact'] if info['Email Contact'] isnt ''
                                @degrees[key].civility = "#{info['Civilité Contact']} #{info['Prenom Contact']} #{info['Nom Contact']}"
                $http.get('data/degree-details.json').success @generateTree
                $http.get('data/rne-coord.json').success @generateMarkers
                # Watch changes on filters
                $rootScope.$watch (=>Filters.get()), @updateFilteredMarkers, yes
                $rootScope.$watch (=>Filters.centers.manual), @generateAddrMarker, yes
                # watch changes for data related to each marker
                $rootScope.$watch @isReady, @crossData, yes


            # True when both dataset are loaded
            isReady: => @markers.all? and !_.isEmpty(@tree) and @degrees.length

            # Associate data to the right markers and places to the right degree
            crossData: (isLoaded)=>
                # Only if the data are loaded
                if isLoaded
                    angular.forEach @degrees, (degree)=>
                        marker = @markers.all[degree.rne]
                        # A marker with this RNE exists
                        if marker?
                            # Find details of the given degree
                            details = @detailsById[degree.id]
                            # First time on this marker
                            unless marker.slug?
                                # Extract address from the first degreee
                                angular.extend marker, degree
                                # Extract name too
                                marker.name    = degree.name
                                marker.message = marker.name
                                marker.slug    = @slugify marker.name
                            # Add the degree to this sector
                            marker.sectors.push  details.sector
                            marker.filieres.push details.filiere
                            marker.levels.push   details.level
                            marker.degrees.push  degree.id
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
                    @markers.filtered = @markers.all or {}
                # Filters markers
                else
                    @markers.filtered = {}
                    for own rne, marker of @markers.all
                        pass = yes
                        # Test every filver
                        for own key, val of filters
                            # Filter by sector
                            if active is 'sector' and _.contains Filters.KEYS.SECTOR, key
                                pass = pass && _.contains marker[key + "s"], val
                            # Filter by name
                            if active is 'name' and _.contains Filters.KEYS.NAME, key
                                pass = pass && -1 isnt marker.slug.indexOf @slugify(val)
                        # Add the marker only if every filters are OK
                        @markers.filtered[rne] = marker if pass

                do @generateAddrMarker

            # Add address marker
            generateAddrMarker: =>
                centers = Filters.centers
                active  = Filters.get()[1]

                delete @markers.filtered["addr"] if @markers.filtered["addr"]?

                if active is "place" and not angular.equals(centers.manual, centers.default)
                    # Add address marker
                    @markers.filtered["addr"] =
                        icon: icons.address
                        lat : centers.manual.lat
                        lng : centers.manual.lng



            # Get CFA that matches with the given RNE
            getCfa: (rne, withDetails=yes)=>
                deferred = do $q.defer
                @deferred.promise.then =>
                    cfa = @markers.all[rne]
                    if withDetails
                        # Extract degree's details for this CFA
                        cfa.details = _.filter @details, (d)-> _.contains cfa.degrees, d.id
                        # Group by sector, filiere, level
                        cfa.details = @getTree cfa.details
                    deferred.resolve(cfa)
                return deferred.promise

            # Creates every markers
            generateMarkers: (data)=>
                all = {}

                for place in data
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

                @markers.all = all
                @markers.filtered = all

            # Generates a tree of trainings sectors, filieres and levels
            generateTree: (data)=>
                @details = data
                # Create an object with each detail
                @detailsById = {}
                @detailsById[detail.id] = detail for detail in @details

                @tree = @tree.concat @getTree(data)

            getTree: (data)->
                tree = []
                sectors = _.pluck(data, 'sector')
                # Do not iterate several time on with those keys
                sectorKeys  = {}
                filiereKeys = {}
                # First level: sector
                for sector in sectors
                    # Iterate on a sector once
                    if sectorKeys[sector]? then continue else sectorKeys[sector] = 1
                    # Create a sector object
                    sectorObj    = name: sector, filieres: []
                    # Get degrees for this sector
                    degreesBySector = _.where(data, 'sector': sector)
                    # Extract filieres for this sector
                    filieresBySector = _.pluck(degreesBySector, 'filiere')

                    for filiere in filieresBySector
                        # Iterate on a filiere once
                        if filiereKeys[filiere]? then continue else filiereKeys[filiere] = 1
                        # Get degrees for this filiere
                        degreesByFiliere = _.where(degreesBySector, 'filiere': filiere)
                        # Extract levels for this filiere
                        levelsByFiliere = _.uniq _.pluck(degreesByFiliere, 'level')
                        # Create filiere obj to append to sector's filieres
                        sectorObj.filieres.push
                            name   : filiere
                            degrees: degreesByFiliere
                            levels : _.map levelsByFiliere, (level)-> name: level

                    tree.push sectorObj
                # Return the tree
                tree

            slugify: (str="")->
                # Duck-typing: is it a string?
                return "" unless str.replace?
                str = str.replace(/^\s+|\s+$/g, "")
                str = str.toLowerCase()
                from = "àáäâèéëêìíïîòóöôùúüûñç·/_,:;"
                to = "aaaaeeeeiiiioooouuuunc------"
                for i in [0..from.length]
                    str = str.replace(new RegExp(from.charAt(i), "g"), to.charAt(i))
                str = str.replace(/[^a-z0-9 -]/g, "").replace(/\s+/g, "-").replace(/-+/g, "-")
                str
])
