angular.module('app.constant',  [])
angular.module('app.config',    ['ngRoute',  'ngSanitize', 'app.constant', 'app.service'])
angular.module('app.controller',['ngResource', 'app.constant', 'app.filter'])
angular.module('app.directive', ['ngResource', 'app.constant'])
angular.module('app.filter',    ['ngResource', 'app.constant'])
angular.module('app.service',   ['ngResource', 'app.constant'])

app = angular.module 'app', [
    # Angular dependencies
    "ngRoute"
    "ngResource"
    "ngAnimate"
    "ngSanitize"
    # Internal dependencies
    "app.constant"
    "app.config"
    "app.filter"
    "app.service"
    "app.directive"
]
# EOF