//Add geojson to myLayer
var myLayer = L.mapbox.featureLayer(geojson).addTo(map);

// Add popup to marker
myLayer.eachLayer(function(marker) {
    var feature = marker.feature;
    
    // Create custom popup content
    var popupContent =  '<a href="#' + feature.properties.name + '">' + feature.properties.name + '</a>';
            
    // http://leafletjs.com/reference.html#popup
    marker.bindPopup(popupContent);
    
});
        
myLayer.on('mouseover', function(e) {
    e.layer.openPopup();
});

$( document ).on('ready', function(e) {
    myLayer.eachLayer(function(layer) {
        var name = layer.feature.properties.name;
        var spans = document.getElementsByClassName(name);
        if (typeof spans != 'undefined') {
            for (i = 0; i<spans.length; i++) {
                var span = spans.item(i);
                var a = document.createElement("a");
                var b = document.createTextNode(" ");
                var linkText = document.createTextNode("(show on map)");
                a.appendChild(linkText);
                a.href = "javascript:void();";
                a.onclick = function() {
                    map.setView(layer.getLatLng());
                    layer.openPopup();
                    location.hash = '#';
                };
                span.appendChild(b);
                span.appendChild(a);
            }
        }
    });
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

map.fitBounds(myLayer.getBounds(),{maxZoom: 7});

function addLinksToPlace() {
    var spans = document.getElementsByClassName(placeName);
    if (typeof spans != 'undefined') {
        for (i = 0; i<spans.length; i++) {
            var span = spans.item(i);
            var a = document.createElement("a");
            var b = document.createTextNode(" ");
            var linkText = document.createTextNode("(show on map)");
            a.appendChild(linkText);
            a.href = "javascript:void();";
            a.onclick = function() {
                map.setView(layer.getLatLng());
                layer.openPopup();
                location.hash = '#';
            };
            span.appendChild(b);
            span.appendChild(a);
        }
    }
}
