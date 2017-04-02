xquery version "3.0";

module namespace tei-to-html="localhost:8080/exist/apps/SAI/tei2html";
(: This is based off of SARIT's module. :)
import module namespace app="localhost:8080/exist/apps/SAI/templates" at "app.xql";
import module namespace config="localhost:8080/exist/apps/SAI/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: This is mostly adapted from SARIT's code :)
(: A helper function in case no options are passed to the function :)
declare function tei-to-html:render($content as node()*) as element()+ {
    tei-to-html:render($content, <parameters/>)
};

(: The main function for the tei-to-html module: Takes TEI content, turns it into HTML, and wraps the result in a div element :)
declare function tei-to-html:render($content as node()*, $options as element(parameters)*) as element()+ {
    <div class="body">
        { tei-to-html:dispatch($content, $options) }
    </div>
};

(: Typeswitch routine: Takes any node in a TEI content and either dispatches it to a dedicated 
 : function that handles that content (e.g. div), ignores it by passing it to the recurse() function
 : (e.g. text), or handles it directly (none). :)
declare function tei-to-html:dispatch($nodes as node()*, $options) as item()* {
    for $node in $nodes
    return
        typeswitch($node)
            case text() return tei-to-html:text($node)
            
            case element(tei:TEI) return tei-to-html:recurse($node, $options)
            
            (: This constructs the header at the top :)
            case element(tei:teiHeader) return tei-to-html:teiHeader($node, $options)
            
            (: Facsimiles :)
            case element(tei:facsimile) return tei-to-html:facsimile($node, $options)
            
            (: Core block elements :)
            case element(tei:p) return tei-to-html:p($node, $options)
            case element(tei:w) return tei-to-html:w($node, $options)
            case element(tei:lg) return tei-to-html:lg($node,$options)
            case element(tei:l) return tei-to-html:l($node,$options)
            case element(tei:caesura) return tei-to-html:caesura($node,$options)
            case element(tei:div) return tei-to-html:div($node,$options)
            
            (: Headings are dealt with in the div function :)
            case element(tei:head) return ""
            
            (: Core inline elements :)
            case element(tei:ref) return tei-to-html:ref($node,$options)
            case element(tei:placeName) return tei-to-html:placeName($node,$options)
            case element(tei:persName) return tei-to-html:persName($node,$options)
            case element(tei:app) return tei-to-html:app($node,$options)
            case element(tei:choice) return tei-to-html:choice($node,$options)
            case element(tei:note) return tei-to-html:note($node,$options)
            case element(tei:emph) return tei-to-html:emph($node,$options)
            case element(tei:seg) return tei-to-html:seg($node,$options)
            
            (: Epidoc-specific elements :)
            case element(tei:gap) return tei-to-html:gap($node, $options)
            case element(tei:lb) return tei-to-html:lb($node, $options)
            case element(tei:supplied) return tei-to-html:supplied($node,$options)
            case element(tei:unclear) return tei-to-html:unclear($node,$options)
            
            (: Bibliography and apparatus elements :)
            case element(tei:biblStruct) return tei-to-html:biblStruct($node)
            case element(tei:listApp) return tei-to-html:listApp($node,$options)
            
            default return tei-to-html:recurse($node, $options)
};

(: Recurses through the child nodes and sends them tei-to-html:dispatch() :)
declare function tei-to-html:recurse($node as node(), $options) as item()* {
    for $node in $node/node()
    return
        tei-to-html:dispatch($node, $options)
};

(: This is for conditional formatting of text elements, for example
 : removing whitespace after an lb element. :)
declare function tei-to-html:text($node as node()) {
    if ($node/preceding-sibling::*[1][self::tei:lb]) then replace($node,'^\s+','')
    else $node
};

declare function tei-to-html:teiHeader($node as element(tei:teiHeader), $options) as element()+ {
    (:  SARIT's version of the function creates a "Toggle Full Header" button.
        This version simply extracts some of the meaningful information from
        the header and displays it. :)
    (:  Displays the title. :)
    <div>
    <h2>{ tei-to-html:dispatch($node/tei:fileDesc/tei:titleStmt/tei:title, $options) }</h2>
    { tei-to-html:objectDescription($node, $options) }
    { tei-to-html:objectHistory($node,$options) }
    { tei-to-html:language($node) }
    </div>
};
declare function tei-to-html:objectDescription($node,$options) {
    let $support := $node//tei:supportDesc
    let $layout := $node//tei:layoutDesc
    return 
        if ($support or $layout)
        then
            <div class="bibentry">
                <b>Object description</b>: 
                <ul>
                    { if ($support) then tei-to-html:support($support,$options) else () }
                    { if ($layout) then tei-to-html:layout($layout,$options) else () }
                </ul>
            </div>
        else ()
};
declare function tei-to-html:objectHistory($node,$options) {
    let $origin := $node//tei:origin
    let $provenance := $node//tei:provenance
    return
        if ($origin or $provenance)
        then 
            <div class="bibentry">
                <b>Object history:</b>
                <ul>
                    { if ($origin) then tei-to-html:origin($origin,$options) else () }
                    { if ($provenance) then tei-to-html:provenance($provenance,$options) else () }
                </ul>
            </div>
    else ()
};
declare function tei-to-html:support($node,$options) {
    <li><b>Support: </b> { tei-to-html:recurse($node,$options) }</li>
};
declare function tei-to-html:layout($node,$options) {
    <li><b>Layout: </b> { tei-to-html:recurse($node,$options) }</li>
};
declare function tei-to-html:origin($node, $options) {
    let $place := $node//tei:origPlace
    let $date := 
        if ($node//tei:origDate) then $node//tei:origDate
        else "date unknown"
    return
        <li><b>Origin ({ $date })</b>: { tei-to-html:recurse($place, $options) }</li>
};
declare function tei-to-html:provenance($nodes,$options) {
    for $x in $nodes
    let $date := 
        if ($x[@notAfter]) then concat($x/@notAfter," or before")
        else if ($x[@notBefore]) then concat($x/@notBefore," or after")
        else if ($x[@when]) then string($x/@when)
        else "(date unknown)"
    return
        <li><b>{ $date }</b>: { tei-to-html:recurse($x,$options) }</li>
};
declare function tei-to-html:language($node) {
    let $script := root($node)//tei:div[@type='edition']/@xml:lang
    let $script := if ($script eq 'san-Latn') then 'Sanskrit' 
                   else if ($script eq 'pra-Latn') then 'Middle Indic'
                   else if ($script eq 'und') then 'Unknown'
                   else 'no language specified'
    return 
        if ($script)
        then
            <div class="bibentry">
                <b>Language</b>: { $script }
            </div>
        else ()
};

(:  Figure out what the "div" is (there can be SIX different types in EpiDoc) 
 :  and send it to the right function.   :)
declare function tei-to-html:div($node as element(tei:div),$options) {
    (: Typeswitch does not work on attributes, so we need to do this manually :)
    let $type := $node/@type
    return
        if ($type = 'apparatus')
            then tei-to-html:apparatus($node,$options)
        else if ($node/@type = 'bibliography')
            then tei-to-html:bibliography($node,$options)
        else if ($node/@type = 'commentary')
            then tei-to-html:commentary($node,$options)
        else if ($node/@type = 'edition')
            then tei-to-html:edition($node,$options)
        else if ($node/@type = 'textpart')
            then tei-to-html:textpart($node,$options)
        else if ($node/@type = 'translation')
            then tei-to-html:translation($node,$options)
        else
            tei-to-html:recurse($node,$options)
};

(:  Apparatus division: we don't use this, so it is blank now. :)
declare function tei-to-html:apparatus($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="bibliography">
        <h2>Critical apparatus</h2>
        { tei-to-html:recurse($node,$options) }
    </div>
};

(: Bibliography division: just contains <bibl> elements :)
declare function tei-to-html:bibliography($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="bibliography">
        <h2>Bibliography</h2>
        { 
            for $x in $node/tei:bibl
            let $id := substring-after($x/tei:ptr/@target,"bibl:")
            let $target := $config:bibl-authority-dir//tei:biblStruct[@xml:id=$id]
            let $shortname := 
                if ($x/tei:ptr/text()) 
                then $x/tei:ptr/text()
                else tei-to-html:bibl-shortname($target)
            let $link := <a href='/exist/apps/SAI/bibliography.html#{$id}'>{$shortname}</a>
            let $rangeno := 
                if ($x/tei:citedRange/text()) then concat(": ",$x/tei:citedRange/text())
                else ""
            let $stringafter :=
                if ($x/following-sibling::tei:bibl) then ", " else ""
            return 
                <span>
                    {$link}{$rangeno}{$stringafter}
                </span>
        }
    </div>
};
(:  Edition division :)
declare function tei-to-html:edition($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="edition">
        <h2>Edition</h2>
        { tei-to-html:recurse($node,$options) }
    </div>
};
(: Commentary division :)
declare function tei-to-html:commentary($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="commentary">
        <h2>Commentary</h2>
        { tei-to-html:recurse($node,$options) }
    </div>
};

(: Translation division :)
declare function tei-to-html:translation($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="translation">
        <h2>Translation</h2>
        { tei-to-html:recurse($node,$options) }
    </div>
};

(: Textpart :)
declare function tei-to-html:textpart($node as element(tei:div),$options) as element()* {
    let $heading := 
        if ($node/tei:head) then <h2>{$node/tei:head/text()}</h2>
        else ""
    return 
        <div>
            { $heading }
            { tei-to-html:recurse($node,$options) }
        </div>
    
};

declare function tei-to-html:p($node as element(tei:p), $options) as element()+ {
    let $rend := $node/@rend
    return 
        if ($rend = ('right', 'center', 'first', 'indent') ) 
        then
            <p class="{concat('p', '-', data($rend))}" id="{$node/@xml:id}">{ tei-to-html:recurse($node, $options) }</p>
        else 
            <p class="p">{tei-to-html:recurse($node, $options)}</p>
};

declare function tei-to-html:w($node as element(tei:w), $options) as element()+ {
    let $rend := $node/@rend
    return 
        if ($rend = ('right', 'center', 'first', 'indent') ) 
        then
            <seg class="{concat('p', '-', data($rend))}" id="{$node/@xml:id}">{ tei-to-html:recurse($node, $options) }</seg>
        else 
            <seg class="w">{tei-to-html:recurse($node, $options)}</seg>
};

declare function tei-to-html:lg($node as element(tei:lg), $options) as element()+ {
    (: we want line breaks after every pāda, but
       that should be taken care of by tei-to-html:l. :)
    let $met := <span class="met">{ fn:string($node/@met) }</span>
    return
    <div class="lg">
        { if ($node/@met) then $met else () }
        { tei-to-html:recurse($node,$options) }
    </div>
};
declare function tei-to-html:l($node as element(tei:l), $options) as element()+ {
    <span class="l">{ tei-to-html:recurse($node,$options) }</span>
};
declare function tei-to-html:caesura($node as element(tei:caesura), $options) as element()+ {
    <span class="caesura"/>
};
declare function tei-to-html:seg($node as element(tei:seg), $options) {
    (: I assume that seg[@met] will only be used to enclose a gap 
        element, and therefore I don't run the recursion on this
        element. :)
    let $met :=  fn:replace(fn:replace($node/@met,'-','⏑'),'\+','−')
    return 
        if ($met) then 
            concat('[',$met,']')
        else tei-to-html:recurse($node,$options)
    
};
declare function tei-to-html:gap($node as element(tei:gap),$options) {
    let $reason := $node/@reason
    let $extentstring := tei-to-html:extent-string($node)
    let $certainty := if ($node/@certainty) then '?' else ''
    let $precision := if ($node[@precision='low']) then 'ca.' else ''
    return 
        if ($reason = 'omitted')
        then '&lt; { $extentstring } &gt;'
        else if ($reason = 'ellipsis')
        then 
            if ($node/@quantity)
            then
                concat($precision,$node/@quantity)
            else if ($node/@atLeast and $node/@atMost)
            then concat($node/@atLeast,'-',$node/@atMost)
            else if ($node/@atLeast)
            then concat('&#x2265;',$node/@atLeast)
            else if ($node/@atMost)
            then concat('&#x2264;',$node/@atMost)
            else '?'
        else if ($reason = 'illegible')
        then concat($certainty,$extentstring)
        else if ($reason = 'lost')
        then concat('[',$extentstring,$certainty,']')
        else ''
};
declare function tei-to-html:extent-string($node as node()) {
    let $circa := 'c.'
    let $cur-dot := '.'
    let $cur-max := 40
    return
        if ($node/@extent eq 'unknown') then ' - - - '
        else if ($node/@quantity and $node[@unit='character'])
        then
            if ((number($node/@quantity) > $cur-max) or ((number($node/@quantity) > 1) and ($node[@precision='low'])))
            then string-join(($cur-dot,$cur-dot,$circa,$node/@quantity,$cur-dot,$cur-dot),' ')
            else if ($cur-max >= number($node/@quantity))
            then tei-to-html:dot-out(number($node/@quantity),$cur-dot)
            else ' - - - '
        else if ($node/@atLeast and $node/@atMost)
        then concat('c. ',$node/@atLeast,' - ',$node/@atMost)
        else ''
};
declare function tei-to-html:dot-out($number, $cur-dot) {
    let $sequence :=
        for $x in (1 to xs:integer($number))
        return $cur-dot
    return string-join($sequence,'')
};
declare function tei-to-html:supplied($node as element(tei:supplied),$options) as element()* {
    <span class="supplied">{ tei-to-html:recurse($node,$options) }</span>
};
declare function tei-to-html:unclear($node as element(tei:unclear),$options) as element()* {
    <span class="unclear">{ tei-to-html:recurse($node,$options) }</span>
};
declare function tei-to-html:note($node as element(tei:note),$options) {
    if ($node/tei:p) then 
        tei-to-html:recurse($node/tei:p,$options)
    else tei-to-html:recurse($node,$options)
};
declare function tei-to-html:app($node as element(tei:app),$options) as element()* {
    let $lem := $node/tei:lem
    let $space := " "
    let $readings := 
        <span class="appcontainer">
            {
                for $x in ($node/tei:lem | $node/tei:rdg)
                let $text := <span>{ tei-to-html:recurse($x,$options) }</span>
                let $brack := if ($x/self::tei:lem) then "]" else ""
                (: change as of 12/16: use @source for bibliographical sources,
                   @wit for documentary witnesses,
                   and @resp for persons :)
                (: maybe we don't need to get of the space between authorities? :)
                let $sources := if ($x/@source) then <span class="wit">{ concat(' ',translate(translate(string($x/@source),' ',''),'#','')) }</span> else ""
                let $witnesses := if ($x/@wit) then <span class="wit">{ concat(' ',translate(translate(string($x/@wit),' ',''),'#','')) }</span> else ""
                let $resps := if ($x/@resp) then <span class="wit">{ concat(' ',translate(translate(string($x/@resp),' ',''),'#','')) }</span> else ""
                return 
                    ( <span class="appentry">{$text}{$sources}{$witnesses}{$resps}{$brack}</span> )
            }
        </span>
    let $notes := 
        <span class="appcontainer">
            {
                for $x in ($node/tei:note)
                let $text := tei-to-html:note($x,$options)
                return
                    ( <span class="appentry">{$text}</span>)
            }
        </span>
    return 
        if ($lem) then
            ( <span class="app">{ tei-to-html:recurse($lem,$options) }{$readings}{$notes}</span> )
        else
            ( <span class="app">*{$readings}{$notes}</span> )
        
};
declare function tei-to-html:choice($node as element(tei:choice),$options) {
    let $lemma := $node/tei:sic
    let $choice :=
        <span class="appcontainer">
            <span class="appentry">{ tei-to-html:recurse($lemma,$options) }] <em>sic</em></span>
            <span class="appentry"><em>read:</em> { tei-to-html:recurse($node/tei:corr,$options) }</span>
        </span>
    let $notes := 
        <span class="appcontainer">
            {
                for $x in ($node/tei:note)
                let $text := tei-to-html:note($x,$options)
                return 
                    ( <span class="appentry">{$text}</span> )
            }
        </span>
    return
        <span class="app">{ tei-to-html:recurse($lemma,$options) }{$choice}{$notes}</span>
};
declare function tei-to-html:lb($node as element(tei:lb),$options) {
    let $prebreak := 
        (: The official EpiDoc stylesheets have a few exceptions to hyphenation
         :  at the end of a line, but this is simpler and meets our needs. :)
        if ($node[@break='no']) then '-'
        else ()
    let $postbreak := '
'
    let $span :=
        <span class="lineno">{ string($node/@n) }</span>
    return 
        ( 
            $prebreak,
            <br/>,
            $postbreak,
            $span )
};
declare function tei-to-html:placeName($node as element(tei:placeName),$options) as element()* {
    let $key := substring-after($node/@key,"pl:")
    let $target := concat("/exist/apps/SAI/places.html#",$key)
    return
        if ($key) then
            <a href="{$target}">{ tei-to-html:recurse($node,$options) }</a>
        else 
            <span>{ tei-to-html:recurse($node,$options) }</span>
};
declare function tei-to-html:persName($node as element(tei:persName),$options) as element()* {
    let $key := substring-after($node/@key,"pers:")
    let $target := concat("/exist/apps/SAI/people.html#",$key)
    return
        if ($key) then
            <a href="{$target}">{ tei-to-html:recurse($node,$options) }</a>
        else 
            <span>{ tei-to-html:recurse($node,$options) }</span>
};
declare function tei-to-html:emph($node as element(tei:emph),$options) {
    <em>{ tei-to-html:recurse($node,$options) }</em>
};

declare function tei-to-html:facsimile($node as element(tei:facsimile),$options) {
    let $graphics := 
        for $i in $node/tei:graphic
        let $x := fn:substring-before(fn:substring-after($i/@url,"images/"),".")
        return 
            <div class="col-lg-3 col-md-4 col-xs-6 thumb">
                <a class="thumbnail" href="#" data-toggle="modal" data-target="#{$x}">
                    <img class="img-rounded" alt="" src="{concat("/exist/apps/SAI-data/",$i/@url)}"></img>
                </a>
            </div>
    let $modals :=
        for $i in $node/tei:graphic
        let $x := fn:substring-before(fn:substring-after($i/@url,"images/"),".")
        return
            <div id="{$x}" class="modal fade" data-backdrop="true" data-keyboard="true" tabindex="-1">
                <div class="modal-lg" role="document">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">x</button>
                        <h3>Facsimiles</h3>
                    </div>
                    <div class="modal-body">
                        <img class="img-responsive center-block" src="{concat("/exist/apps/SAI-data/",$i/@url)}"></img>
                        <p class="text-center">{$i/tei:desc}</p>
                    </div>
                    <div class="modal-footer">
                        <button class="btn" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
    return
        <div class="bibentry">
            <b>Facsimiles:</b>
            <div class="container">
                <div class="row">
                    <div class="col-md-4">
                        {$graphics}
                    </div>
                </div>
            </div>
            {$modals}
        </div>
};
declare function tei-to-html:ref($node as element(tei:ref),$options) {
    let $target := substring-after($node/@target,"bibl:")
    let $text := if ($node/text()) then $node/text() else ""
    return
        if ($target) then
            <a href="/exist/apps/SAI/bibliography.html#{$target}">{$text}</a>
        else tei-to-html:recurse($node,$options)  
};

declare function tei-to-html:listApp($node as element(tei:listApp),$options) {
    tei-to-html:recurse($node,$options)    
};

declare function tei-to-html:biblStruct($node as element(tei:biblStruct)) {
    let $type := $node/@type
    return 
        if ($node/ancestor::tei:div[@type='bibliography']) then ()
        else
            if ($type = "book") then 
                tei-to-html:bibl-book($node)
            else if ($type = "article") then 
                tei-to-html:bibl-article($node)
            else if ($type = "incollection") then 
                tei-to-html:bibl-incollection($node)
            else if ($type = "inbook") then
                tei-to-html:bibl-inbook($node)
            else if ($type = "report") then
                tei-to-html:bibl-report($node)
            else if ($type = "dissertation") then
                tei-to-html:bibl-dissertation($node)
            else "null"
};

declare function tei-to-html:bibl-book($node as element(tei:biblStruct)) {
    let $id := string($node/@xml:id)
    let $space := " "
    let $authors :=
        if ($node//tei:author) then $node//tei:author
        else $node//tei:editor
    let $authorstring := tei-to-html:author-string($authors)
    let $edstring := 
        if ($node//tei:editor[2]) then " (eds.)."
        else if ($node//tei:editor[1]) then " (ed.)."
        else 
            if (ends-with($authorstring,'.')) then " "
            else ". "
    let $notestring := if ($node//tei:note) then concat(" ",$node//tei:note,".") else ""
    let $titlestring := $node//tei:title/text()
    let $pubstring := concat($node//tei:pubPlace/text(),": ",$node//tei:publisher/text(),", ",$node//tei:date/text())
    return
        <div id="{$id}" type="bibitem">
            {$authorstring}{$edstring}{$space}<em>{$titlestring}.</em>{$space}{$pubstring}.{$notestring}
        </div>
};
declare function tei-to-html:bibl-article($node as element(tei:biblStruct)) {
    let $id := $node/@xml:id
    let $space := " "
    let $authors :=
        if ($node//tei:author) then $node//tei:author
        else $node//tei:editor
    let $authorstring := tei-to-html:author-string($authors)
    let $edstring := 
        if ($node//tei:editor[2]) then " (eds.)."
        else if ($node//tei:editor[1]) then " (ed.)."
        else 
            if (ends-with($authorstring,'.')) then " "
            else ". "
    let $notestring := if ($node//tei:note) then concat(" ",$node//tei:note,".") else ""
    let $titlestring := $node//tei:title[@level="a"]/text()
    let $journalstring := $node//tei:title[@level="j"]/text()
    let $voletc := concat($node//tei:biblScope[@unit='vol']/text()," (",$node//tei:date/text(),"): ",$node//tei:biblScope[@unit='pp']/text())
    return
        <div type="bibitem" id="{$id}">
        {$authorstring}{$edstring} “{$titlestring}.”{$space}<em>{$journalstring}</em>{$space}{$voletc}..{$notestring}
        </div>
};
declare function tei-to-html:bibl-incollection($node as element(tei:biblStruct)) {
    let $id := string($node/@xml:id)
    let $authors := $node//tei:author
    let $editors := $node//tei:editor
    let $authorstring := tei-to-html:author-string($authors)
    let $editorstring := tei-to-html:editor-string($editors)
    let $edstring := 
        if ($editors[2]) then " (eds.), "
        else if ($editors[1]) then " (ed.), "
        else ""
    let $volstring :=
        if ($node//tei:biblScope[@unit='vol']) then concat(", vol. ",$node//tei:biblScope[@unit='vol']/text())
        else ""
    let $titlestring := $node//tei:title[@level='a']/text()
    let $notestring := if ($node//tei:note) then concat(" ",$node//tei:note,".") else ""
    let $bookstring := $node//tei:title[@level='m']/text()
    let $pagestring := $node//tei:biblScope[@unit='pp']/text()
    let $pubstring := concat($node//tei:pubPlace/text(),": ",$node//tei:publisher/text(),", ",$node//tei:date/text())
    return
        <div id="{$id}" type="bibitem">
            {$authorstring}. “{$titlestring}.” pp. {$pagestring} in {$editorstring}{$edstring} <em>{$bookstring}</em>{$volstring}. {$pubstring}.{$notestring}
        </div>
};
declare function tei-to-html:bibl-report($node as element(tei:biblStruct)) {
    let $id := string($node/@xml:id)
    let $titlestring := $node//tei:title/text()
    let $pubstring := concat($node//tei:pubPlace/text(),": ",$node//tei:publisher/text())
    return
        <div id="{$id}" type="bibitem">
           <em>{$titlestring}. </em> {$pubstring}.
        </div>
};
declare function tei-to-html:bibl-dissertation($node as element(tei:biblStruct)) {
    let $id := string($node/@xml:id)
    let $authors := $node//tei:author
    let $authorstring := tei-to-html:author-string($authors)
    let $title := $node//tei:title/text()
    let $imprint := concat("PhD Dissertation, ",$node//tei:publisher/text()," ",$node//tei:date/text())
    return 
        <div id="{$id}" type="bibitem">
           {$authorstring}. <em>{$title}. </em> {$imprint}.
        </div>
};
declare function tei-to-html:bibl-inbook($node as element(tei:biblStruct)) {
    let $id := string($node/@xml:id)
    let $authors := $node//tei:author
    let $authorstring := tei-to-html:author-string($authors)
    let $titlestring := $node//tei:title[@level='a']/text()
    let $notestring := if ($node//tei:note) then concat(" ",$node//tei:note,".") else ""
    let $bookstring := $node//tei:title[@level='m']/text()
    let $pagestring := $node//tei:biblScope[@unit='pp']/text()
    let $volstring :=
        if ($node//tei:biblScope[@unit='vol']) then concat(", vol. ",$node//tei:biblScope[@unit='vol']/text())
        else ""
    let $pubstring := concat($node//tei:pubPlace/text(),": ",$node//tei:publisher/text(),", ",$node//tei:date/text())
    return
        <div id="{$id}" type="bibitem">
            {$authorstring}. “{$titlestring}.” pp. {$pagestring} in <em>{$bookstring}</em>{$volstring}. {$pubstring}.{$notestring}
        </div>
};
declare function tei-to-html:author-string($nodes) {
    let $result := 
        for $x in $nodes
        return
            if (not($x/preceding-sibling::tei:author | $x/preceding-sibling::tei:editor)) then
                concat($x//tei:surname,", ",$x//tei:forename)
            else
                if (not($x/following-sibling::tei:author | $x/preceding-sibling::tei:editor)) then
                    concat(" and ",$x//tei:forename," ",$x//tei:surname)
                else concat(", ",$x//tei:forename," ",$x//tei:surname)
    return string-join($result,"")
};
declare function tei-to-html:editor-string($nodes) {
    let $result := 
        for $x in $nodes
        return
            if (not($x/preceding-sibling::tei:editor)) then
                concat($x//tei:forename," ",$x//tei:surname)
            else
                if (not($x/following-sibling::tei:editor)) then
                    concat(" and ",$x//tei:forename," ",$x//tei:surname)
                else concat(", ",$x//tei:forename," ",$x//tei:surname)
    return string-join($result,"")
};
declare function tei-to-html:bibl-shortname($nodes) {
    let $authors := 
        if ($nodes//tei:author) then $nodes//tei:author
        else if ($nodes//tei:editor) then $nodes//tei:editor
        else $nodes//tei:title
    let $authorstring :=
        if ($authors[3]) then
            concat($authors[1]//tei:surname/text()," and ",$authors[2]//tei:surname/text()," et al.")
        else if ($authors[2]) then
            concat($authors[1]//tei:surname/text()," and ",$authors[2]//tei:surname/text())
        else if ($authors[1]//tei:surname/text()) then
            $authors[1]//tei:surname/text()
        else $authors/text()
    let $date := 
        if ($nodes//tei:date) then $nodes//tei:date/text()
        else ""
    let $label := ""
    let $shortname := concat($authorstring," ",$date,$label)
    return
        $shortname
};

(:based on stylesheet at http://wiki.tei-c.org/index.php/XML_Whitespace.
The rules are:
#1 Retain one leading space if the node isn't first, has non-space content, and has leading space.
#2 Retain one trailing space if the node isn't last, isn't first, and has trailing space. 
#3 Retain one trailing space if the node isn't last, is first, has trailing space, and has non-space content.
#4 Retain a single space if the node is an only child and only has space content.:)
declare function local:tei-normalize-space($input) {
   element {node-name($input)}
    {$input/@*,
        for $child in $input/node()
        return
            if ($child instance of element())
            then local:tei-normalize-space($child)
            else
                if ($child instance of text())
                then
                    (:#1 Retain one leading space if node isn't first, has non-space content, and has leading space:)
                    if ($child/position() ne 1 and matches($child,'^\s') and normalize-space($child) ne '')
                    then (' ', normalize-space($child))
                    else
                        (:#4 retain one space, if the node is an only child, and has content but it's all space:)
                        if ($child/last() eq 1 and string-length($child) ne 0 and normalize-space($child) eq '')
                        (:NB: this overrules standard normalization:)
                        then ' '
                        else
                            (:#2 if the node isn't last, isn't first, and has trailing space, retain trailing space and collapse and trim the rest:)
                            if ($child/position() ne 1 and $child/position() ne last() and matches($child,'\s$'))
                            then (normalize-space($child), ' ')
                            else
                                (:#3 if the node isn't last, is first, has trailing space, and has non-space content, then keep trailing space:)
                                if ($child/position() eq 1 and matches($child,'\s$') and normalize-space($child) ne '')
                                then (normalize-space($child), ' ')
                                (:if the node is an only child, and has content which is not all space, then trim and collapse, that is, apply standard normalization:)
                                else normalize-space($child)
        (:output comments and pi's:)
        else $child
    }
};