xquery version "3.0";

module namespace smap="localhost:8080/exist/apps/SAI/smap";
import module namespace config="localhost:8080/exist/apps/SAI/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";

(:  This function builds the JSON data from the place authority
    file. This means that the geodata needs to be specified in the
    place authority file if it's going to be presented on the map. :)
declare function smap:create-data() as xs:string* {
    for $place in collection($config:remote-context-root)//tei:place
    where $place//tei:geo
    return 
        let $name := 
            if ($place/tei:placeName[@type='ancient'])
            then $place/tei:placeName[@type='ancient'][1]/text()
            else $place/tei:placeName[1]/text()
        let $lat := substring-before($place//tei:geo,' ')
        let $long := substring-after($place//tei:geo,' ')
        let $temp :=
            <root>
                <type>Feature</type>
                <geometry>
                    <type>Point</type>
                    <coordinates>[{$lat},{$long}]</coordinates>
                </geometry>
                <properties>
                    <name>{ $name }</name>
                    <description>{ $name }</description>
                    <marker-size>large</marker-size>
                    <marker-color>#A80000</marker-color>
                </properties>
            </root>
        (: This is a pain in the ass, because eXist-DB puts in quotes
            that need to be removed :)
        return 
            concat(replace(replace(fn:serialize($temp,
                <output:serialization-parameters>
                    <output:method value="json"/>
                    <output:indent value="yes"/>
                    <output:media-type value="application/json"/>
                </output:serialization-parameters>),'&#34;\[','['),'\]&#34;',']'),',')
};

(:  This function builds the JSON data from the place authority
    file. This means that the geodata needs to be specified in the
    place authority file if it's going to be presented on the map. :)
declare function smap:create-data($data as node()*) as xs:string* {
    for $place in $data//tei:place
    where $place//tei:geo
    return 
        let $name := 
            if ($place/tei:placeName[@type='ancient'])
            then $place/tei:placeName[@type='ancient'][1]/text()
            else $place/tei:placeName[1]/text()
        let $lat := substring-before($place//tei:geo,' ')
        let $long := substring-after($place//tei:geo,' ')
        let $temp :=
            <root>
                <type>Feature</type>
                <geometry>
                    <type>Point</type>
                    <coordinates>[{$lat},{$long}]</coordinates>
                </geometry>
                <properties>
                    <name>{ $name }</name>
                    <description>{ $name }</description>
                    <marker-size>large</marker-size>
                    <marker-color>#A80000</marker-color>
                </properties>
            </root>
        (: This is a pain in the ass, because eXist-DB puts in quotes that need to be removed :)
        return 
            concat(replace(replace(fn:serialize($temp,
                <output:serialization-parameters>
                    <output:method value="json"/>
                    <output:indent value="yes"/>
                    <output:media-type value="application/json"/>
                </output:serialization-parameters>),'&#34;\[','['),'\]&#34;',']'),',')
};

declare function smap:draw-map($node as node(),$model as map(*)) {
    (: This automatically loads the map using the mapbox JS. :)
    <div id="map">
        <script type="text/javascript">
L.mapbox.accessToken = 'pk.eyJ1IjoiYXNvMjEwMSIsImEiOiJwRGcyeGJBIn0.jbSN_ypYYjlAZJgd4HqDGQ';

var geojson = [{ smap:create-data() }];

var map = L.mapbox.map('map', 'aso2101.kbbp2nnh')
    .setView([20.217, 74.083], 8); // centers on Nasik
        </script>
        <script type="text/javascript" src="/exist/apps/SAI/resources/js/map.js"/>
    </div>
};