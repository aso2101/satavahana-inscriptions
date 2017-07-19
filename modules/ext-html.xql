xquery version "3.1";

module namespace pmf="http://www.hisoma.mom.fr/labs/epigraphy";

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace config = "http://www.tei-c.org/tei-simple/config";
declare namespace pages="http://www.tei-c.org/tei-simple/pages";
declare namespace functx2 = "http://www.hisoma.mom.fr/labs/functx2";

(: version copied to eiad :)

declare function pmf:apply-children($config as map(*), $node as element(), $content) {
    if ($node/@xml:id) then
        attribute id { $node/@xml:id }
    else
        (),
    $config?apply-children($config, $node, $content)
};

declare function pmf:apply-children2($config as map(*), $node as element(), $content) {
    if ($node/@xml:id) then
        attribute id { $node/@xml:id }
    else
       (),
    $config?apply-children($config, $node, $content)
};

(: function copied from http://www.xqueryfunctions.com/xq/functx_remove-elements-not-contents.html :)
declare function functx:trim
  ( $arg as xs:string? )  as xs:string {
   replace(replace($arg,'\s+$',''),'^\s+','')
 } ;

declare function functx2:icon
    ($ClassIcon as xs:string, $icon as xs:string) {
    <i class="{$ClassIcon}">{$icon}</i>
};
declare function functx:name-test
  ( $testname as xs:string? ,
    $names as xs:string* )  as xs:boolean {
        $testname = $names
        or
        $names = '*'
        or
        functx:substring-after-if-contains($testname,':') =
           (for $name in $names
           return substring-after($name,'*:'))
        or
        substring-before($testname,':') =
           (for $name in $names[contains(.,':*')]
           return substring-before($name,':*'))
         } ;


(: function copied from http://www.xqueryfunctions.com/xq/functx_remove-elements-not-contents.html :)
declare function functx:remove-elements-not-contents
  ( $nodes as node()* ,
    $names as xs:string* )  as node()* {
   for $node in $nodes
       return
        if ($node instance of element())
        then if (functx:name-test(name($node),$names))
             then functx:remove-elements-not-contents($node/node(), $names)
             else element {node-name($node)}
                  {$node/@*,
                  functx:remove-elements-not-contents($node/node(),$names)}
        else if ($node instance of document-node())
        then functx:remove-elements-not-contents($node/node(), $names)
        else $node
    } ;
(: function copied from http://www.xqueryfunctions.com/xq/functx_remove-elements-not-contents.html :)
  
declare function functx:substring-after-if-contains
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {
   if (contains($arg,$delim))
   then substring-after($arg,$delim)
   else $arg
 } ;
 
declare function functx:substring-before-if-contains
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {
   if (contains($arg,$delim))
   then substring-before($arg,$delim)
   else $arg
 } ;
 
 declare function functx:repeat-string
  ( $stringToRepeat as xs:string? ,
    $count as xs:integer )  as xs:string {

   string-join((for $i in 1 to $count return $stringToRepeat),
                        '')
 } ;
 
 declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {
   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;
(:~
: Exemple eXist-db
:)
declare function pmf:code($config as map(*), $node as element(), $class as xs:string+, 
    $content as node()*, $lang as item()?) {
    <pre class="sourcecode" data-language="{if ($lang) then $lang else 'xquery'}">
    {replace(string-join($content/node()), "^\s+?(.*)\s+$", "$1")}
    </pre>
};

(:~
: Ajouts #EM.
:)
declare function pmf:repeat-string($config as map(*), $node as element(), 
    $content as xs:string?, $count as xs:integer?, $stringToRepeat as xs:string?) {
    let $stringToRepeat := $stringToRepeat
    let $count := $count
    for $i in (1 to $count) 
        return $stringToRepeat
};

(: à revoir
declare function pmf:xsl-underdotted($config as map(*), $node as element(), 
    $class as xs:string, $content as node()*, $xsl as item()?) {
        <span class="transformed">
        {transform:transform($content, doc('/db/apps/inscriptions/resources/xsl/test.xsl'), ())}
        </span>
};
 :)

declare function pmf:link2($config as map(*), $node as element(), $class as xs:string?, $content, $link as item()?) {
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
        else if(starts-with($target,'place')) then
            replace($target,'pl:',concat($config:app-nav-base,'/place/'))            
        else concat($config:app-nav-base,'/inscription/',$target)
return 							
    <a href="{$link}" class="{$class}">{pmf:apply-children($config, $node, $content)}</a>
};

declare function pmf:milestone($config as map(*), $node as element(), $class as xs:string+, $content, $unit as xs:string+, $label as item()*) {
    switch($unit)
        case "fragment" return
            <span class="{$class} fragment">{pmf:apply-children($config, $node, $label)}</span>
        case "face" return
            <span class="badge">{pmf:apply-children($config, $node, $label)}</span>
        default return
            ''
};

(:~
: Ajouts #EM. pour les références biblio de la div@type='bibliography'. 
:   Doit pointer sur le fichier bibliography à l'endroit du pointeur @target. @ref ou @target.
:   il faut une autre fonction qui aille chercher les infos pour le titre du lien
:  on va chercher le title[@type='short']
:)
(:  
declare function pmf:refbibl($config as map(*), $node as element(),
    $class as xs:string+, $content, $link as item()?) {
        let $target := substring-after($content,'pyu-bibl:')
        let $ref := doc("/db/apps/epieditor/data/bibliography.xml")//tei:biblStruct[@xml:id=$target]
        let $title-short := $ref//tei:title[@type='short'][1]
       (: let $title-short-hi-1 := replace ($title-short, '<i>','<span class="hi">')
        let $title-short-hi-2 := replace ($title-short-hi-1, '</i>','</span>'):)
        let $title-short := $ref//tei:title[@type='short'][1]/text()
        let $title-deb := if (contains($title-short, '</i>'))
                            then (substring-before($title-short,'<i>'))
                            else ($title-short)
        let $title-end := substring-after($title-short,'</i>')
        let $title-mid := substring-before(substring-after($title-short, '<i>'),'</i>')
        let $title-long := $ref//tei:title[not(@type='short')][1]
        return 
           <a href="{$link}" title="{$title-long}" class="refbibl">{$title-deb}<span class="hi">{$title-mid}</span>{$title-end}:</a>
};

:)

(: #EM: fonction pour l et lb par ex. :)
declare function pmf:breakPyu($config as map(*), $node as element(), $class as xs:string+, 
                                $content, $type as xs:string?, $break as xs:string?, $label as item()*) {
    switch($type)
        case "page" return
            (: à tester :)
            <span class="pageNumber {$class}">{pmf:apply-children($config, $node, $label)}</span>
        case "line" return
            (if ($break='yes') then <br/> else(),
            <span class="lineNumber {$class}">({pmf:apply-children($config, $node, $label)}) </span>)
        case "element" return
            (if ($break='yes') then <br/> else(),
            <span class="{$class}">
                <span class="label">{$label}</span>
                { pmf:apply-children($config, $node, $content) }
            </span>)
        default return
            (: default = no break :)
            <span class="{$class}">({pmf:apply-children($config, $node, $label)}) </span>
};

declare function pmf:section($config as map(*), $node as element(), $class as xs:string+, $hr as xs:string?, $content) {
    (: #EM à revoir : pas de h3 vide si pas de valeur, faire une fonction ?:)
     (: #EM à revoir : controler la class :)
    <section class="{$class}">{ 
        if ($hr='yes') then element hr{ attribute class {'hr'} } else(),
        pmf:apply-children($config, $node, $content) 
    }
    </section>
};
(: revoir pour html div / dl et styles bootstrap  :)
(: transform:transform($root, xs:anyURI("xmldb:exist:///db/styles/style.xsl"), ()) :)
declare function pmf:xsl-biblio($config as map(*), $node as element(), $class as xs:string+, $content as node()*) {
        <div class="table-responsive {$class}">          
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th class="col-md-1">#</th>
                        <th class="col-md-2">Short title</th>
                        <th class="col-md-9">Ref.</th>
                    </tr>
                </thead>
                <tbody>
                        {transform:transform($content, doc('/db/apps/pyu/resources/xsl/pyu-biblio-controle-table.xsl'), ())}
                </tbody>
            </table>
        </div>
};

declare function pmf:span($config as map(*), $node as element(), $class as xs:string+, $content) {
    <span class="{$class}">
    {
        pmf:apply-children($config, $node, $content)
    }
    </span>
};

(:  
declare function pmf:dl($config as map(*), $node as element(), $class as xs:string+, $content) {
        <dl class="{$class}">
            { pmf:apply-children($config, $node, $content) }
        </dl>
};

declare function pmf:dt($config as map(*), $node as element(), $class as xs:string+, $content) {
            <dt class="{$class}">
                { pmf:apply-children($config, $node, $content) }
            </dt>
};

declare function pmf:dd($config as map(*), $node as element(), $class as xs:string+, $content) {
            <dd class="{$class}">
                { pmf:apply-children($config, $node, $content) }
            </dd>
};
:)

(: return a deep copy of  the element and all sub elements :)
declare function local:copy($element as element()) as element() {
   element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
                if ($child instance of comment()) then () else
                    if ($child instance of element() )
                        then local:copy($child)
                        else $child
      }
};
(: 
 :  : creates a div with xml tei code in it 
:)
declare function pmf:xml($config as map(*), $node as element(), $class as xs:string+, $content) {    
        let $type := $node/@type
        let $content2 := local:copy($content)
        let $content3 := util:serialize($content2,"indent=no")
        return
            <div class="{class} xml-tab {@type}">
                <pre>
                	<code class="epidoc">{$content3}</code>
                </pre>
            </div>
};


declare function pmf:popover($config as map(*), $node as element(), $class as xs:string+, $content,
                            $note-ref as xs:string, $pop-title as xs:string, $pop-content as item()*) {
(: todo = rajouter transformat pour rdg et lem:)
    let $bibliography := doc('/db/app/pyu/data/Pyu-Bibliography.xml')
    let $root := $node/ancestor-or-self::tei:TEI
    let $popover-content := <ul>
                                {
                                for $rdg in $pop-content
                                    let $resp := if (starts-with($rdg/@resp, "#")) then substring-after($rdg/@resp, '#') else string($rdg/@resp)
                                    let $resp-ref := doc('/db/apps/pyu/data/Pyu-Bibliography.xml')//tei:author[@xml:id=$resp]/tei:surname
                                    let $source := if (starts-with($rdg/@source, "#")) then substring-after($rdg/@source, '#') else string($rdg/@source)
                                    let $citedRange := $root//tei:bibl[@xml:id=$source]/tei:citedRange
                                    let $biblStruct := substring-after($root//tei:bibl[@xml:id=$source]/tei:ptr/@target,'pyu-bibl:')
                                    let $source-ref := doc('/db/apps/pyu/data/Pyu-Bibliography.xml')//tei:biblStruct[@xml:id=$biblStruct]//tei:title[@type='short']
                                    let $space := '&#32;'
                                    let $rdg-ref := if ($rdg/@resp and $rdg/@source) then $resp-ref || ' in ' || $source-ref || ' ' || $citedRange
                                        else if ($rdg/@resp) then $resp-ref
                                        else if ($rdg/@source) then $source-ref || ' ' || $source-ref || $citedRange
                                        else ()
                                return
                                   (: <li>{$citedRange}</li>:)
                                   <li><i>{$rdg}</i>{$space }{$rdg-ref}</li>
                                }
                            </ul>
    let $popid := concat('pop',translate(util:node-id($node),'.',''))
    return
        (<button type="button"
                class="btn btn-primary popover-app" 
                data-toggle="popover" 
                data-placement="top"
                data-popover-content="#{$popid}" data-html="true"
                data-original-title="{$pop-title}"
                aria-describedby="{$popid}">{$note-ref}</button>,
        <div class="popover fade top in" role="tooltip" id="{$popid}" style="">
            <div class="arrow" style="left: 50%;"></div>
            <h3 class="popover-title"/>
            <div class="popover-body">
                {$popover-content}
            </div>
        </div>)
};


(: may 2017 :)
(:  used only for links in the bibliography; AO changed on july 6 2017 on the basis of winona's app:rec-link :)
declare function pmf:bibl-link($config as map(*), $node as element(), $class as xs:string+, $content, $id as xs:string) {
    let $path := concat('/exist/apps/SAI/bibliography/',$id)
    return
    	<a href="{$path}" class="{$class}">
	     	{ pmf:apply-children($config, $node, $content) }
	    </a>
};

declare function pmf:headingPyu($config as map(*), $node as element(), $class as xs:string+, $content, $level) {
    let $level :=
        if ($level) then
            $level
        else if ($content/ancestor::tei:div[@type='edition']) then 4
        else if ($content instance of element()) then
            if ($config?parameters?root and $content/@exist:id) then
                let $node := util:node-by-id($config?parameters?root, $content/@exist:id)
                return
                    max((count($node/ancestor::tei:div), 1))
            else
                max((count($content/ancestor::tei:div), 1))
        else
            4
    return
        element { "h" || $level } {
            attribute class { $class },
            pmf:apply-children($config, $node, $content)
        }
};
(:  samedi 28 janvier 2017-  :)
declare function pmf:dl($config as map(*), $node as element(), $class as xs:string+, $content) {
    <dl class="{$class} dl-horizontal">
        { pmf:apply-children($config, $node, $content) }
    </dl>
}; 
declare function pmf:dt($config as map(*), $node as element(), $class as xs:string+, $content) {
    <dt>{pmf:apply-children($config, $node, $content)}</dt>
};
declare function pmf:dd($config as map(*), $node as element(), $class as xs:string+, $content) {
    <dd>{pmf:apply-children($config, $node, $content)}</dd>
};

(: modal for images, AO, june 17 2017 :)
declare function pmf:images($config as map(*), $node as element(), $class as xs:string+,$content) {
    <div class="row">
        <div class="col-md-4">{pmf:apply-children($config,$node,$content)}</div>
    </div>
};
declare function pmf:graphic($config as map(*), $node as element(), $class as xs:string+,$url) {
let $x := fn:substring-before(fn:substring-after($url,"images/"),".")
return
    <div class="col-lg-3 col-md-4 col-xs-6 thumb">
        <a class="thumbnail" href="#" data-toggle="modal" data-target="#{$x}">
            <img class="img-rounded" alt="" src="{concat("/exist/apps/SAI-data/",$url)}"></img>
        </a>
    </div>
};
declare function pmf:image-modals($config as map(*), $node as element(), $class as xs:string+,$images) {
let $modals := 
    for $i in $images
    let $url := fn:string($i/@url)
    let $id := fn:substring-before(fn:substring-after($url,"images/"),".")
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

declare function pmf:refbibl($config as map(*), $node as element(), $class as xs:string+, $link as xs:string+, $content) {
	let $prefix := 'bibl:'
	for $i in tokenize($link, ' ') 
		let $target := substring-after(data($i),$prefix)
		let $ref := collection($config:bibl-authority-dir)//tei:biblStruct[@xml:id=$target]			
		return
			pmf:make-bibl-link($ref)
};
(: use this for making an apparatus link :)
declare function pmf:bibl-author-key($config as map(*), $node as element(), $class as xs:string+, $content) {
	let $prefix := 'bibl:'
	let $tokens := tokenize($content, ' ')
	let $tokencount := count($tokens)
	let $result :=
	    for $i at $count in $tokens
		    let $target := substring-after(data($i),$prefix)
		    let $ref := collection($config:bibl-authority-dir)//tei:biblStruct[@xml:id=$target]
		    let $href := $pages:app-root || '/bibliography.html' || '#' || $target
		    let $connector :=
		        if ($count < $tokencount) then ', ' else ''
		    let $link := 
		        if ($ref//tei:author[@key][1])
		            then (<a class="{$class}" href="{$href}">{string($ref//tei:author[@key][1]/@key)}</a>,' ')
		        else if ($ref//tei:title[@type='short'])
		            then (pmf:make-bibl-link($ref),$connector)
		        else ()
		    return $link
	return <span>{$result}</span>
};
(: 
 : creates a link to the master bibliography 
:)
declare function pmf:make-bibl-link($ref as node()*) {
    let $title-short := $ref//tei:title[@type='short'][1]/text()    
    let $author-key := string($ref//tei:author[@key][1])
    (:the data contains some markup from the zotero db to tag some italics or sup:)
    let $title-deb := if (contains($title-short, '</i>')) then 
    						(substring-before($title-short,'<i>'))
                       else ($title-short)
    let $title-end := substring-after($title-short,'</i>')
    let $title-mid := substring-before(substring-after($title-short, '<i>'),'</i>')
    let $title-long := $ref//tei:title[not(@type='short')][1]
    let $target := $ref/@xml:id
    let $link := $pages:app-root || '/bibliography.html' || '#' || $target
    return 
        <a href="{$link}" title="{$title-long}" class="refbibl">{$title-deb}<span class="hi">{$title-mid}</span>{$title-end}</a>
};
(: 
 : creates an apparatus list 
:)
declare function pmf:list-app($config as map(*), $node as element(), $class as xs:string+, $content) {
    <ul class="{$class} list-inline">
    	{pmf:apply-children($config, $node, $content)}
    </ul>
};
declare function pmf:listItem-app($config as map(*), $node as element(), $class as xs:string+, $content) {
    let $loc :=
        if ($node/@loc) then $node/@loc
        else
           'loc'
    (:let $finale := 
    	 	if (ends-with(normalize-space($node),'.')) then () 
    		else '.':)
       	
    return
        
        	<li class="{$class} list-inline-item">
        	{ if ($loc) then 
            	<span class="loc">({pmf:apply-children($config, $node, $loc)})</span>
            	else ()
            }
            	{pmf:apply-children($config, $node, $content)}
            </li>
          
};
(:  samedi 11 février :)
declare function pmf:graphic-pyu($config as map(*), $node as element(), $class as xs:string+, $content, $url,
    $width, $height, $scale, $title) {
    let $style := if ($width) then "width: " || $width || "; " else ()
    let $style := if ($height) then $style || "height: " || $height || "; " else $style
    return
        <img src="{$url}" class="{$class}" title="{$title}">
        { if ($node/@xml:id) then attribute id { $node/@xml:id } else () }
        { if ($style) then attribute style { $style } else () }
        </img>
};
(: samedi 18 février :)
(: modification de pmf:listItem : ajout du paramètre icon :)



declare function pmf:listItemImage($config as map(*), $node as element(), $class as xs:string+, $content, $glyphicon as xs:string*, $material-icons as xs:string*) {
    let $label :=
        if ($node/../tei:label) then
            $node/preceding-sibling::*[1][self::tei:label]
        else
            ()
    let $classIcon :=
        if ($glyphicon) then
        'glyphicon ' || $glyphicon
        else 
            if ($material-icons) then
            'material-icons'
                else
                    ''
    let $icon :=
        if ($material-icons) then
            $material-icons
                else
                    '' 
    return
        if ($label) then (
            <dt>{pmf:apply-children($config, $node, $label)}</dt>,
            <dd>{pmf:apply-children($config, $node, $content)}</dd>
        ) else
            <li class="{$class}">
            {functx2:icon($classIcon, $icon)}
            {pmf:apply-children($config, $node, $content)}
            </li>
};

declare function pmf:separator($config as map(*), $node as element(), $class as xs:string+, $content) {
     	element { "hr" }
     		{ attribute class { $class } 
     	}
};

(: FUNCTIONS SPECIFIC TO THE SĀTAVĀHANA INSCRIPTIONS
 : PROJECT - ANDREW OLLETT :)
declare function pmf:name-orthography($config as map(*), $node as element(), $content) {
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
                pmf:name-element-to-string($name)
        let $joiner :=
            if ($pos eq $length) then "" else ", "
        return 
            if($inscription) then 
                <span><em>{ $namestring }</em>{' '}<a href="/exist/apps/SAI/inscription/{$inscription/@xml:id}">{$idno}</a>{ $joiner }</span>
            else ()
    return 
        <dd>{$attested}{" "}({ $spellings })</dd>
};
(: 

    return
        if($spellings) then 
            <dd>{ $ attested } ({ $spellings })</dd>
        else ()
};
 :)
declare function pmf:name-element-to-string($node as element()) {
    let $string := ""
    let $output := 
        for $i in ($node//text())
        let $text :=
            if (not($i/ancestor::tei:rdg) and not($i/ancestor::tei:corr) and not($i/ancestor::tei:note)) then $i
            else ""
        return concat($string,$text)
    return $output
};