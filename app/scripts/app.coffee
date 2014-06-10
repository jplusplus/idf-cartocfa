angular.module('app.constant',  [])
angular.module('app.config',    [])
angular.module('app.controller',[])
angular.module('app.directive', [])
angular.module('app.filter',    [])
angular.module('app.service',   [])

app = angular.module 'app', [
    # Angular dependencies
    "ngRoute"
    "ngResource"
    "ngAnimate"
    "ngSanitize"
    "leaflet-directive"
    "truncate"
    # Internal dependencies
    "app.constant"
    "app.controller"
    "app.config"
    "app.filter"
    "app.service"
    "app.directive"
]
# EOF