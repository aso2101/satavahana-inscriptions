xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";
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
    for $place in $config:place-authority//tei:place
    let $name := 
        if ($place/tei:placeName[@type='ancient'])
        then $place/tei:placeName[@type='ancient'][1]/text()
        else $place/tei:placeName[1]/text()
    let $lat := substring-before($place/tei:geo,' ')
    let $long := substring-after($place/tei:geo,' ')
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

return $data