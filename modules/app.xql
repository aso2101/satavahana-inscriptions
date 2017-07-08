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
import module namespace search="http://www.tei-c.org/tei-simple/search" at "search.xql";
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

declare function app:list-inscriptions-by-ruler($node as node(), $model as map(*)) {
    map {
        "inscriptions" :=
            let $ruler := $model("ruler")/@xml:id
            let $key := concat('pers:',$ruler)
            for $inscription in collection($config:remote-data-root)//tei:TEI
            where $inscription//tei:persName[@key=$key]
            order by $inscription//tei:origDate/@notBefore-custom
                return $inscription
    }  
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

(:~
 : Used by person.html  
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
                <h3>Relations with other persons:</h3>
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

(:
    Search functions
    Right now these are more or less modelled on SARIT's search function.
:)

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
        let $context := collection($config:remote-data-root)/tei:TEI
        let $hits :=
            if(request:get-parameter('filter', '') = 'translation') then
                let $hits := util:eval(concat("$context//tei:div[@type='translation'][ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def)))
                for $hit in $hits
                order by ft:score($hit) descending
                return $hit
            else if(request:get-parameter('filter', '') = 'metadata') then
                let $persons-data := collection(replace($config:remote-data-root,'/data','/contextual/Persons'))//tei:person
                let $places-data := collection(replace($config:remote-data-root,'/data','/contextual/Places'))//tei:place
                (: Change to contextual/Bibliography when data has been moved :)
                let $bibl-data := collection(replace($config:remote-data-root,'/data','/contextual'))//tei:biblStruct
                let $path := concat(
                        "($persons-data[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$places-data[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$bibl-data[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$context//tei:teiHeader[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$context//tei:div[@type='bibliography'][ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$context//tei:div[@type='commentary'][ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),")"
                    )
                let $hits := util:eval($path)
                for $hit in $hits
                order by ft:score($hit) descending
                return $hit                
            else if(request:get-parameter('filter', '') = 'text') then 
                for $hit in util:eval(concat("$context[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def)))
                order by ft:score($hit) descending
                return $hit
            else    
                let $persons-data := collection(replace($config:remote-data-root,'/data','/contextual/Persons'))//tei:person
                let $places-data := collection(replace($config:remote-data-root,'/data','/contextual/Places'))//tei:place
                let $bibl-data := collection(replace($config:remote-data-root,'/data','/contextual'))//tei:bibl
                let $path := concat(
                        "($persons-data[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$places-data[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$bibl-data[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),
                        ",$context[ft:query(.,'", $query,"', app:search-options())]",facet:facet-filter($facet-def),")"
                    )
                let $hits := util:eval($path)
                for $hit in $hits
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
    $max-pages as xs:int) {
    if ($min-hits < 0 or count($model("hits")) >= $min-hits) then
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
            ()
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
    else if($hit-root/descendant::tei:title) then 
        $hit-root/descendant::tei:title[1]/text()
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

(:~
 : Build link to record view used by app:loc(), app:person-browse-hits(), app:view-hits()
:)
declare function app:rec-link($rec, $type, $title){
let $id := string($rec//@xml:id[1]) 
let $med := if($type = 'Bibliography') then 'bibliography/'
            else if($type = 'Person') then 'person/'
            else if($type = 'Place') then 'place/'                    
            else 'inscription/'
let $path := concat(concat('/exist/apps/SAI/',$med),$id)
return             
    <a href="{$path}" class="search-title">{ $title }</a>
};

(:~
 : Decode record type based on root or text/child elements
 : @param $rec record node
 :)
declare function app:rec-type($rec as node()*){
let $root-el := root($rec)
return
    if(($root-el/name(.) = ('TEI','teiHeader')) or ($root-el/child::*/name(.) = ('TEI','teiHeader'))) then 'Inscription'
    else if($root-el/child::*/name(.) = 'biblStruct') then 'Bibliography'
    else if($root-el/child::*/name(.) = 'person') then 'Person'
    else if($root-el/child::*/name(.) = 'place') then 'Place'
    else $root-el/child::*/name(.)
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
    let $hit-root := if($type = 'Inscription') then root($r) else  $r    
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
 : Extensible generic browse function. gets all results adds them to 'hits' map
 : Used by Browse Inscriptions, Browse Persons, Browse Places and Browse Bibliography HTML pages
 : @param $path path to data relative to $config:remote-root
 : @param $type data type accepted values, defaults to Inscription 'Bibliography|Person|Place|Inscription'
 : @param $facets path to facet-definition file relative to $config:app-root
 : @param $date-slider include date slider, date type to use 'bibl|inscriptions'
:)
declare function app:browse($node as node()*, $model as map(*), $path as xs:string?, $type as xs:string?, $facets as xs:string?, $date-slider as xs:string?) {
    map {
            "hits" := 
                    let $browse-path := 
                        if($path != '') then ($config:remote-root || $path) 
                        else $config:remote-data-root    
                    let $abc-filter := 
                            if($type = 'Place') then 
                               app:abc-filter('descendant::tei:placeName[1]/text()')
                            else if($type = 'Person') then
                                app:abc-filter('descendant::tei:persName[1]/text()')
                            else app:abc-filter('descendant::tei:titleStmt/tei:title[1]/text()')
                    let $facet-filter :=  
                        if($facets != '') then
                            if(doc($config:app-root || $facets)) then
                                facet:facet-filter(doc($config:app-root || $facets))
                            else ()
                        else ()
                    let $slider-filter := 
                        if($date-slider != '') then
                            slider:date-filter($date-slider)
                        else ()
                  let $hits := util:eval(concat("collection($browse-path)",$abc-filter,$facet-filter,$slider-filter))  
                  for $h in $hits 
                   let $sortOrder := 
                        if($type = 'Place') then 
                            $h/descendant::tei:placeName[1]
                        else if($type = 'Person') then
                            $h/descendant::tei:persName[1]
                        else $h/descendant::tei:titleStmt/descendant::tei:title[1]
                   order by $sortOrder
                   return $h 
            } 
};


(:~
 : HTML output for browse hits. Includes paging and sorting. 
 : @param $start default 1 
 : @param $per-page default 10
 : @param $type data type accepted values, defaults to Inscription 'Bibliography|Person|Place|Inscription'
:)
declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
function app:browse-display-hits($node as node()*, $model as map(*), $start as xs:integer, $per-page as xs:integer, $type as xs:string?) {
    for $p in subsequence($model("hits"), $start, $per-page)
    let $docNode :=
        if($type='Bibliography') then 
            $p/descendant::tei:biblStruct[1]            
        else $p
    let $html := $pm-config:web-transform($docNode, map { "root": root($docNode) },$model?config?odd)
    let $id := 
        if($type='Bibliography') then 
            $p/descendant::tei:biblStruct/@xml:id
        else if($type='Place') then
            $p/descendant::tei:place[1]/@xml:id
        else if($type='Person') then
            $p/descendant::tei:person[1]/@xml:id            
        else $p/@xml:id
    let $ref-id := 
        if($type='Bibliography') then 
            concat('bibl:',$id)
        else if($type='Place') then
            concat('pl:',$id)
        else if($type='Person') then
            concat('pers:',$id)
        else $id
    let $inscriptions := 
        for $i in collection($config:remote-data-root)//tei:TEI[.//tei:bibl/tei:ptr[@target=$ref-id] or .//@key[. = $ref-id]]
        return <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{string($i/@xml:id)}">{($i/tei:teiHeader, $i//tei:div[@type='edition'][@xml:lang])}</TEI>
    let $related-records :=
        if ($inscriptions) then 
            <div class="row mentions">
                <div class="col-sm-12">
                    <p>Mentioned in these records:</p>
                    <div class="indent">
                        {app:view-hits($inscriptions, $ref-id)}
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
 : Browse Bibliography
:)
declare function app:browse-bibl-data($node as node(), $model as map(*), $view as xs:string?) {
    map {
                "config" := map { "odd": $config:odd },
                "hits" := 
                    let $browse-path := concat($config:remote-root,'/contextual/Bibliography')
                    let $facet-def :=  doc($config:app-root || '/browse-bibl-facet-def.xml')
                    for $i in util:eval(concat("collection($browse-path)/tei:TEI",app:abc-filter('descendant::tei:titleStmt/tei:title[1]/text()'),facet:facet-filter($facet-def),slider:date-filter('bibl')))
                    order by $i//tei:titleStmt/tei:title[1]
                    return $i
        }  
};

(:~
 : Browse inscriptions  
 : Group inscriptions by place/@key
 : @sort  
:)
declare function app:browse-get-inscriptions($node as node(), $model as map(*)) {
    map {
                "config" := map { "odd": $config:odd },
                "hits" := 
                    let $facet-def := doc($config:app-root || '/browse-facet-def.xml')
                    for $i in util:eval(concat("collection($config:remote-data-root)//tei:TEI",facet:facet-filter($facet-def),slider:date-filter('inscriptions')))
                    return $i
        }  
};

(:~
 : Browse inscriptions group by places  
 : Group inscriptions by place/@key
 : @sort  
:)
declare function app:browse-get-places($node as node(), $model as map(*)){
    map {
                "config" := map { "odd": $config:odd },
                "places" := 
                    let $places := distinct-values($model("hits")//descendant::tei:origPlace/tei:placeName/@key)
                    for $p in $places
                    let $id := 
                                if (contains($p,'pl:')) then substring-after($p,'pl:')
                                else $p
                    for $place in collection($config:remote-context-root || '/Places')//@xml:id[. = $id]
                    let $p := root($place)
                    return $p
        }  
};

(:~
 : Browse persons with inscriptions 
:)
declare function app:browse-get-persons($node as node(), $model as map(*)){
    map {
                "hits" := 
                    let $pids := distinct-values(collection($config:remote-data-root)//tei:persName/@key)
                    let $persons := 
                        for $person in $pids
                        return 
                            <person id="{$person}">
                                {
                                    let $p := collection($config:remote-context-root)//tei:person[@xml:id= replace($person,'pers:','')]
                                    let $i := 
                                        for $inscription in collection($config:remote-data-root)//tei:TEI[.//tei:persName[@key= $person]]
                                        return 
                                        <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{string($inscription/@xml:id)}">{($inscription/tei:teiHeader, $inscription//tei:div[@type='edition'][@xml:lang])}</TEI> 
                                    return ($p,$i)
                                }
                            </person>  
                            (:
                            $hit[matches(substring(global:build-sort-string(.,$browse:computed-lang),1,1),browse:get-sort(),'i')]
                            :)
                    let $facet-def := doc($config:app-root || '/browse-person-facet-def.xml')
                    for $i in util:eval(concat("$persons",app:abc-filter('tei:person[1]/tei:persName[1]'),facet:facet-filter($facet-def)))
                    let $name := $i//tei:person[1]/tei:persName[1]
                    order by $name
                    return $i
        }     
};

(:~
 : Show browse hits. 
 : @param $start default 1 
 : @param $per-page default 10
:)
declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
function app:bibl-browse-hits($node as node()*, $model as map(*), $start as xs:integer, $per-page as xs:integer) {
    for $p in subsequence($model("hits"), $start, $per-page)
    let $docNode := util:eval("$p//tei:biblStruct[1]")
    let $html := $pm-config:web-transform($docNode, map { "root": root($docNode) },$model?config?odd)
    let $id := $p/descendant::tei:biblStruct/@xml:id
    let $bibl-id := concat('bibl:',$id)
    let $title := $p/descendant::tei:titleStmt/tei:title[1]/text()
    let $inscriptions := 
        for $i in collection($config:remote-data-root)//tei:TEI[.//tei:bibl/tei:ptr[@target=$bibl-id]]
        return <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{string($i/@xml:id)}">{($i/tei:teiHeader, $i//tei:div[@type='edition'][@xml:lang])}</TEI>
    let $related-records :=
        if ($inscriptions) then 
            <div class="row mentions">
                <div class="col-sm-12">
                    <p>Mentioned in these records:</p>
                    <div class="indent">
                        {app:view-hits($inscriptions, $bibl-id)}
                    </div>
                </div>
            </div>
        else ""
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
declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
function app:person-browse-hits($node as node()*, $model as map(*), $start as xs:integer, $per-page as xs:integer) {
    for $p in subsequence($model("hits"), $start, $per-page)
    let $id := 
        if (contains($p/@id,'pers:')) then xs:NCName(substring-after($p/@id,'pers:'))
        else xs:NCName($p)
    let $name := 
        if ($p/tei:person/tei:persName[1]) then $p/tei:person/tei:persName[1]/text()
        else $id
    order by $id
    return 
     <div id="pers-{$id}">
        <h4>{app:rec-link($p, 'Person', $name)}
            {
            if($p/tei:person/tei:sex/@value) then  concat(' (',string-join($p/tei:person/tei:sex/@value,' '),') ')
            else()
            }
        </h4>
        {(
            if($p/tei:person/tei:residence/tei:placeName) then
                    <p>{concat('From ', $p/tei:person/tei:residence/tei:placeName/text(), '. ')}</p>
            else(),
            if($p/tei:person/descendant::tei:state or $p/tei:person/descendant::tei:trait or $p/tei:person/descendant::tei:faith) then
                <p>Identifiers: 
                    {
                        let $identifiers := $p/tei:person/descendant::tei:state | 
                                  $p/tei:person/descendant::tei:trait |
                                  $p/tei:person/descendant::tei:faith
                        let $last := count($identifiers)
                        for $i at $pos in $identifiers
                        return 
                        (<span class="person-identifiers">{$i/text()} {if($i/@type) then concat(' [',string($i/@type),'] ') else ()}</span>, if($i[$pos != $last]) then ', ' else())                                 
                    }
                </p>
            else()
        )}
        <p>Mentioned in these inscriptions:</p>
        <div class="indent">
        {app:view-hits($p/descendant::tei:TEI, $id)}
        </div>
    </div>     
};

(:~
 : Show browse hits. 
 : @param $start default 1 
 : @param $per-page default 10
:)
declare function app:browse-hits($node as node()*, $model as map(*)) {
    for $key in distinct-values($model("hits")//descendant::tei:origPlace/tei:placeName/@key)
    let $name := 
        if (contains($key,'pl:')) then substring-after($key,'pl:')
        else $key
    let $id := xs:NCName($name)
    let $inscriptions := $model("hits")[descendant::tei:placeName[@key = $key]]
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
 : Browse results table for inscriptions by place. 
 : Uses javascript for dynamic sorting within table.
 : Called by app:browse-hits 
 : @param $inscriptions results of browse filter
 : @param $placeID place id for sorted inscriptions
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
                let $id := string($i/@xml:id)
                let $title := $i/descendant::tei:title[1]/text()
                let $type := $i/descendant::tei:profileDesc/tei:textClass/tei:keywords/tei:term/text()
                let $lang := app:translate-lang(string($i/descendant::tei:div[@type='edition'][1]/@xml:lang))
                let $date-text := $i/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/text()
                (: Deal with dates for sorting... if notBefore... :)
                let $date := $i/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore-custom
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

(:~
 : Simple ABC filter on first letter in sort element
 : May need to add filters for accented letters?
 : @param $node element to filter by
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
declare function app:display-facets($node as node(), $model as map(*), $facet-def as xs:string?) {
    let $hits := $model("hits")
    let $facet-def := doc($config:app-root || '/' || $facet-def)
    return
        if($facet-def) then 
            facet:html-list-facets-as-buttons(facet:count($hits, $facet-def/descendant::facet:facet-definition))
        else 'No matching facet definition file.'
};

(:~
 : Build dynamic map data for variouse result sets. 
:)
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

declare function app:map($node as node(), $model as map(*)) { 
    if(not(empty(app:dynamic-map-data($node, $model)))) then 
        <div class="map panel panel-default">
           <div class="panel-heading">
               <h3 class="panel-title">Map<a class="pull-right" data-toggle="collapse" data-target="#map-panel" href="#" title="show/hide map">&#160;</a></h3>
           </div>
           <div class="panel-collapse collapse in" id="map-panel">
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
    else ()
};

(:~
 : Date slider pulls functions from lib/date-slider.xqm
 : Build Javascript Date Slider. 
 : $param $model data in map
 : $param $mode bibl|inscription changes what dates should be used by the slider.
 : bibl option uses publication date
 : inscription option uses descendant::tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate
:)
declare function app:browse-date-slider($node as node(), $model as map(*)){   
    slider:browse-date-slider($model("hits"))
};
                    
(:~
 : Translate language code to text value, accepts langague code string
 : @param $lang-code as a string.
:)
declare function app:translate-lang($lang-code as xs:string*){
    if($lang-code = ('san-Latn','sa-Latn')) then 'Sanskrit'
    else if($lang-code = ('pra-Latn','mi-Latn')) then 'Middle Indic'
    else if($lang-code = ('und','xx')) then 'Unknown'
    else if ($lang-code eq 'mar-Latn') then 'Marathi'
    else if ($lang-code eq 'kan-Latn') then 'Kannada'
    else if ($lang-code eq 'hin-Latn') then 'Hindi'
    else if ($lang-code eq 'und') then 'Unknown'
    else ''
};

(:SAI customizations for view.html pages :)
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
:)
declare function app:related-inscriptions($node as node(), $model as map(*)) {
    let $doc := $model?data
    let $id := string($doc/@xml:id)
    let $type := 
        if($doc/descendant::tei:body/tei:text/tei:body/tei:listPerson or name($doc) = 'person') then
            'person'
        else if($doc/descendant::tei:body/tei:text/tei:body/tei:listPlace or name($doc) = 'place') then
            'place'   
        else if($doc/descendant::tei:body/tei:text/tei:biblStruct or name($doc) = 'biblStruct') then 
            'bibl'               
        else 'inscription'
    let $key := 
        if($type='bibl') then
            concat('bibl:',$id)
        else if($type='place') then
            concat('pl:',$id)
        else if($type='person') then
            concat('pers:',$id)
        else $id
    let $inscriptions := if($type='bibl') then 
                            collection($config:remote-data-root)//tei:TEI[descendant::tei:div[@type='bibliography']//@target=$key]
                         else if($type = 'place') then
                            collection($config:remote-data-root)//tei:TEI[descendant::tei:origPlace/tei:placeName/@key=$key]
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
                <h3>Mentioned in these records:</h3>
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
        if($data//tei:title) then
            $data//tei:title[1]/text()
        else if(name($data) = 'person') then 
            $data//tei:persName[1]/text()
        else if(name($data) = 'place') then 
            $data//tei:placeName[1]/text()
        else ()
    return 
        <h3 class="text-center">{ $main-title } {$teispan} { $idspan }</h3>
        
};
