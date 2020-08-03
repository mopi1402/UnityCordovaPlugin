var exec = require('cordova/exec');

exports.testPlugin = function (arg0, success, error) {
    exec(success, error, 'UnityCordova', 'testPlugin', [arg0]);
};

exports.initUnity = function (success, error) {
    exec(success, error, 'UnityCordova', 'initUnity');
};
