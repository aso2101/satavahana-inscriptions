xquery version "3.0";

module namespace app="localhost:8080/exist/apps/SAI/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="localhost:8080/exist/apps/SAI/config" at "config.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace smap="localhost:8080/exist/apps/SAI/smap" at "map.xql";
import module namespace tei-to-html="localhost:8080/exist/apps/SAI/tei2html" at "tei2html.xql";

declare namespace expath="http://expath.org/ns/pkg";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ti="http://chs.harvard.edu/xmlns/cts3/ti";
declare namespace h="http://www.w3.org/1999/xhtml";
declare namespace functx="http://www.functx.com";

(:
 : Much of this code is adapted from the SARIT project,
 : which was the inspiration for this database. :)

declare function app:generate-place-entry($id as xs:string,$name as xs:string) {
    if ($id instance of xs:NCName)
    then 
        <place xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$id}">
            <placeName>{ $name }</placeName>
        </place>
    else 
        <place xmlns="http://www.tei-c.org/ns/1.0">
            <placeName>{ $name } (not a valid NCName)</placeName>
        </place>
};
declare function app:generate-person-entry($id as xs:string,$name as xs:string) {
    if ($id instance of xs:NCName)
    then 
        <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$id}">
            <persName>{ $name }</persName>
        </person>
    else
        <person xmlns="http://www.tei-c.org/ns/1.0">
            <persName>{ $name } (not a valid NCName)</persName>
        </person>
};

(: This lists all of the places mentioned anywhere in the corpus. :)
declare function app:list-places($node as node(), $model as map(*)) {
    map {
        "places" :=
            for $key in distinct-values(collection($config:remote-data-root)//tei:placeName/@key)
            let $name := 
                if (contains($key,'pl:'))
                then substring-after($key,'pl:')
                else $key
            let $id := xs:NCName($name)
            order by $name
            return
                (:  I am excluding place-names that aren't either find-spots 
                    or mentioned in the text. :)
                if (collection($config:remote-data-root)//tei:div[@type='edition']//tei:placeName[@key=$key] or
                    collection($config:remote-data-root)//tei:origPlace//tei:placeName[1][@key=$key])
                then app:generate-place-entry($id,$id)
                else ()
    }  
};

(:  This returns a list of <place> nodes for all of the places mentioned in the
    TEXT of inscriptions. :)
declare function app:list-places-mentioned($node as node(), $model as map(*)) {
    map {
        "places" :=
            for $key in distinct-values(collection($config:remote-data-root)//tei:div[@type='edition']//tei:placeName/@key)
            let $name := 
                if (contains($key,'pl:'))
                then substring-after($key,'pl:')
                else $key
            let $id := xs:NCName($name)
            order by $name
            return app:generate-place-entry($id,$name)
    }  
};

(:  This returns a list of <place> nodes for all of the places mentioned as the
    LOCATION where inscriptions are found :)
declare function app:list-places-location($node as node(), $model as map(*)) {
    map {
        "places" :=
            for $key in distinct-values(collection($config:remote-data-root)//tei:origPlace//tei:placeName/@key)
            let $name := 
                if (contains($key,'pl:'))
                then substring-after($key,'pl:')
                else $key
            let $id := xs:NCName($name)
            order by $name
            return app:generate-place-entry($id,$name)
    }  
};


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

declare function app:place($node as node(), $model as map(*), $key as xs:string) {
    let $id := substring-after($key,'pl:')
    let $place := $model("places")//id($id)
    return
        map { "place" := $place[1] }
};

declare function app:ruler($node as node(), $model as map(*), $key as xs:string) {
    let $id := substring-after($key,'pers:')
    let $ruler := $model("rulers")//id($id)
    return
        map { "ruler" := $ruler[1] }
};

declare function app:place-name($node as node(), $model as map(*)) {
    let $place := $model("place")
    let $text :=
        if ($place//tei:placeName[@type='ancient'])
        then $place//tei:placeName[@type='ancient'][1]/text()
        else $place//tei:placeName/text()
    return
        if (contains(request:get-url(),'places.html'))
        then 
            <span class="{$text}">{$text}<a id="{$text}"/></span>
        else 
            <a href="places.html#{$text}" id="{$text}"><span class="{$text}">{$text}</span></a>
};

declare function app:ruler-name($node as node(), $model as map(*), $type as xs:string?) {
    let $ruler := $model("ruler")
    return
        $ruler/tei:persName/text()
};

(: Trying to get this to sort by date. :)
declare function app:list-inscriptions($node as node(), $model as map(*)) {
  map {
     "inscriptions" := 
        for $inscription in collection($config:remote-data-root)//tei:TEI
        order by 
            if ($inscription//tei:origDate/@when-custom)
            then xs:integer($inscription//tei:origDate/@when-custom)
            else xs:integer($inscription//tei:origDate/@notBefore-custom)
        return
            $inscription
  }  
};

declare function app:list-inscriptions-by-place-mentioned($node as node(), $model as map(*)) {
    map {
        "inscriptions" :=
            let $place := $model("place")/@xml:id
            let $key := concat('pl:',$place)
            for $inscription in collection($config:remote-data-root)//tei:TEI
            where $inscription//tei:div[@type='edition']//tei:placeName[@key=$key]
            order by 
                if ($inscription//tei:origDate/@when-custom)
                then xs:integer($inscription//tei:origDate/@when-custom)
                else xs:integer($inscription//tei:origDate/@notBefore-custom)
            return $inscription
    }  
};
declare function app:list-inscriptions-by-place-location($node as node(), $model as map(*)) {
    map {
        "inscriptions" :=
            let $place := $model("place")/@xml:id
            let $key := concat('pl:',$place)
            for $inscription in collection($config:remote-data-root)//tei:TEI
            where $inscription//tei:origPlace//tei:placeName[@key=$key]
            order by 
                if ($inscription//tei:origDate/@when-custom)
                then xs:integer($inscription//tei:origDate/@when-custom)
                else xs:integer($inscription//tei:origDate/@notBefore-custom)
            return $inscription
    }  
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

declare
    %templates:wrap
function app:inscription($node as node(), $model as map(*), $id as xs:string) {
    let $inscription := collection($config:remote-data-root)//id($id)
    return
        map { "inscription" := $inscription[1] }
};

declare function app:inscription-title($node as node(), $model as map(*), $type as xs:string?) {
    let $suffix := if ($type) then "." || $type else ()
    let $inscription := $model("inscription")
    let $title := $inscription//tei:titleStmt/tei:title/text()
    return
        <a xmlns="http://www.w3.org/1999/xhtml" href="{$node/@href}inscriptions/{$inscription/@xml:id}{$suffix}">{ $title }</a>
};

declare function app:inscription-regnal_year($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    let $test := xs:string($model("ruler")/@xml:id)
    (: We use the first regnal year found in the EDITION,
       even if there may be others. :)
    let $date := $inscription//tei:div[@type='edition']//tei:date[@datingMethod='regnal'][1]
    let $rulerasstated := substring-after($date/@datingPoint,'pers:')
    order by xs:integer($date/@when-custom)
    return 
        if ($test = $rulerasstated)
        then xs:string($date/@when-custom)
        else ''
};

declare function app:inscription-date($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    let $date := $inscription//tei:origDate/text()
    return 
        $date
};

declare function app:inscription-id($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    let $id := $inscription//tei:idno
    return $id
};

(: ~
 : This should be adopted to reflect differences in language
 : (Sanskrit v. Middle Indic). 
 : I am currently pulling this information from the @xml:lang
 : attribute of div[@type='edition'], rather than text. :)
declare function app:inscription-language($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    let $script := $inscription//tei:div[@type='edition']/@xml:lang
    let $script := if ($script eq 'sa-Latn') then 'Sanskrit'
                   else if ($script eq 'mi-Latn') then 'Middle Indic'
                   else if ($script eq 'xx') then 'Unknown'
                   else 'Unspecified'
    (: Obviously this will need revision at some point... :)
    return 
        $script
};

(: This also needs work. :)
declare function app:download-epidoc($node as node(), $model as map(*)) {
    let $doc-path := document-uri(root($model("inscription")))
    let $rest-link := '/exist/rest' || $doc-path
    return
        <a xmlns="http://www.w3.org/1999/xhtml" href="{$rest-link}" target="_blank">{ $node/node() }</a>
};

(: List of persons. Sorting still needs work. :)
declare function app:list-people($node as node(), $model as map(*)) {
    map {
        "people" := 
            for $key in distinct-values(collection($config:remote-data-root)//tei:persName/@key)
            let $id := 
                if (contains($key,'pers:'))
                    then substring-after($key,'pers:')
                else $key
            let $nid := xs:NCName($id)
            let $name := 
                if ($config:person-authority//tei:person[@xml:id=$id]/tei:persName/text())
                    then $config:person-authority//tei:person[@xml:id=$id][1]/tei:persName/text()
                else $id
            order by $name
            return app:generate-person-entry($nid,$name)
    }
};

declare 
    %templates:wrap
function app:person($node as node(), $model as map(*), $key as xs:string) {
    let $id := substring-after($key,'pers:')
    let $person := $model("people")//id($id)
    return
        map { "person" := $person[1] }
};

declare function app:person-name($node as node(), $model as map(*)) {
    let $person := $model("person")
    let $anchor := $person/@xml:id
    return 
        <h4><a name="{$person/@xml:id}"/>{ $person/tei:persName/text() }</h4>
};

declare function app:inscriptions-related-to-person($node as node(), $model as map(*), $type as xs:string?) {
    let $suffix := if ($type) then "." || $type else ()
    let $personid := $model("person")/@xml:id
    let $key := concat('pers:',$personid)
    return
        <div>
        Mentioned in these inscriptions:
        {   for $inscription in collection($config:remote-data-root)//tei:TEI
            let $idno := $inscription//tei:idno
            let $namestring :=
                for $name in $inscription//tei:div[@type='edition']//tei:persName[@key=$key]
                return 
                    app:flatten-app($name)
            where $inscription//tei:persName[@key=$key]
            return 
                <span>
                    <a xmlns="http://www.w3.org/1999/xhtml" href="{$node/@href}inscriptions/{$inscription/@xml:id}{$suffix}">{ $idno }</a>
                    (<em>{ $namestring }</em>)
                </span>
        }
        </div>
};

(:  List of bibliography items :)
declare function app:list-bibitems($node as node(), $model as map(*)) {
    map {
        "bibitems" :=
            for $bibitem in $config:bibl-authority//tei:bibl
            let $orderkey :=
                if ($bibitem/tei:author) then $bibitem/tei:author[1]/tei:name/tei:surname/text()
                else if ($bibitem/tei:editor) then $bibitem/tei:editor[1]/tei:name/tei:surname/text()
                else $bibitem/tei:title[1]/text()
            order by $orderkey,$bibitem/tei:date
            return $bibitem 
    }
};

(:  Generate short name for bibliography item :)
declare function app:bibl-shortname($node as node(), $model as map(*)) {
    let $bibitem := $model("bibitem")
    return tei-to-html:bibl-shortname($bibitem)
};

declare function app:bibitem($node as node(), $model as map(*)) {
    let $bibitem := $model("bibitem")
    return tei-to-html:bibl($bibitem)
};

declare function app:places-inscriptions-located($node as node(), $model as map(*), $type as xs:string?) {
    let $suffix := if ($type) then "." || $type else ()
    let $place := $model("place")
    let $id := $place/@xml:id
    let $key := concat('pl:',$id)
    return
        if (collection($config:remote-data-root)//tei:origPlace//tei:placeName[@key=$key])
        then
            <div>
            Inscriptions located here:
            {
                for $inscription in collection($config:remote-data-root)//tei:TEI
                let $idno := $inscription//tei:idno
                where $inscription//tei:origPlace//tei:placeName[@key=$key]
                return
                    <a xmlns="http://www.w3.org/1999/xhtml" href="{$node/@href}inscriptions/{$inscription/@xml:id}{$suffix}">{ $idno }</a>
            }
            </div>
        else ()
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

declare function app:places-inscriptions-mentioned($node as node(), $model as map(*), $type as xs:string?) {
    let $suffix := if ($type) then "." || $type else ()
    let $place := $model("place")
    let $id := $place/@xml:id
    let $key := concat('pl:',$id)
    return
        if (collection($config:remote-data-root)//tei:div[@type='edition']//tei:placeName[@key=$key])
        then
            <div>
            Mentioned in these inscriptions:
            {
                for $inscription in collection($config:remote-data-root)//tei:TEI
                let $idno := $inscription//tei:idno
                let $namelist := 
                    for $name in $inscription//tei:div[@type='edition']//tei:placeName[@key=$key]
                    return
                        app:flatten-app($name)
                let $namestring := string-join(distinct-values($namelist),', ')
                where $inscription//tei:div[@type='edition']//tei:placeName[@key=$key]
                return
                    <span>
                        <a xmlns="http://www.w3.org/1999/xhtml" href="{$node/@href}inscriptions/{$inscription/@xml:id}{$suffix}">{ $idno }</a>
                        (<em>{ $namestring }</em>)
                    </span>
            }
            </div>
        else ()
};

declare function app:view($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    return
        tei-to-html:render($inscription)
};

declare function app:view-facsimiles($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    return 
        if ($inscription//tei:facsimile/tei:graphic)
        then
            let $graphics := 
                for $i in $inscription//tei:facsimile/tei:graphic
                return 
                    <div>
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
};

declare function app:view-map($node as node(), $model as map(*)) {
    let $inscription := $model("inscription")
    let $placename := substring-after($inscription//tei:origPlace/tei:placeName/@key,"pl:")
    let $place := $config:place-authority//tei:place[@xml:id = $placename]
    return
        if ($place/tei:geo)
        then 
            let $lat := substring-before($place/tei:geo,' ')
            let $long := substring-after($place/tei:geo,' ')
            let $latlong := concat($long,", ",$lat)
            return
                <section class="accordion">
                    <div class="map-container">
                        <input id="ac-1" name="accordion-1" type="checkbox"/>
                        <label for="ac-1">Map of inscription location ({$placename})</label>
                            <article>
                                <div id="map" class="row">
                                    <script type="text/javascript">
            L.mapbox.accessToken = 'pk.eyJ1IjoiYXNvMjEwMSIsImEiOiJwRGcyeGJBIn0.jbSN_ypYYjlAZJgd4HqDGQ';
            var geojson = [{ smap:create-data() }];
            var map = L.mapbox.map('map', 'aso2101.kbbp2nnh')
                        .setView([{$latlong}],8);
                                    </script>
                                    <script type="text/javascript" src="/exist/apps/SAI/resources/js/map.js"/>
                                </div>
                            </article>
                        </div>
                    </section>
        else ()
};

(:  Right now these are more or less modelled on SARIT's search function. :)
declare function app:query($node as node()*, $model as map(*), $query as xs:string?) as map(*) {
    (:If there is no query string, fill up the map with existing values:)
    if (empty($query))
        then
            map {
                "hits" := session:get-attribute("apps.sai"),
                "query" := session:get-attribute("apps.sai.query")
            }
    (: Otherwise perform the query :)
    else
        let $context := collection($config:remote-data-root)/tei:TEI/tei:text
        let $hits :=
            for $hit in 
                (
                $context//tei:p[ft:query(., $query)],
                $context//tei:head[ft:query(., $query)],
                $context//tei:lg[ft:query(., $query)],
                $context//tei:trailer[ft:query(., $query)],
                $context//tei:l[not(local-name(./..) eq 'lg')][ft:query(., $query)],
                $context//tei:quote[ft:query(., $query)],
                $context//tei:text[ft:query(.,$query)],
                $context//tei:unclear[ft:query(.,$query)],
                $context//tei:supplied[ft:query(.,$query)]
                )
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
                    <a href="?start={max( ($start - $per-page, 1 ) ) }"><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ),
            let $startPage := xs:integer(ceiling($start div $per-page))
            let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
            let $upperBound := min(($lowerBound + $max-pages - 1, $count))
            let $lowerBound := max(($upperBound - $max-pages + 1, 1))
            for $i in $lowerBound to $upperBound
            return
                if ($i = ceiling($start div $per-page)) then
                    <li class="active"><a href="?start={max( (($i - 1) * $per-page + 1, 1) )}">{$i}</a></li>
                else
                    <li><a href="?start={max( (($i - 1) * $per-page + 1, 1)) }">{$i}</a></li>,
            if ($start + $per-page < count($model("hits"))) then (
                <li>
                    <a href="?start={$start + $per-page}"><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a href="?start={max( (($count - 1) * $per-page + 1, 1))}"><i class="glyphicon glyphicon-fast-forward"/></a>
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
  if ($node/ancestor::tei:div or $node/ancestor::tei:note) then 
      ()
  else if ($mode eq 'before') then 
      concat($node, ' ')
  else 
      concat(' ',$node)
};
(:~
    Output the actual search result as a div, using the kwic module to summarize full text matches.
:)
(:template function in search.html:)
declare 
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("per-page", 10)
function app:show-hits($node as node()*, $model as map(*), $start as xs:integer, $per-page as xs:integer) {
    for $hit at $p in subsequence($model("hits"), $start, $per-page)
    let $inscription := $hit/ancestor::tei:TEI
    let $inscription-title := $inscription//tei:titleStmt/tei:title/text()
    let $inscription-id := $inscription/@xml:id/string()
    (:pad hit with surrounding siblings:)
    let $hit-padded := <hit>{($hit/preceding-sibling::*[1], $hit, $hit/following-sibling::*[1])}</hit>
    let $loc := 
        <tr class="reference">
            <td colspan="3">
                <span class="number">{$start + $p - 1}</span>
                <a href="inscriptions/{$inscription-id}">{ $inscription-title }</a>
            </td>
        </tr>
    let $matchId := ($hit/@xml:id, util:node-id($hit))[1]
    let $config := <config width="80" table="yes"/>
    let $kwic := kwic:summarize($hit-padded, $config, util:function(xs:QName("local:filter-kwic"), 2))
    return
        ($loc, $kwic)
};