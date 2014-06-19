app = angular.module("app.config").config ["$httpProvider", ($httpProvider) ->
    # enable http caching
    $httpProvider.defaults.cache = yes
]