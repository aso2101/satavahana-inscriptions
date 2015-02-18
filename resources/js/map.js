var myLayer = L.mapbox.featureLayer()
    .addTo(map);
    
myLayer.on('layeradd', function(e) {
    var marker = e.layer,
        feature = marker.feature;

    // Create custom popup content
    var popupContent =  '<a href="#' + feature.properties.name + '">' + feature.properties.name + '</a>';

    // http://leafletjs.com/reference.html#popup
    marker.bindPopup(popupContent);
});

myLayer.setGeoJSON(geojson);

map.featureLayer.on('ready', function(e) {
    myLayer.eachLayer(function(layer) {
        var name = layer.feature.properties.name;
        if (typeof document.getElementById(name) != 'undefined') {
            var span = document.getElementById(name);
            var a = document.createElement("a");
            var linkText = document.createTextNode("(show on map)");
            var b = document.createTextNode(" ");
            a.appendChild(linkText);
            a.href = "javascript:void();";
            span.appendChild(b);
            span.appendChild(a);
            a.onclick = function() {
                map.setView(layer.getLatLng());
                layer.openPopup();
                location.hash = '#';
            };
        } 
        else { }
    });
});

myLayer.on('mouseover', function(e) {
    e.layer.openPopup();
});

function panto(e) {
    myLayer.eachLayer(function(layer) {
        var name = layer.feature.properties.name;
        if (e == name) {
            try {
                map.setView(layer.getLatLng());
                layer.openPopup();
                location.hash = '#';
            }
            catch(err) { 
                alert(err.message); 
            }
        }
    });
}