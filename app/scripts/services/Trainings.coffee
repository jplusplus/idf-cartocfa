angular.module("app.service").factory("Trainings", ['$http', ($http)->
    new class Trainings
        # ─────────────────────────────────────────────────────────────────
        # Public method
        # ─────────────────────────────────────────────────────────────────
        constructor: ->       
            $http.get('data/training.json').success (data)=> 
                tree    = {}
                sectors = _.uniq(_.pluck(data, 'sector'))
                for sector in sectors
                    dataBySector = _.where(data, 'sector': sector)
                    filieres = _.uniq(_.pluck(data, 'filiere'))
                    for filiere in filieres                        
                        tree[sector][filiere] = null
])
