class SidebarCtrl
    @$inject: ['$scope', '$rootScope', '$q', '$http', '$location', 'Filters', 'Dataset']
    constructor: (@scope, @rootScope, @q, @http, @location, @Filters, @Dataset)->
        @empty = []
        # Filter to display
        @shouldShowFilter = 'sector'
        @shouldShowSector = null

        # instantiate the bloodhound suggestion engine for places
        @placeEngine = new Bloodhound(
            datumTokenizer: (d) ->
                Bloodhound.tokenizers.whitespace (d.rne or "") + "_" + (d.name or "")
            queryTokenizer: Bloodhound.tokenizers.whitespace
            local: []
        )

        # instantiate the bloodhound suggestion engine for addr from GoogleMap
        @addrEngine = new Bloodhound(
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("value")
            queryTokenizer: Bloodhound.tokenizers.whitespace
            remote:
                url: "http://maps.googleapis.com/maps/api/geocode/json?address=%QUERY,Île-de-France, France"
                filter: (data)->
                    if data.results.length and
                       data.results[0].formatted_address is "Île-de-France, France"
                        # No result
                        return []
                    else
                        return data.results
        )


        # initialize the bloodhound suggestion engines
        @placeEngine.initialize()
        @addrEngine.initialize()

        # ──────────────────────────────────────────────────────────────────────
        # Methods and attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        @scope.places       = []
        @scope.addr         =
            displayKey: 'formatted_address'
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
                # Bind placeEngine to the scope
                @scope.places =
                    displayKey: 'name',
                    source: @placeEngine.ttAdapter()

                # Update notfound messages
                @scope.placeNotFound = @shouldShowFilter is 'name' and _.isEmpty(@Dataset.markers.filtered)

        , yes

        @scope.$on 'typeahead:selected', (ev, val)=>
            if val?
                @rootScope.safeApply =>
                    switch @shouldShowFilter
                        when 'name'  then @filterBy 'name', val.name
                        when 'place' then @setCenter val

    trackEmailClick: (cfa)->
        window.ga 'send', 'event', 'button', 'click', "#{cfa.rne} - #{cfa.name}"

    setCenter: (geo)=>
        @scope.addrNotFound = no
        if geo is null
            angular.extend @Filters.centers.manual, @Filters.centers.default
            if @Dataset.markers.filtered['addr']?
                delete @Dataset.markers.filtered['addr']
        else if geo.geometry?
            angular.extend @Filters.centers.manual, geo.geometry.location
            angular.extend @Filters.centers.manual, zoom: 14
        else
            @getAddress(geo).then (results)=>
                if results.length
                    geometry = results[0].geometry
                    angular.extend @Filters.centers.manual, geometry.location
                    angular.extend @Filters.centers.manual, zoom: 14
                else
                    @scope.addrNotFound = yes

    filterBy: (filter, value)=>
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
        params = address: value + ", Île-de-France", sensor: no
        # Use Google Map's API to geocode the given address
        url = "http://maps.googleapis.com/maps/api/geocode/json"
        @http.get(url, params: params).then (res)->
            if res.data.results?
                if res.data.results.length and
                res.data.results[0].formatted_address is "Île-de-France, France"
                    # No result
                    res.data.results = []
                deferred.resolve res.data.results
            else
                deferred.reject 'No result'
        return deferred.promise



angular.module('app.controller').controller "SidebarCtrl", SidebarCtrl
