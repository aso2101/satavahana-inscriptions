xquery version "3.1";

module namespace sai="http://sai.indology.info";

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace config = "http://www.tei-c.org/tei-simple/config";
declare namespace pages="http://www.tei-c.org/tei-simple/pages";
declare namespace functx2 = "http://www.hisoma.mom.fr/labs/functx2";

(: FUNCTIONS SPECIFIC TO THE SĀTAVĀHANA INSCRIPTIONS
 : PROJECT - ANDREW OLLETT :)
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