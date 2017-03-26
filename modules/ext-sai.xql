(:
 : Copyright 2015, Wolfgang Meier
 :
 : This software is dual-licensed:
 :
 : 1. Distributed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
 : http://creativecommons.org/licenses/by-sa/3.0/
 :
 : 2. http://www.opensource.org/licenses/BSD-2-Clause
 :
 : All rights reserved. Redistribution and use in source and binary forms, with or without
 : modification, are permitted provided that the following conditions are met:
 :
 : * Redistributions of source code must retain the above copyright notice, this list of
 : conditions and the following disclaimer.
 : * Redistributions in binary form must reproduce the above copyright
 : notice, this list of conditions and the following disclaimer in the documentation
 : and/or other materials provided with the distribution.
 :
 : This software is provided by the copyright holders and contributors "as is" and any
 : express or implied warranties, including, but not limited to, the implied warranties
 : of merchantability and fitness for a particular purpose are disclaimed. In no event
 : shall the copyright holder or contributors be liable for any direct, indirect,
 : incidental, special, exemplary, or consequential damages (including, but not limited to,
 : procurement of substitute goods or services; loss of use, data, or profits; or business
 : interruption) however caused and on any theory of liability, whether in contract,
 : strict liability, or tort (including negligence or otherwise) arising in any way out
 : of the use of this software, even if advised of the possibility of such damage.
 :)
xquery version "3.1";

(:~
 : Template functions to handle page by page navigation and display
 : pages using TEI Simple.
 :)
module namespace sai="http://localhost/sai/ext";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace expath="http://expath.org/ns/pkg";

import module namespace app="http://www.tei-c.org/tei-simple/templates" at "app.xql";
import module namespace pages="http://www.tei-c.org/tei-simple/pages" at "pages.xql";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";
import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd" at "../../tei-simple/content/odd2odd.xql";
import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util" at "../../tei-simple/content/util.xql";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
(: SAI extention functions :)
import module namespace facet="http://expath.org/ns/facet" at "lib/facet.xqm";
import module namespace smap="localhost:8080/exist/apps/SAI/smap" at "lib/map.xql";

(:
import module namespace slider = "http://localhost/ns/slider" at "lib/date-slider.xqm";
:)

(: 
 : Inscription/record view functions, adapted from pages.xql
 : Updated getting of document root, is buggy in pages.xql
:)
declare
    %templates:wrap
function sai:load($node as node(), $model as map(*), $doc as xs:string, $root as xs:string?, 
    $id as xs:string?, $view as xs:string?) {
    let $doc := xmldb:decode($doc)
    let $view := if ($view) then $view else $config:default-view
    let $node := 
        if ($id) then
            let $node := doc($config:data-root || "/" || $doc)/id($id)
            let $div := $node/ancestor-or-self::tei:div[1]
            return
                if (empty($div)) then
                    $node/following-sibling::tei:div[1]
                else
                    $div
        else
            pages:load-xml($view, $root, $doc)
    let $node :=
        if ($node) then
            $node
        else
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <teiHeader>
                    <fileDesc>
                        <titleStmt>
                            <title>Not found</title>
                        </titleStmt>
                    </fileDesc>
                </teiHeader>
                <text>
                    <body>
                        <div>
                            <head>Failed to load!</head>
                            <p>Could not load document {$doc}. Maybe it is not valid TEI or not in the TEI namespace?</p>
                        </div>
                    </body>
                </text>
            </TEI>//tei:div
    return
        map {
            "data": $node
        }
};

(:~
 : Get specified xml node and pass to page view. (BUGGY)
 : @param $node eXist templating param
 : @param $model eXist templating param
 : @param $xpath xpath to xml node accepts single value. 
:)
declare
    %templates:wrap
function sai:view-node($node as node(), $model as map(*), $xpath as xs:string?) {
    let $doc := $model?data
    let $path:= if($xpath != '') then concat('$doc','//',$xpath) else '$doc'
    return util:eval($path)
    (:$pm-config:web-transform(util:eval($path), map { 
            "teiHeader-type": "epidoc",
            "doc": $id
        }, $config:odd)
        :)
};

(:
 : SAI browse functions
:)

(:~
 : General/Browse facets  
 : Uses facet definitions in facet-def.xml
 : Used by browse.html
 : @see facet library lib/facet.xqm
 : @param $node nodes to be faceted on, passed from search and browse
 : @param $facet-def facet-definition file, passed from html page. 
:)
declare function sai:display-facets($node as node(), $model as map(*), $facet-def as xs:string?) {
    let $hits := $model?all
    let $facet-def := doc($config:app-root || '/' || $facet-def)
    return 
        if($facet-def) then 
            facet:html-list-facets-as-buttons(facet:count($hits, $facet-def/descendant::facet:facet-definition))
        else 'No matching facet definition file.'
};

(:~
 : Display map on html page
:)
declare function sai:map($node as node(), $model as map(*)) { 
    if(not(empty(sai:dynamic-map-data($node, $model)))) then 
        <div id="map">
            <script type="text/javascript">
                L.mapbox.accessToken = 'pk.eyJ1IjoiYXNvMjEwMSIsImEiOiJwRGcyeGJBIn0.jbSN_ypYYjlAZJgd4HqDGQ';
                smap:create-data($data)
                var geojson = [{smap:create-data(sai:dynamic-map-data($node,$model))}];
                var bounds = L.latLngBounds(geojson);
                var map = L.mapbox.map('map', 'aso2101.kbbp2nnh'); // centers on Nasik
                
                //map.fitBounds(geojson.getBounds());
            </script>
            <script type="text/javascript" src="resources/scripts/map.js"/>
            <!--<script type="text/javascript" src="{$config:app-root}/resources/scripts/map.js"/>-->
        </div>
    else ()

};

declare function sai:dynamic-map-data($node as node(), $model as map(*)){
    if($model("hits")//tei:geo) then 
        for $p in $model("hits")//tei:geo
        return root($p)
    else if($model("places")//tei:geo) then 
        for $p in $model("places")//tei:geo
        return root($p)        
    else if($model?all) then 
        let $places := distinct-values($model?all//tei:placeName/@key)
        for $p in $places
        let $id := 
                if (contains($p,'pl:')) then substring-after($p,'pl:')
                else $p
        for $place in collection(replace($config:remote-data-root,'/data','/contextual/Places'))//@xml:id[. = $id]
        let $p := root($place)
        return $p
    else
        let $places := distinct-values($model("hits")//tei:placeName/@key)
        for $p in $places
        let $id := 
                if (contains($p,'pl:')) then substring-after($p,'pl:')
                else $p
        for $place in collection(replace($config:remote-data-root,'/data','/contextual/Places'))//@xml:id[. = $id]
        let $p := root($place)
        return $p
};