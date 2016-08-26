/*global cordova, module*/

module.exports = {
    openFile: function (successCallback, errorCallback, filePath) {
        cordova.exec(successCallback, errorCallback, "FileOpener", "openFile", [filePath]);
    }
};