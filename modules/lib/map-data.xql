xquery version "3.1";

declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";
(:
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";
:)
import module namespace config="http://www.tei-c.org/tei-simple/config" at "../config.xqm";
import module namespace smap="localhost:8080/exist/apps/SAI/smap" at "map.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

let $filename := "map-data.geojson"
let $path := "/db/apps/SAI/resources/js/"
let $fullpath := concat($path,$filename)
let $places := collection('/db/apps/SAI-data/contextual/Places')//tei:place
let $data := 
    <root>
        <type>FeatureCollection</type>
        <features>
        {
            for $place in collection($config:remote-context-root)//tei:place
            where $place//tei:geo
            let $name := 
                if ($place/tei:placeName[@type='ancient']) then 
                    $place/tei:placeName[@type='ancient'][1]/text()
                else $place/tei:placeName[1]/text()
            let $lat := substring-before($place/tei:geo,' ')
            let $long := substring-after($place/tei:geo,' ')
            return
                <json:value>
                    <type>Feature</type>
                    <geometry>
                        <place>{$name}</place>
                        <type>Point</type>
                        <coordinates json:literal="true">[{$lat},{$long}]</coordinates>
                    </geometry>
                    <properties>
                        <name>{ $name }</name>
                        <description>{ $name }</description>
                        <marker-size>large</marker-size>
                        <marker-color>#A80000</marker-color>
                    </properties>
                </json:value>
        }        
      </features>
    </root>   
return fn:serialize($data,
            <output:serialization-parameters>
                <output:method value="json"/>
                <output:indent value="yes"/>
                <output:media-type value="application/json"/>
            </output:serialization-parameters>)