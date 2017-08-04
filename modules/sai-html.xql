xquery version "3.1";

module namespace sai="http://sai.indology.info";

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace config = "http://www.tei-c.org/tei-simple/config";
declare namespace pages="http://www.tei-c.org/tei-simple/pages";
declare namespace functx2 = "http://www.hisoma.mom.fr/labs/functx2";
import module namespace pmf = "http://www.hisoma.mom.fr/labs/epigraphy" at "ext-html.xql";


(: FUNCTIONS SPECIFIC TO THE SĀTAVĀHANA INSCRIPTIONS
 : PROJECT - ANDREW OLLETT :)
declare function sai:images($config as map(*), $node as element(), $class as xs:string+,$content) {
    <div class="row">
        <div class="col-md-4">{pmf:apply-children($config,$node,$content)}</div>
    </div>
};
declare function sai:graphic($config as map(*), $node as element(), $class as xs:string+,$url) {
    let $id := fn:substring-before(fn:tokenize($url,"/")[last()],".")
    return
        <div class="col-lg-3 col-md-4 col-xs-6 thumb">
            <a class="thumbnail" href="#" data-toggle="modal" data-target="#{$id}">
                <img class="img-rounded" alt="" src="{concat("/exist/apps/SAI-data/",$url)}"></img>
            </a>
        </div>
};
declare function sai:image-modals($config as map(*), $node as element(), $class as xs:string+,$images) {
let $modals := 
    for $i in $images
    let $url := fn:string($i/@url)
    let $id := fn:substring-before(fn:tokenize($url,"/")[last()],".")
    return 
    <div id="{$id}" class="modal text-left"  tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">x</button>
                    <h3>Facsimiles</h3>
                </div>
                <div class="modal-body">
                    <img class="img-responsive center-block" src="{concat("/exist/apps/SAI-data/",$url)}"></img>
                    <p class="text-center">{$i/tei:desc}</p>
                </div>
                <div class="modal-footer">
                    <button class="btn" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    return if($modals) then $modals else ()
};
declare function sai:link($config as map(*), $node as element(), $class as xs:string?, $content, $link as item()?) {
    let $target :=
        if($content/@target) then $content/@target
        else if($content/@key) then $content/@key
        else ()
    let $link :=    
        if(starts-with($target,'http')) then 
            $target
        else if(starts-with($target,'in')) then
            replace($target,'in:',concat($config:app-nav-base,'/inscription/'))
        else if(starts-with($target,'bibl')) then
            replace($target,'bibl:',concat($config:app-nav-base,'/bibliography/'))
        else if(starts-with($target,'pers')) then
            replace($target,'pers:',concat($config:app-nav-base,'/person/'))
        else if(starts-with($target,'pl')) then
            replace($target,'pl:',concat($config:app-nav-base,'/place/'))            
            else concat($config:app-nav-base,'/inscription/',$target)
    return 							
        <a href="{$link}" class="{$class}">{pmf:apply-children($config, $node, $content)}</a>
};
 
declare function sai:name-orthography($config as map(*), $node as element(), $content) {
    let $attested := $node/tei:persName[not(@type)][1]
    let $key := concat('pers:',string($node/@xml:id))
    let $spellings :=
        let $inscriptions := collection($config:remote-data-root)//tei:TEI[descendant::tei:div[@type='edition']//tei:persName[@key=$key]]
        let $length := count($inscriptions)
        for $inscription at $pos in $inscriptions
        let $idno := 
            if ($inscription//tei:publicationStmt/tei:idno) then $inscription//tei:publicationStmt/tei:idno/text()
            else $inscription//tei:idno[1]/text()
        let $namestring :=
            for $name in $inscription//tei:div[@type='edition']//tei:persName[@key=$key]
            return
                sai:name-element-to-string($name)
        let $joiner :=
            if ($pos eq $length) then "" else ", "
        return 
            if($inscription) then 
                <span><em>{ $namestring }</em>{' '}<a href="/exist/apps/SAI/inscription/{$inscription/@xml:id}">{$idno}</a>{ $joiner }</span>
            else ()
    return 
        <dd>{$attested}{" "}({ $spellings })</dd>
};
declare function sai:name-element-to-string($node as element()) {
    let $string := ""
    let $output := 
        for $i in ($node//text())
        let $text :=
            if (not($i/ancestor::tei:rdg) and not($i/ancestor::tei:corr) and not($i/ancestor::tei:note)) then $i
            else ""
        return concat($string,$text)
    return $output
};
declare function sai:date-range($begin as xs:string,$end as xs:string) {
    let $begin := number($begin)
    let $end := number($end)
    return 
        (: if both dates are BCE :)
        if ($begin lt 0 and $end lt 0) then 
            <span>{ string($begin * -1) }–{ string($end * -1) }{' '}<span class="era">bce</span></span>
        (: if both dates are CE :)
        else if ($begin gt 0 and $end gt 0) then
            <span>{ string($begin) }–{ string($end) }{' '}<span class="era">ce</span></span>
        (: if the starting date is BCE and the ending date is CE :)
        else
            <span>{ string($begin) }{' '}<span class="era">ce</span>–{ string($end) }{' '}<span class="era">ce</span></span>
};
declare function sai:word-list($key as xs:string, $desc as xs:string) {
   (: eventually we will have a word list of terms that have a key, :)
   (: i.e., those that appear with @key='terms:' etc. :) 
   (: for now these are just strings :)
   <span>{ $desc }</span>
};
declare function sai:state-or-trait($config as map(*), $node as element(), $content, $states as element()) {
    let $length := count($states)
    let $output := 
        for $state at $pos in $states
            let $state-key := substring-after($state/@key,'terms:')
            let $state-desc := $state/tei:desc
            let $cert := 
                if ($state/@precision eq 'low') then "c. " else ()
            let $joiner :=
                if ($pos eq $length) then "" else ", "
            let $duration := 
                if ($state/@notBefore-custom and $state/@notAfter-custom)
                then <span>{' '}({$cert}{ sai:date-range($state/@notBefore-custom,$state/@notAfter-custom) })</span>
                else ()
        return <span>{ $state-desc }{ $duration }{ $joiner }</span>
    return
        <dd>{ $output }</dd>
};