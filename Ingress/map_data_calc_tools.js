// MAP DATA REQUEST CALCULATORS //////////////////////////////////////
// Ingress Intel splits up requests for map data (portals, links,
// fields) into tiles. To get data for the current viewport (i.e. what
// is currently visible) it first calculates which tiles intersect.
// For all those tiles, it then calculates the lat/lng bounds of that
// tile and a quadkey. Both the bounds and the quadkey are “somewhat”
// required to get complete data. No idea how the projection between
// lat/lng and tiles works.
// What follows now are functions that allow conversion between tiles
// and lat/lng as well as calculating the quad key. The variable names
// may be misleading.
// The minified source for this code was in gen_dashboard.js after the
// “// input 89” line (alternatively: the class was called “Xe”).

var DEG2RAD = Math.PI / 180;

function convertCenterLat(centerLat) {
	return Math.round(256 * 0.9999 * Math.abs(1 / Math.cos(centerLat * DEG2RAD)));
}

function calculateR(convCenterLat, zoom) {
	return 1 << zoom - (convCenterLat / 256 - 1);
}

function convertLatLngToPoint(latlng, magic, R) {
	var x = (magic/2 + latlng.lng * magic / 360)*R;
	var l = Math.sin(latlng.lat * DEG2RAD);
	var y =  (magic/2 + 0.5*Math.log((1+l)/(1-l)) * -(magic / (2*Math.PI)))*R;
	return {x: Math.floor(x/magic), y: Math.floor(y/magic)};
}

function convertPointToLatLng(x, y, magic, R) {
	var e = {};
	e.sw = {
		// orig function put together from all over the place
		// lat: (2 * Math.atan(Math.exp((((y + 1) * magic / R) - (magic/ 2)) / (-1*(magic / (2 * Math.PI))))) - Math.PI / 2) / (Math.PI / 180),
		// shortened version by your favorite algebra program.
    lat: (360*Math.atan(Math.exp(Math.PI - 2*Math.PI*(y+1)/R)))/Math.PI - 90,
    lng: 360*x/R-180
	};
	e.ne = {
		//lat: (2 * Math.atan(Math.exp(((y * magic / R) - (magic/ 2)) / (-1*(magic / (2 * Math.PI))))) - Math.PI / 2) / (Math.PI / 180),
    lat: (360*Math.atan(Math.exp(Math.PI - 2*Math.PI*y/R)))/Math.PI - 90,
    lng: 360*(x+1)/R-180
	};
	return e;
}

// calculates the quad key for a given point. The point is not(!) in
// lat/lng format.
function pointToQuadKey(x, y, zoom) {
	return zoom + "_" + x + "_" + y;;
//	var quadkey = [];
//	for(var c = zoom; c > 0; c--) {
//		//  +-------+   quadrants are probably ordered like this
//		//  | 0 | 1 |
//		//  |---|---|
//		//  | 2 | 3 |
//		//  |---|---|
//		var quadrant = 0;
//		var e = 1 << c - 1;
//		(x & e) != 0 && quadrant++;               // push right
//		(y & e) != 0 && (quadrant++, quadrant++); // push down
//		quadkey.push(quadrant);
//	}
//	return quadkey.join("");
}

// given quadkey and bounds, returns the format as required by the
// Ingress API to request map data.
function generateBoundsParams(quadkey, bounds) {
	return {
    id: quadkey,
    qk: quadkey,
    minLatE6: Math.round(bounds.sw.lat * 1E6),
    minLngE6: Math.round(bounds.sw.lng * 1E6),
    maxLatE6: Math.round(bounds.ne.lat * 1E6),
    maxLngE6: Math.round(bounds.ne.lng * 1E6)
	};
}

function test(zoom, centerLat, swLat, swLng, neLat, neLng) {

	var sw = {lat: swLat, lng: swLng};
	var ne = {lat: neLat, lng: neLng};

	var magic = convertCenterLat(centerLat);
	var R = calculateR(magic, zoom);
	
	// convert to point values
	topRight = convertLatLngToPoint(ne, magic, R);
	bottomLeft = convertLatLngToPoint(sw , magic, R);
	// how many quadrants intersect the current view?
	quadsX = Math.abs(bottomLeft.x - topRight.x);
	quadsY = Math.abs(bottomLeft.y - topRight.y);

	// will group requests by second-last quad-key quadrant
	tiles = {};

	// walk in x-direction, starts right goes left
	for (var i = 0; i <= quadsX; i++) {
		var x = Math.abs(topRight.x - i);
		var qk = pointToQuadKey(x, topRight.y, zoom);
		var bnds = convertPointToLatLng(x, topRight.y, magic, R);
		if(!tiles[qk.slice(0, -1)]) tiles[qk.slice(0, -1)] = [];
		tiles[qk.slice(0, -1)].push(generateBoundsParams(qk, bnds));

		// walk in y-direction, starts top, goes down
		for(var j = 1; j <= quadsY; j++) {
			var qk = pointToQuadKey(x, topRight.y + j, zoom);
			var bnds = convertPointToLatLng(x, topRight.y + j, magic, R);
			if(!tiles[qk.slice(0, -1)]) tiles[qk.slice(0, -1)] = [];
			tiles[qk.slice(0, -1)].push(generateBoundsParams(qk, bnds));
		}
	}

	return JSON.stringify(tiles);

}