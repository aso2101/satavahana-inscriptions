xquery version "3.1";

(: Module for app-specific template functions :)
module namespace app="teipublisher.com/app";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace smap="localhost:8080/exist/apps/SAI/smap" at "lib/map.xql";
import module namespace facet="http://expath.org/ns/facet" at "lib/facet.xqm";
import module namespace slider = "http://localhost/ns/slider" at "lib/date-slider.xqm";

(: For SAI customization of pages.xql which does not handle current data well :)
import module namespace pages="http://www.tei-c.org/tei-simple/pages" at "lib/pages.xql";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "lib/util.xql";
import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd";
import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:  This should get everyone in the person authority file who is a King
    Currently ordered by regnal years :) 
declare function app:list-rulers($node as node(), $model as map(*)) {
    map {
        "rulers" :=
            for $ruler in $config:person-authority//tei:state[@type = 'political']
            where $ruler = 'King'
            order by xs:integer($ruler/@notAfter-custom)
            return
                $ruler/..
    }
};

declare function app:ruler($node as node(), $model as map(*), $key as xs:string) {
    let $id := substring-after($key,'pers:')
    let $ruler := $model("rulers")//id($id)
    return
        map { "ruler" := $ruler[1] }
};

declare function app:ruler-name($node as node(), $model as map(*), $type as xs:string?) {
    let $ruler := $model("ruler")
    return
        $ruler/tei:persName/text()
};

(: ~
 : This should be adopted to reflect differences in language
 : (Sanskrit v. Middle Indic). 
 : I am currently pulling this information from the @xml:lang
 : attribute of div[@type='edition'], rather than text. :)
declare function app:inscription-language($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    let $script := $inscription//tei:div[@type='edition']/@xml:lang
    let $script := if ($script eq 'san-Latn') then 'Sanskrit'
                   else if ($script eq 'pra-Latn') then 'Middle Indic'
                   else if ($script eq 'und') then 'Unknown'
                   else 'Unspecified'
    (: Obviously this will need revision at some point... :)
    return 
        $script
};

(:
 : Used by person.html
 : DEPRECATED 
:)
declare function app:person-name-revised($node as node(), $model as map(*)) {
    let $id := $model?data/@xml:id
    let $data := $model('data')
    let $key := concat('pers:',$id)
    let $names :=
        for $name in ($data//tei:persName)
        let $lang := <small class="text-muted">{ app:translate-lang($name/@xml:lang) }</small>
        let $cert := 
            if ($name/@cert = "low") then "*"
            else ""
        return
            if ($name = $data//tei:persName[1]) then <h3 class="text-left">{ $cert }{ $name/text() }{ $lang }</h3>
            else <h4 class="text-left">{ $cert }{ $name/text() }{ $lang }</h4>
    return 
        <div>
            { $names }
        </div>
};

(:~
 : Generate person name orthography from $data
 : $param $model, data passed to templating function from main query. 
:)
declare function app:person-name-orthography($node as node(), $model as map(*)) {
    let $id := $model?data/@xml:id
    let $key := concat('pers:',$id)
    let $spellings :=
        for $inscription in collection($config:remote-data-root)//tei:TEI[descendant::tei:div[@type='edition']//tei:persName[@key=$key]]
        let $idno := 
            if ($inscription//tei:publicationStmt/tei:idno) then $inscription//tei:publicationStmt/tei:idno/text()
            else $inscription//tei:idno[1]/text()
        let $namestring :=
            for $name in $inscription//tei:div[@type='edition']//tei:persName[@key=$key]
            return 
                app:flatten-app($name)
        return 
            if($inscription) then 
                <li><em>{ $namestring }</em> (<a href="/exist/apps/SAI/inscription/{$inscription/@xml:id}">{$idno}</a>)</li>
            else ()
    return
        if($spellings) then 
            <div>
                <h3>Spellings of the name:</h3>
                <ul>{ $spellings }</ul>
            </div>
        else ()
};

(:
 : Edited for use with TEI Publisher
:)
declare function app:person-relations($node as node(), $model as map(*)) {
    let $id :=  string($model?data/@xml:id)
    let $hashname := concat('#',string($id))
    (: is there a way to get relations without going to every single <relation> element? :)
    let $relations :=
        if (collection($config:remote-context-root)//tei:person[@xml:id=$id]) then
            collection($config:remote-context-root)//tei:relation[contains(@active,$id) or contains(@passive,$id) or contains(@mutual,$id)]
        else ()
    let $list := 
        for $relation in $relations
        let $type := $relation/@name
        let $label := ""
        let $data :=
            switch($type)
            case "parent" return
                (: if the person is a parent of another person :)
                if (contains($relation/@active,$hashname)) then
                    <data>
                        <label>Child</label>
                        <otherPerson>{ translate($relation/@passive,'#','') }</otherPerson>
                    </data>
                (: otherwise the other person is a parent of this person :)
                else 
                    <data>
                        <label>Parent</label>
                        <otherPerson>{ translate($relation/@active,'#','') }</otherPerson>
                    </data>
            case "teacher" return
                (: if the person is the teacher of another person :)
                if (contains($relation/@active,$hashname)) then
                    <data>
                        <label>Student</label>
                        <otherPerson>{ translate($relation/@passive,'#','') }</otherPerson>
                    </data>
                (: otherwise the other person is the teacher of this person :)
                else
                    <data>
                        <label>Teacher</label>
                        <otherPerson>{ translate($relation/@active,'#','') }</otherPerson>
                    </data>
            case "sibling" return
                <data>
                    <label>Sibling</label>
                    <otherPerson>{ translate(translate(translate($relation/@mutual,$hashname,''),' ',''),'#','') }</otherPerson>
                </data>
            case "spouse" return
                <data>
                    <label>Spouse</label>
                    <otherPerson>{ translate(translate(translate($relation/@mutual,$hashname,''),' ',''),'#','') }</otherPerson>
                </data>
            default return ""
        let $label := $data/label/text()
        let $otherperson := $data/otherPerson/text()
        let $otherpersonName :=
            if (collection($config:remote-context-root)//tei:person[@xml:id=$otherperson])
                then collection($config:remote-context-root)//tei:person[@xml:id=$otherperson][1]/tei:persName[1]/text()
            else $otherperson
        order by $type
        return <li><b>{ $label }</b>: <a href="/exist/apps/SAI/person/{ $otherperson }">{ $otherpersonName }</a></li>
    return
        if (empty($list)) then ()
        else
            <div>
                <h4>Relations with other persons:</h4>
                <ul>{ $list }</ul>
            </div>
};

declare function app:flatten-app($node as node()*) {
    let $elements :=
        for $i in $node//text()
        where not($i/ancestor::tei:rdg)
        return
            $i
    return
        normalize-space(string-join($elements,''))
};


(:  declare function app:view-facsimiles($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    return 
        if ($inscription//tei:facsimile/tei:graphic)
        then
            let $graphics := 
                for $i in $inscription//tei:facsimile/tei:graphic
                return 
                    <div class="col-lg-3 col-md-4 col-xs-6 thumb">
                        <img style="padding:1em;" src="{concat("/exist/apps/SAI-data/",$i/@url)}"></img>
                        <p>{$i/tei:desc}</p>
                    </div>
            return
                <section class="accordion">
                <div id="facsimile-container">
                    <input id="ac-2" name="accordion-2" type="checkbox"/>
                    <label for="ac-2">Facsimiles</label>
                    <article>
                        {$graphics}
                    </article>
                </div>
                </section>
        else ()
}; :)

declare function app:inscription-map($node as node(), $model as map(*)) {
    let $inscription := $model("data")
    let $placename := substring-after($inscription//tei:origPlace/tei:placeName[1]/@key,"pl:")
    let $place := 
        if ($config:place-authority//tei:place[@xml:id = $placename]) 
            then $config:place-authority//tei:place[@xml:id = $placename]
        else collection($config:place-authority-dir)//tei:place[@xml:id = $placename]
    return
        if ($place/tei:geo)
        then 
            let $lat := substring-before($place/tei:geo,' ')
            let $long := substring-after($place/tei:geo,' ')
            let $latlong := concat($long,", ",$lat)
            let $feature := 
                <json:value>
                    <type>Feature</type>
                    <geometry>
                        <place>{$place}</place>
                        <type>Point</type>
                        <coordinates json:literal="true">[{$lat},{$long}]</coordinates>
                    </geometry>
                    <properties>
                        <name>{ $place }</name>
                        <description>{ $place }</description>
                        <marker-size>large</marker-size>
                        <marker-color>#A80000</marker-color>
                    </properties>
                </json:value> 
            let $json := 
                fn:serialize($feature,
                <output:serialization-parameters>
                    <output:method value="json"/>
                    <output:indent value="yes"/>
                    <output:media-type value="application/json"/>
                </output:serialization-parameters>)
            return
            <section class="accordion map-panel">
                <div class="map-container">
                    <input id="ac-1" name="accordion-1" type="checkbox"/>
                    <label for="ac-1">Map of inscription location ({$placename})</label>
                    <article>
                        <div id="map">
                        <script type="text/javascript">
                        L.mapbox.accessToken = 'pk.eyJ1IjoiYXNvMjEwMSIsImEiOiJwRGcyeGJBIn0.jbSN_ypYYjlAZJgd4HqDGQ';
                        var geojson = {$json};
                        var bounds = L.latLngBounds(geojson);
                        var map = L.mapbox.map('map', 'aso2101.kbbp2nnh').setView([{$latlong}],8);
                        </script>
                        <script type="text/javascript" src="resources/scripts/map.js"/>
                        <ul id="marker-list"/>
                        </div>
                    </article>
               </div>
            </section>   
        else ()
};

(:  Updated search functions. :)
(:~
 : Builds query.
 : @param $query from input field
 : @param $filter select search type
:)
declare function app:query($node as node()*, $model as map(*), $query as xs:string?) as map(*) {
    (:If there is no query string, fill up the map with existing values:)
    if (empty(request:get-parameter-names()))
    (:if (empty($query)):)
        then
            map {
                "hits" := session:get-attribute("apps.sai"),
                "query" := session:get-attribute("apps.sai.query")
            }
    (: Otherwise perform the query :)
    else 
        let $facet-def := doc($config:app-root || '/search-facet-def.xml')/child::*
        let $inscriptions := concat("collection($config:remote-data-root)/tei:TEI[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))
        let $iText := concat("collection($config:remote-data-root)//tei:div[@type='apparatus'][ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))
        let $iTranslation := concat("collection($config:remote-data-root)//tei:div[@type='translation'][ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))        
        let $iCommentary := concat("collection($config:remote-data-root)//tei:div[@type='commentary'][ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))
        let $iMetadata := concat("collection($config:remote-data-root)/tei:TEI[descendant::tei:teiHeader[ft:query(.,'", $query,"', app:search-options())] or //tei:biblStruct[ft:query(.,'", $query,"', app:search-options())]]",facet:facet-filter($facet-def))        
        let $persons := concat("collection($config:remote-context-root || '/Persons')//tei:person[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))
        let $places := concat("collection($config:remote-context-root || '/Places')//tei:place[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))
        let $bibl := concat("collection($config:remote-context-root || '/Bibliography')//tei:biblStruct[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def))
        let $hits :=
            if(request:get-parameter('filter', '') = 'Inscriptions') then
                for $hit in util:eval($inscriptions)
                order by ft:score($hit) descending
                return kwic:expand($hit)
            else if(request:get-parameter('filter', '') = 'iText') then
                for $hit in util:eval($iText)
                order by ft:score($hit) descending
                return $hit
            else if(request:get-parameter('filter', '') = 'iTranslation') then
                for $hit in util:eval($iTranslation)
                order by ft:score($hit) descending
                return $hit  
            else if(request:get-parameter('filter', '') = 'iCommentary') then
                for $hit in util:eval($iCommentary)
                order by ft:score($hit) descending
                return $hit   
            else if(request:get-parameter('filter', '') = 'iMetadata') then
                for $hit in util:eval($iMetadata)
                order by ft:score($hit) descending
                return $hit                    
            else if(request:get-parameter('filter', '') = 'People') then
                for $hit in util:eval($persons)
                order by ft:score($hit) descending
                return $hit
            else if(request:get-parameter('filter', '') = 'Places') then
                for $hit in util:eval($places)
                order by ft:score($hit) descending
                return $hit
            else if(request:get-parameter('filter', '') = 'Bibliography') then
                for $hit in util:eval($bibl)
                order by ft:score($hit) descending
                return $hit
            else 
                for $hit in util:eval(concat($inscriptions,'|', $persons, '|', $places, '| ', $bibl))
                order by ft:score($hit) descending
                return $hit
        (: The hits are not returned directly, but processed by the nested templates :)
        let $store := (
            session:set-attribute("apps.sai", $hits),
            session:set-attribute("apps.sai.query", $query)
        )
        return 
            map {
                "hits" := $hits,
                "query" := $query
            }
};

(:~
 : Default search options to be passed to Lucene via ft:query()
:)
declare function app:search-options(){
    <options>
        <default-operator>and</default-operator>
        <phrase-slop>1</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

(:~
 : Create a bootstrap pagination element to navigate through the hits.
 :)
(:template function in search.html:)
declare
    %templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 10)
    %templates:default("min-hits", 0)
    %templates:default("max-pages", 10)
function app:paginate($node as node(), $model as map(*), $start as xs:int, $per-page as xs:int, $min-hits as xs:int,
    $max-pages as xs:int, $sort-options as xs:string?) {
    (if ($min-hits < 0 or count($model("hits")) >= $min-hits) then
        let $count := xs:integer(ceiling(count($model("hits"))) div $per-page) + 1
        let $middle := ($max-pages + 1) idiv 2
        (: get all parameters to pass to paging function, strip start parameter :)
        let $url-params := replace(replace(request:get-query-string(), '&amp;start=\d+', ''),'start=\d+','')
        let $param-string := if($url-params != '') then concat('?',$url-params,'&amp;start=') else '?start='
        return (
            if ($start = 1) then (
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-fast-backward"/></a>
                </li>,
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ) else (
                <li>
                    <a href="?start=1"><i class="glyphicon glyphicon-fast-backward"/></a>
                </li>,
                <li>
                    <a href="{$param-string}{max( ($start - $per-page, 1 ) ) }"><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ),
            let $startPage := xs:integer(ceiling($start div $per-page))
            let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
            let $upperBound := min(($lowerBound + $max-pages - 1, $count))
            let $lowerBound := max(($upperBound - $max-pages + 1, 1))
            for $i in $lowerBound to $upperBound
            return
                if ($i = ceiling($start div $per-page)) then
                    <li class="active"><a href="{$param-string}{max( (($i - 1) * $per-page + 1, 1) )}">{$i}</a></li>
                else
                    <li><a href="{$param-string}{max( (($i - 1) * $per-page + 1, 1)) }">{$i}</a></li>,
            if ($start + $per-page < count($model("hits"))) then (
                <li>
                    <a href="?start={$start + $per-page}"><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a href="{$param-string}{max( (($count - 1) * $per-page + 1, 1))}"><i class="glyphicon glyphicon-fast-forward"/></a>
                </li>
            ) else (
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a><i class="glyphicon glyphicon-fast-forward"/></a>
                </li>
            )
        ) else
            (),
    if($sort-options != '') then
        <li class="sort-menu"><span>
            <div class="btn-group">
                <div class="dropdown">
                <button class="btn btn-default dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-expanded="true">Sort <span class="caret"/></button>
                    <ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu1">
                        {
                            let $url-params := replace(replace(request:get-query-string(), '&amp;sort=(\w+)', ''),'sort=(\w+)','')
                            let $sort-param-string := if($url-params != '') then concat('?',$url-params,'&amp;sort=') else '?sort='
                            for $option in tokenize($sort-options,',')
                            return 
                            <li role="presentation">
                                <a role="menuitem" tabindex="-1" href="{concat($sort-param-string,$option)}">{$option}</a>
                            </li>
                        }
                    </ul>
                </div>
            </div></span>
        </li>
    else ())
};

(:  Number of hits :)
declare function app:hit-count($node as node()*, $model as map(*)) {
    <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ count($model("hits")) }</span>
};
declare function app:query-name($node as node()*, $model as map(*)) {
    <span xmlns="http://www.w3.org/1999/xhtml" id="query-name">{ $model("query") }</span>
};
declare %private function app:get-next($div as element()) {
    if ($div/tei:div) then
        if (count(($div/tei:div[1])/preceding-sibling::*) < 5) then
            app:get-next($div/tei:div[1])
        else
            $div/tei:div[1]
    else
        $div/following::tei:div[1]
};
declare %private function app:get-previous($div as element(tei:div)?) {
    if (empty($div)) then
        ()
    else
        if (
            empty($div/preceding-sibling::tei:div)  (: first div in section :)
            and count($div/preceding-sibling::*) < 5 (: less than 5 elements before div :)
            and $div/.. instance of element(tei:div) (: parent is a div :)
        ) then
            app:get-previous($div/..)
        else
            $div
};
declare %private function app:get-current($div as element()?) {
    if (empty($div)) then
        ()
    else
        if ($div instance of element(tei:teiHeader)) then
        $div
        else
            if (
                empty($div/preceding-sibling::tei:div)  (: first div in section :)
                and count($div/preceding-sibling::*) < 5 (: less than 5 elements before div :)
                and $div/.. instance of element(tei:div) (: parent is a div :)
            ) then
                app:get-previous($div/..)
            else
                $div
};

declare function local:filter-kwic($node as node(), $mode as xs:string) as xs:string? {
(:
  if ($node/ancestor::tei:div or $node/ancestor::tei:note) then 
      ()
  else:)
  if ($mode eq 'before') then 
      concat($node, ' ')
  else 
      concat(' ',$node)
};

(:~
    Output the actual search result as a div, using the kwic module to summarize full text matches.
:)

(:~
 : Format search results
 : Display and id/title/path variables all depend on type
:)
declare function app:loc($hit-root, $type, $start, $p){
let $title :=     
    if($hit-root/descendant::tei:titleStmt/tei:title) then 
        $hit-root/descendant::tei:titleStmt/tei:title[1]/text()
    else if($hit-root/tei:persName) then
        $hit-root/tei:persName[1]/text()
    else if($hit-root/tei:placeName) then
        $hit-root/tei:placeName[1]/text()        
    else if($hit-root/descendant::tei:title) then 
        $hit-root/descendant::tei:title[1]/text()   
    else (name($hit-root/child::*[1]), ' ', $hit-root/child::*[1]/text())  
return
        <tr class="reference">
            <td colspan="3">
                <span class="sai-number">{$start + $p - 1}</span>
                <span class="sai-type badge">{$type}</span>&#160;
                {app:rec-link($hit-root, $type, $title)}
            </td>
        </tr>
};

declare function app:rec-link($rec, $type, $title){
let $id := string($rec//@xml:id[1]) 
let $med := if($type = 'Bibliography') then '/bibliography/'
            else if($type = ('Person','Persons')) then '/person/'
            else if($type = ('Place','Places')) then '/place/'                    
            else '/inscription/'
let $path := concat(concat($config:app-nav-base,$med),$id)
return             
    <a href="{$path}" class="search-title">{ $title }</a>
};

(:~
 : Decode record type based on root or text/child elements
 : @param $rec record node
 :)
declare function app:rec-type($rec as node()*){
    if($rec/descendant::tei:text/tei:body/tei:biblStruct) then 'Bibliography'
    else if($rec/descendant-or-self::tei:text/tei:body/tei:listPerson or (local-name($rec/child::*[1]) = 'person')) then 'Person'
    else if($rec/descendant-or-self::tei:text/tei:body/tei:listPlace or (local-name($rec/child::*[1]) = 'place')) then 'Place'
    else 'Inscription'
};

(:~
 : HTML output for search results
 : @param $start
 : @param $per-page
 :)
declare 
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("per-page", 10)
function app:show-hits($node as node()*, $model as map(*), $start as xs:integer, $per-page as xs:integer) {
(
    for $hit at $p in subsequence($model("hits"), $start, $per-page)
    let $r := $hit
    let $root-el := root($r)
    let $type := app:rec-type($root-el)
    let $hit-root := if($type = 'Inscription') then $root-el else  $r    
    let $hit-padded := <hit>{($hit/preceding-sibling::*[1], $hit, $hit/following-sibling::*[1])}</hit>        
    let $matchId := ($hit/@xml:id, util:node-id($hit))[1]
    let $config := <config width="80" table="yes"/>
    let $kwic := kwic:summarize($hit, <config width="40"/>) (:kwic:summarize($hit-padded, $config, util:function(xs:QName("local:filter-kwic"), 2)):)
    return
        (
        app:loc($hit-root, $type, $start, $p),
        <tr class="reference">
            <td colspan="3" class="kwic">
                {$kwic}
            </td>
        </tr>
        )
)        
};


(:  Number of hits :)
declare function app:hit-count($node as node()*, $model as map(*)) {
    <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ count($model("hits")) }</span>
};

(:~
 : Extensible generic browse function. 
 : Used by Browse Inscriptions, Browse Persons, Browse Places and Browse Bibliography and Browse HTML pages
 : @param $path path to data relative to $config:remote-root, use if to browse data not in $config:remote-data-root, or to browse a subset of $config:remote-data-root
 : @param $type data type accepted values, defaults to Inscription 'Bibliography|Person|Place|Inscription'
 : @param $facets path to facet-definition file relative to $config:app-root
 : @param $date-slider include date slider, date type to use 'bibl|inscriptions'
:) 
declare function app:browse($node as node()*, $model as map(*), 
    $path as xs:string?, 
    $type as xs:string?, 
    $facets as xs:string?, 
    $date-slider as xs:string?) {
    map {
                "config" := map { "odd": $config:odd },
                "hits" := 
                    let $browse-path := 
                        if($path != '') then ($config:remote-root || $path)                            
                        else $config:remote-data-root    
                    let $abc-filter := 
                            if($type = ('Place','Places')) then 
                               app:abc-filter('descendant::tei:placeName[1]/text()')
                            else if($type = ('Person','Persons','People')) then
                                app:abc-filter('descendant::tei:persName[1]/text()')
                            else app:abc-filter('descendant::tei:titleStmt/tei:title[1]/text()')
                    let $facet-filter :=  
                        if($facets != '') then
                            if(doc($config:app-root || '/' || $facets)) then
                                facet:facet-filter(doc($config:app-root || '/' || $facets))
                            else ()
                        else ()
                    let $slider-filter := 
                        if($date-slider != '') then
                            slider:date-filter($date-slider)
                        else ()
                    let $filter-ids :=  
                        if($type = ('Place','Places')) then
                            if(request:get-parameter('places-in-places', '') = ('true','show')) then 
                                collection($config:remote-context-root || '/Places')//tei:place[1] | collection($config:remote-context-root || '/Places')//tei:place[1]/descendant::tei:place
                            else collection($config:remote-context-root || '/Places')//tei:place[1] 
                        else if($type = ('Person','Persons','People')) then
                            collection($config:remote-context-root || '/Persons')//tei:person[1]
                        else if($type = 'Bibliography') then
                            collection($config:remote-context-root || '/Bibliography')//tei:biblStruct[1]
                        else ()  
                   let $hits := 
                        if($filter-ids != '') then
                            for $h in $filter-ids
                            let $id := $h//@xml:id[1]
                            return 
                                <hit id="{$id}">
                                    {
                                        let $i :=                                                     
                                           if($type = 'Bibliography') then 
                                                for $inscription in collection($config:remote-data-root)//tei:TEI[.//tei:bibl/tei:ptr[@target = concat('bibl:',$id)]]
                                                return 
                                                    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{string($inscription/@xml:id)}">{($inscription/tei:teiHeader, $inscription//tei:div[@type='edition'][@xml:lang])}</TEI>
                                           else if($type = 'Persons') then  
                                                for $inscription in collection($config:remote-data-root)//tei:TEI[.//tei:persName[@key = concat('pers:',$id)]]
                                                return 
                                                    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{string($inscription/@xml:id)}">{($inscription/tei:teiHeader, $inscription//tei:div[@type='edition'][@xml:lang])}</TEI>
                                           else if($type = 'Places') then
                                                for $inscription in collection($config:remote-data-root)//tei:TEI[.//tei:placeName[@key = concat('pl:',$id)]]
                                                return 
                                                    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{string($inscription/@xml:id)}">{($inscription/tei:teiHeader, $inscription//tei:div[@type='edition'][@xml:lang])}</TEI>                                                    
                                           else ()                                                     
                                        return ($h,$i)
                                    }
                                </hit> 
                        else
                            for $h in collection($browse-path)
                            return 
                                <hit>{$h}</hit>   
                  for $h in util:eval(concat("$hits",$abc-filter,$facet-filter,$slider-filter)) 
                  let $sortOrder := 
                        if(request:get-parameter('sort', '') != '') then 
                            if(request:get-parameter('sort', '') = 'date') then
                                $h/descendant::tei:date[1]
                            else if(request:get-parameter('sort', '') = 'author') then     
                                if($h/descendant::tei:author[1]) then 
                                    $h/descendant::tei:author[1]
                                else $h/descendant::tei:editor[1]
                            else $h/descendant::tei:titleStmt[1]/descendant::tei:title[1]
                        else if($type = 'Places') then 
                            $h/descendant::tei:place[1]/tei:placeName[1]
                        else if($type = 'Persons') then
                            $h/descendant::tei:person[1]/tei:persName[1]
                        else $h/descendant::tei:titleStmt[1]/descendant::tei:title[1]
                  order by $sortOrder
                  return $h  
        }   
};

(:~
 : HTML output for browse hits. Includes paging and sorting. 
 : @param $start default 1 
 : @param $per-page default 10
 : @param $type data type accepted values, defaults to Inscription 'Bibliography|Persons|Places|Inscriptions'
:)
declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
function app:browse-display-hits($node as node()*, $model as map(*), $start as xs:integer, $per-page as xs:integer, $type as xs:string?) {
    for $p in subsequence($model("hits"), $start, $per-page)
    let $docNode := $p
    (:let $html := $pm-config:web-transform($docNode, map { "root": root($docNode) },$model?config?odd):)
    let $title := 
        if($type='Places') then
            $p/descendant::tei:place[1]/descendant::tei:placeName[1]/text()
        else if($type='Persons') then
            $p/descendant::tei:person[1]/descendant::tei:persName[1]/text()           
        else if($p/descendant::tei:title[@type='short']) then
            $p/descendant::tei:title[@type='short'][1]/text()
        else $p/descendant::tei:title[1]/text()
    let $html := 
        <h4>{app:rec-link($p, $type, $title)}
            {
            if($p/tei:person/tei:sex/@value) then  concat(' (',string-join($p/tei:person/tei:sex/@value,' '),') ')
            else()
            }
        </h4>
    let $id := 
        if($type='Bibliography') then 
            $p/descendant::tei:biblStruct/@xml:id
        else if($type='Places') then
            $p/descendant::tei:place[1]/@xml:id
        else if($type='Persons') then
            $p/descendant::tei:person[1]/@xml:id            
        else $p/@xml:id
    let $ref-id := 
        if($type='Bibliography') then 
            concat('bibl:',$id)
        else if($type='Places') then
            concat('pl:',$id)
        else if($type='Persons') then
            concat('pers:',$id)
        else $id
    let $inscriptions := app:view-hits($p/descendant::tei:TEI, $ref-id)
    let $related-records :=
        if ($inscriptions) then 
            <div class="row mentions">
                <div class="col-sm-12">
                    <p>Mentioned in these records:</p>
                    <div class="indent">
                        {$inscriptions}
                    </div>
                </div>
            </div>
        else ()    
    return 
        <li class="list-group-item">
          { $html }{ $related-records }
        </li>
};


(:~
 : Show browse hits. 
 : @param $start default 1 
 : @param $per-page default 10
:)
declare function app:browse-hits($node as node()*, $model as map(*)) {
    for $key in distinct-values($model("hits")//descendant::tei:origPlace/tei:placeName[1]/@key)
    let $name := 
        if (contains($key,'pl:')) then substring-after($key,'pl:')
        else $key
    let $id := xs:NCName($name)
    let $inscriptions := $model("hits")[descendant::tei:origPlace/tei:placeName[1][@key = $key]]
    order by $name
    return 
     <div id="place-{$key}">
        <!--<a id="{$name}"></a>-->
        <h4 class="placeName" id="{$name}">{string(replace($key,'pl:',''))}</h4>
        {
                app:view-hits($inscriptions, $key)
        }
    </div>     
};

(:~
 : Browse results table
 : Uses javascript for dynamic sorting.
 : Called by app:browse-hits 
:)
declare function app:view-hits($inscriptions, $placeId){
    (<table class="table" id="{$placeId}">
        <thead>
            <tr>
                <th class="col-md-2"><button class="btn-link">ID <span class="caret"/></button></th>
                <th><button class="btn-link">Name <span class="caret"/></button></th>
                <th class="col-md-2"><button class="btn-link">Type <span class="caret"/></button></th>
                <th class="col-md-2"><button class="btn-link">Language <span class="caret"/></button></th>
                <th class="col-md-2"><button class="btn-link">Date <span class="caret"/></button></th>
            </tr>
        </thead>
        <tbody id="results">
            {
                for $i in $inscriptions
                let $id := string($i//@xml:id[1])
                let $title := $i/descendant::tei:title[1]/text()
                let $type := string-join($i/descendant::tei:profileDesc/tei:textClass/tei:keywords/tei:term,', ')
                let $lang := app:translate-lang(string($i/descendant::tei:div[@type='edition'][1]/@xml:lang))
                let $date-text := $i/descendant::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/text()
                (: Deal with dates for sorting... if notBefore... :)
                let $date := $i/descendant::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore-custom
                order by $title
                return 
                    <tr>
                        <td data-sort="{$id}">{$id}</td>
                        <td data-sort="{$title}">{app:rec-link($i,'inscription', $title)}</td>
                        <td data-sort="{$type}">{$type}</td>
                        <td data-sort="{$lang}">{$lang}</td>
                        <td data-sort="{$date}">{$date-text}</td>
                    </tr>
                }
            </tbody>
    </table>,
    <script type="text/javascript">
        <![CDATA[
            $(document).ready(function() {
               var table = document.getElementById(']]>{$placeId}<![CDATA[')
                    ,tableHead = table.querySelector('thead')
                    ,tableHeaders = tableHead.querySelectorAll('th')
                    ,tableBody = table.querySelector('tbody')
                ;
                tableHead.addEventListener('click',function(e){
                    var tableHeader = e.target
                        ,textContent = tableHeader.textContent
                        ,tableHeaderIndex,isAscending,order
                    ;
                    if (textContent!=='add row') {
                        while (tableHeader.nodeName!=='TH') {
                            tableHeader = tableHeader.parentNode;
                        }
                        tableHeaderIndex = Array.prototype.indexOf.call(tableHeaders,tableHeader);
                        isAscending = tableHeader.getAttribute('data-order')==='asc';
                        order = isAscending?'desc':'asc';
                        tableHeader.setAttribute('data-order',order);
                        tinysort(
                            tableBody.querySelectorAll('tr')
                            ,{
                                selector:'td:nth-child('+(tableHeaderIndex+1)+')'
                                ,attr:"data-sort"
                                ,order: order
                            }
                        );
                    }
                });
            });
        ]]>
    </script>)
};

(:
 : Apply abc filter to get record by first letter matching abc filter.
 : @param $node tei node to apply filter to. 
 : @NOTE May need to add filters for accented letters?
:)
declare function app:abc-filter($node){
 if(request:get-parameter('abc-filter', '') != '') then
    if(request:get-parameter('abc-filter', '') = 'ALL') then () 
    else 
     concat('[',$node,'[matches(., "^',request:get-parameter('abc-filter', ''),'")]]')
 else()
};

(:~
 : Browse Alphabetical Menu
 : Used by browse pages: people.html, places.html, bibliography.html
:)
declare %templates:wrap function app:browse-abc-menu($node as node(), $model as map(*)){
    for $letter in tokenize('A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ALL', ' ')
    return 
        <li role="presentation"
            class="{if(request:get-parameter('abc-filter', '') = string($letter)) then 'active' else 'clickable'}">
            <a href="?abc-filter={$letter}">{$letter}</a>
        </li>
};

(:~
 : General/Browse facets  
 : Uses facet definitions in facet-def.xml
 : Used by browse.html
 : @see facet library lib/facet.xqm
 : @param $node nodes to be faceted on, passed from search and browse
 : @param $facet-def facet-definition file, passed from html page. 
:)
declare function app:display-facets($node as node(), $model as map(*), $facets as xs:string?) {
    let $hits := $model("hits")
    let $facet-def := doc($config:app-root || '/' || $facets)
    return
        if($facet-def) then 
            facet:html-list-facets-as-buttons(facet:count($hits, $facet-def/descendant::facet:facet-definition))
        else 'No matching facet definition file.'
};

(:~
 : Simple toggle button to show places within places
:)
declare function app:places-within-places($node as node(), $model as map(*)){
    (<h4>Places Within Places</h4>,
     <form action="places.html">
        <div class="btn-group btn-toggle places-in-places"> 
            <button class="{if(request:get-parameter('places-in-places', '') = 'show') then 'btn btn-info active' else 'btn btn-default'}" value="show" name="places-in-places">Show</button>
            <button class="{if(request:get-parameter('places-in-places', '') = 'hide') then 'btn btn-info active' else 'btn btn-default'}" value="hide" name="places-in-places">Hide</button>
        </div>                                
    </form>)
};

declare function app:dynamic-map-data($node as node(), $model as map(*)){
    if($model("hits")//tei:geo) then 
        for $p in $model("hits")//tei:geo
        return root($p)
    else if($model("places")//tei:geo) then
       for $p in $model("places")//tei:geo
       return root($p) 
    else 
        let $data := if($model("places")) then $model("places") else if($model("persons")) then $model("persons") else if($model("data")) then $model("data") else $model("hits") 
        let $places := if($model("places") | $model("persons")) then distinct-values($data//tei:placeName/@key | $data/@xml:id) else distinct-values($data//tei:origPlace/tei:placeName/@key | $data/@xml:id) 
        for $p in $places
        let $id := 
                if (contains($p,'pl:')) then substring-after($p,'pl:')
                else $p
        for $place in collection(replace($config:remote-data-root,'/data','/contextual/Places'))//@xml:id[. = $id]
        let $p := root($place)
        return $p
};

(:~ 
 : Builds map HTML and javascript elements 
 : Uses dynamic data based on page data 
:)
declare function app:map($node as node(), $model as map(*)) { 
    if(not(empty(app:dynamic-map-data($node, $model)))) then 
        
    <section class="map">
        <div class="panel panel-default">             
            <div class="panel-heading">
                <h4 class="panel-title">
                    <a class="accordion-toggle" data-toggle="collapse" href="#collapse-map-panel">Map</a><hr/>
                </h4>
            </div>
            <div id="collapse-map-panel" class="panel-collapse collapse in">
                 <div class="panel-body">                    
                    <div id="map"/>
                    <script type="text/javascript">
                        L.mapbox.accessToken = 'pk.eyJ1IjoiYXNvMjEwMSIsImEiOiJwRGcyeGJBIn0.jbSN_ypYYjlAZJgd4HqDGQ';
                        var geojson = {smap:create-data(app:dynamic-map-data($node,$model))};
                        var map = L.mapbox.map('map', 'aso2101.kbbp2nnh')
                    </script>
                    <script type="text/javascript" src="resources/scripts/map.js"/>
                    <ul id="marker-list"/>
                </div>
            </div>
        </div>
    </section>
    else ()
};

(:~
 : Date slider pulls functions from lib/date-slider.xqm
 : Build Javascript Date Slider. 
 : $param @model data passed from initial query
 : @param $mode selects which date element to use for filter. Current modes are 'inscription' and 'bibl'
:)
declare function app:browse-date-slider($node as node(), $model as map(*), $mode as xs:string?){   
    slider:browse-date-slider($model("hits"), $mode)
};
                    
(:~
 : Translate language code to text value, accepts langague code string
:)
declare function app:translate-lang($lang-code as xs:string*){
    if($lang-code = ('san-Latn','sa-Latn')) then 'Sanskrit'
    else if($lang-code = ('pra-Latn','mi-Latn')) then 'Middle Indic'
    else if($lang-code = ('und','xx')) then 'Unknown'
    else if ($lang-code eq 'mar-Latn') then 'Marathi'
    else if ($lang-code eq 'kan-Latn') then 'Kannada'
    else if ($lang-code eq 'hin-Latn') then 'Hindi'
    else ''
};


(: Special handling for SAI - Returns whole TEI record :)
declare
    %templates:wrap
function app:load($node as node(), $model as map(*), $doc as xs:string?, $root as xs:string?,
    $id as xs:string?, $view as xs:string?) {
    let $doc := xmldb:decode($doc)
    let $data :=
        if ($id) then
            let $node := collection($config:remote-root)//id($doc) 
            let $config := tpu:parse-pi($node, $view)
            return 
                map {
                    "config": $config,
                    "data": $node       
                }
        else app:load-xml($view, $root, $doc)
    let $node :=
        if ($data?data) then
            $data?data
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
            "config": $data?config,
            "data": $node
        }
        
};

(: Special handling for SAI - Returns whole TEI record :)
declare function app:load-xml($view as xs:string?, $root as xs:string?, $doc as xs:string) {
    let $data := app:get-document($doc)
    let $config := tpu:parse-pi(root($data), $view)
    return
        map {
            "config": $config,
            "data": $data
        }
};

declare function app:get-document($idOrName as xs:string) {
    collection($config:remote-root)//id($idOrName)
};

(:~
 : SAI custom function to display specific child nodes via the TEI Publisher
 : Allows more flexibility in display, as nodes can be moved around, or filtered through additional XQueries 
 : @para $node  
:)
declare function app:display-node($node as node(), $model as map(*), $path as xs:string?) {
let $docNode := if($path != '' and $path != 'root()') then util:eval(concat("$model?data/",$path)) else $model?data
let $html := $pm-config:web-transform($docNode, map { "root": root($docNode) }, $model?config?odd)
return 
    if(not(empty($docNode))) then 
        $html
    (:
        <div class="map panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">title</h3>
            </div>
            <div class="panel-collapse collapse in" id="map-panel">
                {$html}
            </div>
        </div>    
      :)  
    else ()
};
(: this is jugar, since the modal can't be programmatically placed at the bottom of the page
 : due to the templating functions, and so it's covered by the backdrop. i've made the backdrop
 : transparent in the css, but it would be nice to fix this for real. :)
declare function app:display-modal($node as node(), $model as map(*), $path as xs:string?) {
let $docNode := if($path != '' and $path != 'root()') then util:eval(concat("$model?data/",$path)) else $model?data
let $html := $pm-config:web-transform($docNode, map { "modal" : "true" }, $model?config?odd)
return 
    if(not(empty($docNode))) then $html else ()
};

(: PYU function adapted for SAI :)
declare function app:display-tabs($node as node(), $model as map(*), $path as xs:string?) {
    let $odd := $model?config?odd
    let $tabs := array {"Logical","Physical","XML"}
    let $status := if ($tabs = 'Logical') then 'active' else ()
    return 
    if(not(empty(util:eval(concat("$model?data/",$path))))) then 
        <div class="{$config:css-content-class}">
    		<!-- heading -->
            <h3>Edition</h3>
            <!-- tab card -->
            <div class="card card-nav-tabs card-plain">        	
            	<div class="header header-success">
    	        	<!-- colors: "header-primary", "header-info", "header-success", "header-warning", "header-danger" -->
    	        	<div class="nav-tabs-navigation">
    	        		<div class="nav-tabs-wrapper">       	
    			            <ul class="nav nav-tabs" role="tablist" data-tabs="tabs">
    			                <li role="presentation" class="{$status}"><a href="#{$tabs?1}" aria-controls="..." role="tab" data-toggle="tab">{$tabs?1}</a></li>
    			                <li role="presentation"><a href="#{$tabs?2}" aria-controls="profile" role="tab" data-toggle="tab">{$tabs?2}</a></li>
    			                <li role="presentation"><a href="#{$tabs?3}" aria-controls="profile" role="tab" data-toggle="tab">{$tabs?3}</a></li>
    			            </ul>
    					</div>
    				</div>
    			</div>
    		</div>
            <div class="card-content">
                <div class="tab-content">
                    {   
                        for $i in 1 to array:size($tabs) 
                        let $tabId := $tabs($i)
                        return
                            app:process-content-tabs($node,$model, $path, $tabId,$odd)
                    }
                </div>
    		</div>		
    	</div>  
    else ()
	   
};

declare function app:process-content-tabs($node as node(), $model as map(*),$path as xs:string?, $tabId as xs:string, $odd as xs:string) {
    let $docNode := util:eval(concat("$model?data/",$path))
    let $html := $pm-config:web-transform($docNode, map { "root": root($docNode), "break":$tabId}, $model?config?odd)
    let $class := if ($html//*[@class = ('margin-note')]) then "margin-right" else ()
    let $body := pages:clean-footnotes($html)
    let $status := if ($tabId = 'Logical') then ' active' else ()
    return
        <div role="tabpanel" class="tab-pane{$status}" id="{$tabId}">
        {
            $body,
            if ($html//li[@class="footnote"]) then
                <div class="footnotes">
                    <ol>
                    {
                        for $note in $html//li[@class="footnote"]
                        order by number($note/@value)
                        return
                            $note
                    }
                    </ol>
                </div>
            else
                ()
        }       
        </div>        
};


(:~
 : Get related inscriptions. 
 : Used in person.html, bibl.html and place.html
:)
declare function app:related-inscriptions($node as node(), $model as map(*)) {
    let $doc := $model?data
    let $type := 
        if(name($doc) = 'person') then 
            'person'
        else if(name($doc) = 'place') then 
            'place'   
        else if($doc/descendant::tei:body/tei:text/tei:biblStruct or name($doc) = 'biblStruct') then 
            'bibl'               
        else 'inscription'
    let $key := 
        if($type='person') then 
            concat('pers:',string($doc/@xml:id))
        else if($type='place') then 
            concat('place:',string($doc/@xml:id))   
        else if($type='bibl') then 
            concat('bibl:',string($doc/@xml:id))               
        else $doc/@xml:id
    let $inscriptions := if($type='bibl') then 
                            collection($config:remote-data-root)//tei:TEI[descendant::tei:div[@type='bibliography']//@target=$key]
                         else collection($config:remote-data-root)//tei:TEI[descendant::tei:div[@type='edition']//@key=$key]
    let $places := 
        for $placekey in distinct-values($inscriptions//tei:origPlace/tei:placeName[1]/@key)
        let $name := 
            if (contains($placekey,'pl:')) then substring-after($placekey,'pl:')
            else $placekey
        let $inscriptions-by-place := $inscriptions[descendant::tei:placeName[@key=$placekey]]
        order by $name
        return 
            <div>
                <h4>{ $name }</h4>
                {
                    app:view-hits($inscriptions-by-place, $placekey)
                }
            </div>
    return 
        if($places) then 
            <div>
                <h4>Mentioned in these inscriptions:</h4>
                { $places }
            </div>
        else ()
};

(: SAI version of page title, handles titles for persons/places/bibliography items and inscriptions :)
declare
    %templates:wrap
function app:navigation-title($node as node(), $model as map(*)) {
    let $id := string($model?data/@xml:id)
    let $data := $model('data')
    let $idspan :=
        if ($id) then
            <span class="small pull-right">ID: { $id }</span>
        else ()
    let $teiLink := concat(request:get-uri(),'.xml')
    let $teispan := 
            <span class="small pull-right" style="margin:-.25em .5em;"><a href="{$teiLink}"><img src="{$config:app-nav-base}/resources/images/tei-25.png"/></a></span>    
    let $main-title := 
        if (name($data) = 'person') then 
            $data//tei:persName[1]/text()
        else if (name($data) = 'place') then 
            $data//tei:placeName[1]/text()
        else if ($data//tei:title) then
            $data//tei:title[1]/text()
        else ()
    return 
        <h3 class="text-center">{ $main-title } {$teispan} { $idspan }</h3>
        
};


declare function app:section-custom($node as element(),$model as map(*),$path as xs:string?,$title as xs:string) {
    <div id="metadata-panel">
        <section>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">
                        <a class="accordion-toggle" data-toggle="collapse" href="#collapse-metadata">{$title}</a>
                        <hr/>
                    </h4>
                </div>
                <div id="collapse-metadata" class="panel-collapse collapse in">
                    <div class="panel-body">
                        {app:display-node($node,$model,$path)}
                    </div>
                </div>
            </div>
        </section>
    </div>
};