xquery version "3.0";

module namespace tei-to-html="localhost:8080/exist/apps/SAI/tei2html";
(: This is based off of SARIT's module. :)
import module namespace app="localhost:8080/exist/apps/SAI/templates" at "app.xql";

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
            
            (: Core block elements :)
            case element(tei:p) return tei-to-html:p($node, $options)
            case element(tei:div) return tei-to-html:div($node,$options)
            
            (: Core inline elements :)
            case element(tei:ref) return tei-to-html:ref($node,$options)
            
            (: Epidoc-specific elements :)
            case element(tei:gap) return tei-to-html:gap($node, $options)
            case element(tei:lb) return tei-to-html:lb($node, $options)
            
            (: Bibliography elements :)
            case element(tei:bibl) return tei-to-html:bibl($node)
            
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
    { tei-to-html:placeOfOrigin($node, $options) }
    { tei-to-html:dateOfOrigin($node, $options) }
    { tei-to-html:objectDescription($node, $options) }
    { tei-to-html:language($node) }
    </div>
};

declare function tei-to-html:placeOfOrigin($node, $options) {
    let $place := $node//tei:origPlace
    return
        if ($place) 
        then 
            <div class="bibentry">
                <b>Place of origin</b>: { tei-to-html:recurse($place, $options) }
            </div>
        else ()
};
declare function tei-to-html:dateOfOrigin($node, $options) {
    let $date := $node//tei:origDate
    return
        if ($date) 
        then
            <div class="bibentry">
                <b>Date of origin</b>: { tei-to-html:recurse($date, $options) }
            </div>
        else ()
};
declare function tei-to-html:objectDescription($node, $options) {
    let $objdesc := $node/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc
    return
        if ($objdesc)
        then
            <div class="bibentry">
                <b>Object description</b>: { tei-to-html:dispatch($objdesc, $options) }
            </div>
        else ()
};

declare function tei-to-html:language($node) {
    let $script := root($node)/tei:text/tei:body/tei:div[@type='edition']/@xml:lang
    let $script := if ($script eq 'sa-Latn') then 'Sanskrit' 
                   else if ($script eq 'mi-Latn') then 'Middle Indic'
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
    tei-to-html:recurse($node,$options)
};

(:  Edition division :)
declare function tei-to-html:edition($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="edition">
        <h2>Edition</h2>
        { tei-to-html:recurse($node,$options) }
    </div>
};

(:  Bibliography division :)
declare function tei-to-html:bibliography($node as element(tei:div),$options) as element()* {
    tei-to-html:recurse($node,$options)  
};

(: Commentary division :)
declare function tei-to-html:commentary($node as element(tei:div),$options) as element()* {
    <div class="epidoc" id="commentary">
        <h2>Notes</h2>
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
    tei-to-html:recurse($node,$options)
};

declare function tei-to-html:p($node as element(tei:p), $options) as element()+ {
    let $rend := $node/@rend
    return 
        if ($rend = ('right', 'center', 'first', 'indent') ) 
        then
            <p class="{concat('p', '-', data($rend))}" title="tei:p" id="{$node/@xml:id}">{ tei-to-html:recurse($node, $options) }</p>
        else 
            <p class="p" title="tei:p">{tei-to-html:recurse($node, $options)}</p>
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

declare function tei-to-html:ref($node as element(tei:ref),$options) {
    let $target := substring-after($node/@target,"bibl:")
    let $text := $node/text()
    return
        if ($target) then
            <a href="/exist/apps/SAI/bibliography.html#{$target}">{$text}</a>
        else tei-to-html:recurse($node,$options)  
};
declare function tei-to-html:biblpntr($node) {
    let $target := substring-after($node/@target,"bibl:")
    let $range := $node/tei:citedRange/text()
    return
        <a href="/exist/apps/SAI/bibliography.html#{$target}">abc</a>
};

declare function tei-to-html:bibl($node as element(tei:bibl)) {
    let $type := $node/@type
    return 
        if ($node/ancestor::tei:div[@type='bibliography']) then tei-to-html:biblpntr($node)
        else
            if ($type = "book") then 
                tei-to-html:bibl-book($node)
            else if ($type = "article") then 
                tei-to-html:bibl-article($node)
            else if ($type = "incollection") then 
                tei-to-html:bibl-incollection($node)
            else if ($type = "inbook") then
                tei-to-html:bibl-inbook($node)
            else "null"
};

declare function tei-to-html:bibl-book($node as element(tei:bibl)) {
    let $id := string($node/@xml:id)
    let $space := " "
    let $authors :=
        if ($node/tei:author) then $node/tei:author
        else $node/tei:editor
    let $authorstring := tei-to-html:author-string($authors)
    let $edstring := 
        if ($node/tei:editor[2]) then " (eds.)."
        else if ($node/tei:editor[1]) then " (ed.)."
        else 
            if (ends-with($authorstring,'.')) then " "
            else ". "
    let $notestring := if ($node/tei:note) then concat(" ",$node/tei:note,".") else ""
    let $titlestring := $node/tei:title/text()
    let $pubstring := concat($node/tei:pubPlace/text(),": ",$node/tei:publisher/text(),", ",$node/tei:date/text())
    return
        <div id="{$id}" type="bibitem">
            {$authorstring}{$edstring}{$space}<em>{$titlestring}.</em>{$space}{$pubstring}.{$notestring}
        </div>
};
declare function tei-to-html:bibl-article($node as element(tei:bibl)) {
    let $id := $node/@xml:id
    let $space := " "
    let $authors :=
        if ($node/tei:author) then $node/tei:author
        else $node/tei:editor
    let $authorstring := tei-to-html:author-string($authors)
    let $edstring := 
        if ($node/tei:editor[2]) then " (eds.)."
        else if ($node/tei:editor[1]) then " (ed.)."
        else 
            if (ends-with($authorstring,'.')) then " "
            else ". "
    let $notestring := if ($node/tei:note) then concat(" ",$node/tei:note,".") else ""
    let $titlestring := $node/tei:title[@level="a"]/text()
    let $journalstring := $node/tei:title[@level="j"]/text()
    let $voletc := concat($node/tei:biblScope[@unit='vol']/text()," (",$node/tei:date/text(),"): ",$node/tei:biblScope[@unit='pp']/text())
    return
        <div type="bibitem" id="{$id}">
        {$authorstring}{$edstring} “{$titlestring}.”{$space}<em>{$journalstring}</em>{$space}{$voletc}..{$notestring}
        </div>
};
declare function tei-to-html:bibl-incollection($node as element(tei:bibl)) {
    let $id := string($node/@xml:id)
    let $authors := $node/tei:author
    let $editors := $node/tei:editor
    let $authorstring := tei-to-html:author-string($authors)
    let $editorstring := tei-to-html:editor-string($editors)
    let $edstring := 
        if ($editors[2]) then " (eds.), "
        else if ($editors[1]) then " (ed.), "
        else ""
    let $volstring :=
        if ($node/tei:biblScope[@unit='vol']) then concat(", vol. ",$node/tei:biblScope[@unit='vol']/text())
        else ""
    let $titlestring := $node/tei:title[@level='a']/text()
    let $notestring := if ($node/tei:note) then concat(" ",$node/tei:note,".") else ""
    let $bookstring := $node/tei:title[@level='m']/text()
    let $pagestring := $node/tei:biblScope[@unit='pp']/text()
    let $pubstring := concat($node/tei:pubPlace/text(),": ",$node/tei:publisher/text(),", ",$node/tei:date/text())
    return
        <div id="{$id}" type="bibitem">
            {$authorstring}. “{$titlestring}.” pp. {$pagestring} in {$editorstring}{$edstring} <em>{$bookstring}</em>{$volstring}. {$pubstring}.{$notestring}
        </div>
};
declare function tei-to-html:bibl-inbook($node as element(tei:bibl)) {
    let $id := string($node/@xml:id)
    let $authors := $node/tei:author
    let $authorstring := tei-to-html:author-string($authors)
    let $titlestring := $node/tei:title[@level='a']/text()
    let $notestring := if ($node/tei:note) then concat(" ",$node/tei:note,".") else ""
    let $bookstring := $node/tei:title[@level='m']/text()
    let $pagestring := $node/tei:biblScope[@unit='pp']/text()
    let $volstring :=
        if ($node/tei:biblScope[@unit='vol']) then concat(", vol. ",$node/tei:biblScope[@unit='vol']/text())
        else ""
    let $pubstring := concat($node/tei:pubPlace/text(),": ",$node/tei:publisher/text(),", ",$node/tei:date/text())
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
        if ($nodes/tei:author) then $nodes/tei:author
        else if ($nodes/tei:editor) then $nodes/tei:editor
        else $nodes/tei:title
    let $authorstring :=
        if ($authors[3]) then
            concat($authors[1]//tei:surname/text()," and ",$authors[2]//tei:surname/text()," et al.")
        else if ($authors[2]) then
            concat($authors[1]//tei:surname/text()," and ",$authors[2]//tei:surname/text())
        else $authors[1]//tei:surname/text()
    let $date := 
        if ($nodes/tei:date) then $nodes/tei:date/text()
        else "no date"
    return
        concat($authorstring," ",$date)
};