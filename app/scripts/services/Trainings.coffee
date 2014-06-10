angular.module("app.service").factory("Trainings", [
    '$http',
    '$rootScope',
    'icons',
    'Filters',
    ($http, $rootScope, icons, Filters)->
        new class Trainings
            tree   : []
            markers: {}
            # ─────────────────────────────────────────────────────────────────
            # Public method
            # ─────────────────────────────────────────────────────────────────
            constructor:->
                $http.get('data/training.json').success @generateTree
                $http.get('data/rne-coord.json').success @generateMarkers


            generateMarkers: (data)=>
                all = {}
                angular.forEach data, (place)=>
                    all[place.rne] =
                        lat : 1*place.lat
                        lng : 1*place.lng
                        icon: icons.default

                angular.extend @markers,
                    all     : all
                    filtered: all

            generateTree: (data)=>
                sectors = _.uniq(_.pluck(data, 'sector'))
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
