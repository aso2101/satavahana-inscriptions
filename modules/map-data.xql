xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

import module namespace config="localhost:8080/exist/apps/SAI/config" at "config.xqm";
import module namespace smap="localhost:8080/exist/apps/SAI/smap" at "map.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

let $filename := "map-data.geojson"
let $path := "/db/apps/SAI/resources/js/"
let $fullpath := concat($path,$filename)
let $data := 
    for $place in $config:place-authority//place
    let $name := $place/placeName[@type='ancient']
    let $lat := substring-before($place/geo,' ')
    let $long := substring-after($place/geo,' ')
    let $temp :=
        <root>
            <type>Feature</type>
            <geometry>
                <type>Point</type>
                <coordinates>[{$lat}, {$long}]</coordinates>
            </geometry>
            <properties>
                <name>{ $name/text() }</name>
                <description>{ $name/text() }</description>
                <marker-size>large</marker-size>
            </properties>
        </root>
    return
        fn:serialize($temp,
            <output:serialization-parameters>
                <output:method value="json"/>
                <output:indent value="yes"/>
                <output:media-type value="application/json"/>
            </output:serialization-parameters>)

return $data