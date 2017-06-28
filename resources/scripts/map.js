//Add geojson to myLayer
var myLayer = L.mapbox.featureLayer(geojson).addTo(map);

//Trigger popup 
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

//Add links to placeNames that appear on the map
$(document).ready(function() {
    //Center and fit all markers on map
    map.fitBounds(myLayer.getBounds(),{maxZoom: 6});
    //Create popups for markers and create links on page to markers
    myLayer.eachLayer(function(marker) {
        var feature = marker.feature;
        var name = feature.properties.name
        // Create custom popup content
        var popupContent =  '<a href="#' + name + '">' + name + '</a>';  
        // http://leafletjs.com/reference.html#popup
        marker.bindPopup(popupContent);
        $('#' + name).each(function(){
            $(this).append(' <a href="' + $(this).html() + '" class="small panto">(show on map)</a> ');
        });
    });
    //trigger panto() function from place titles to map markers. 
    $( ".panto" ).click(function(e) {
      e.preventDefault();
      location.href = "#map";
      panto($(this).attr('href'));
    });
});