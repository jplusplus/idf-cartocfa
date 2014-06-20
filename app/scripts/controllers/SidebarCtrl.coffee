class SidebarCtrl
    @$inject: ['$scope', '$rootScope', '$q', '$http', '$location', 'Filters', 'Dataset']
    constructor: (@scope, @rootScope, @q, @http, @location, @Filters, @Dataset)->
        @empty = []
        # Filter to display
        @shouldShowFilter = 'sector'
        @shouldShowSector =
        @bounds     =
            wn: [1.232294, 49.256857]
            es: [3.580622, 48.103566]
            ne: [49.256857, 3.580622]
            sw: [48.103566, 1.232294]
        @gmapBounds = @bounds.wn.join(",") + "," + @bounds.es.join(",")
        @gmapUrl    = "http://nominatim.openstreetmap.org/search?"
        @gmapUrl   += "format=json&"
        @gmapUrl   += "limit=10&"
        @gmapUrl   += "bounded=1&"
        @gmapUrl   += "osm_type=N&"
        @gmapUrl   += "viewbox=#{@gmapBounds}&"

        # instantiate the bloodhound suggestion engine for places
        @placeEngine = new Bloodhound
            datumTokenizer: (d) ->
                Bloodhound.tokenizers.whitespace (d.rne or "") + " " + ((d.name or "").replace /\W/g, " ")
            queryTokenizer: Bloodhound.tokenizers.whitespace
            local: []

        # instantiate the bloodhound suggestion engine for addr from GoogleMap
        @addrEngine = new Bloodhound
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("value")
            queryTokenizer: Bloodhound.tokenizers.whitespace
            remote:
                dataType: "jsonp"
                url: "#{@gmapUrl}q=%QUERY&json_callback=?"
                filter: (data)->
                    names = []
                    filtered = []
                    angular.forEach data, (d)->
                        # Simplify display name
                        d.display_name = d.display_name.replace ', France métropolitaine', ''
                        d.display_name = d.display_name.replace ', France', ''
                        d.display_name = d.display_name.replace ', Île-de-France', ''
                        # Remove duplicated name
                        unless _.contains names, d.display_name
                            # Add the place once
                            filtered.push d
                            # Record the name to aovid duplicated
                            names.push d.display_name
                    filtered


        # initialize the bloodhound suggestion engines
        @placeEngine.initialize()
        @addrEngine.initialize()

        # ──────────────────────────────────────────────────────────────────────
        # Methods and attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        @scope.places       =
            displayKey: 'name'
            source    : @placeEngine.ttAdapter()
        @scope.addr         =
            displayKey: 'display_name'
            source    : @addrEngine.ttAdapter()
        @scope.filters      = @Filters
        @scope.shouldShowFilter = (filter)=> @shouldShowFilter is filter
        @scope.shouldShowSector = (sector)=> @shouldShowSector is sector
        # Toggle some elements
        @scope.toggleFilter = (f)=>
            @shouldShowFilter = if @shouldShowFilter is f then null else f
            # Activate the given filter
            @Filters.activate @shouldShowFilter
        @scope.toggleSector = (s)=> @shouldShowSector = if @shouldShowSector is s then null else s
        # Update map center
        @scope.setCenter    = @setCenter
        # Close single mode
        @scope.closeSingle  = => @location.search "rne", null
        # Filter map
        @scope.filterBy     = @filterBy
        @scope.removeFilter = @removeFilter
        @scope.getSectors   = @getSectors
        @scope.getFilieres  = @getFilieres
        @scope.getLevels    = @getLevels
        # Active values
        @scope.getActiveSector  = @getActiveSector
        @scope.getActiveFiliere = @getActiveFiliere
        @scope.getActiveLevel   = @getActiveLevel
        @scope.trackEmailClick  = @trackEmailClick

        # ──────────────────────────────────────────────────────────────────────
        # Watchers
        # ──────────────────────────────────────────────────────────────────────
        # Save spaces as an array (instead of an objects)
        @scope.$watch (=>@Dataset.markers), =>
            if @Dataset.markers.all?
                places = _.map _.values(@Dataset.markers.all), (place)->
                    name: place.name
                    rne: place.rne
                # Remove any previous dataset
                @placeEngine.clear()
                @placeEngine.add(places)

                # Update notfound messages
                @scope.placeNotFound = @shouldShowFilter is 'name' and _.isEmpty(@Dataset.markers.filtered)

        , yes

        @scope.$on 'typeahead:selected', (ev, val)=>
            if val?
                @rootScope.safeApply =>
                    switch @shouldShowFilter
                        when 'name'  then @filterBy 'name', val.name
                        when 'place' then @setCenter val

    setCenter: (geo)=>
        @scope.addrNotFound = no
        if geo is null
            angular.extend @Filters.centers.manual, @Filters.centers.default
            if @Dataset.markers.filtered['addr']?
                delete @Dataset.markers.filtered['addr']
        else if geo.lon?
            angular.extend @Filters.centers.manual, { lng: 1*geo.lon, lat: 1*geo.lat }
            angular.extend @Filters.centers.manual, zoom: 14
        else
            @getAddress(geo).then (results)=>
                # Take the first results (wich is the most accurate)
                geo = results[0]
                angular.extend @Filters.centers.manual, { lng: 1*geo.lon, lat: 1*geo.lat }
                angular.extend @Filters.centers.manual, zoom: 14
            # Fail
            , => @scope.addrNotFound = yes

    filterBy: (filter, value)=>
        value = value.name if value.name?
        # Hide the menu
        @shouldShowSector = null
        # Remove "sub-filter"
        switch filter
            when "sector" then @removeFilter ['filiere', 'level']
            when "filiere" then @removeFilter ['level']
        # Update filter
        @Filters.set filter, value

    removeFilter: (filters)=>
        # Hide the menu
        @shouldShowSector = null
        # Update filter
        @Filters.set filter, null for filter in filters


    # Get filters sets
    getSectors: =>
        @Dataset.tree

    getFilieres: =>
        sector   = _.findWhere @getSectors(), name: @Filters.active('sector')
        if sector? and sector.filieres? then sector.filieres else @empty

    getLevels: =>
        filiere =  _.findWhere @getFilieres(), name: @Filters.active('filiere')
        if filiere? and filiere.levels? then filiere.levels else @empty

    # Get filters displays
    getActiveSector : (alt="Tous")=> @Filters.active('sector') or alt
    getActiveFiliere: (alt="Tous")=> @Filters.active('filiere') or alt
    getActiveLevel  : (alt="Tous")=> @Filters.active('level') or alt

    getAddress: (value)=>
        deferred = do @q.defer
        return deferred.reject('No value') unless value?
        # Object value
        value = value.display_name if value.display_name?
        # Use OSM API to geocode the given address
        url = "#{@gmapUrl}&q=#{value}&json_callback=JSON_CALLBACK"
        @http.jsonp(url).then (res)=>
            if res.data.length
                deferred.resolve res.data
            else
                deferred.reject 'No result'
        return deferred.promise



angular.module('app.controller').controller "SidebarCtrl", SidebarCtrl
