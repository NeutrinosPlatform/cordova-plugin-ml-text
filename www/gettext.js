/*global cordova, module*/

// module.exports = {
//     getText: function (sourceType, returnType, imageSource, successCallback, errorCallback) {
//         cordova.exec(successCallback, errorCallback, "Mltext", "getText", [sourceType, returnType, imageSource]);
//     }
// };

module.exports = {
    getText: function (successCallback, errorCallback, options) {
    	options = options || {};
    	var imgType = options.imgType || 0;	// 0 NORMFILEURI, 1 NORMNATIVEURI, 2 FASTFILEURI, 3 FASTNATIVEURI, 4 BASE64
		//options.recType = options.recType || 0; // 0 for normal text recognition, 1 for document text recognition
		
	
    	if(options.imgSrc)
    	{
			var imgType = options.imgType || 0;
			var imgSrc = options.imgSrc;
			var args = [imgType, imgSrc];
			
        	cordova.exec(successCallback, errorCallback, "Mltext", "getText", args);
    	}
    	else
    	{
    		alert("No Uri or Base64 passed into the plugin. Please provide a value for imgsrc");
    	}
    }
};