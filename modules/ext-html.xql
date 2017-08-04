xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)

module namespace pmf="http://www.tei-c.org/tei-simple/xquery/ext-html";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(:import module namespace app="teipublisher.com/app" at "app.xql";:)

declare namespace config = "http://www.tei-c.org/tei-simple/config";
declare namespace pages="http://www.tei-c.org/tei-simple/pages";
declare namespace functx2 = "http://www.hisoma.mom.fr/labs/functx2";
declare namespace pm-config="http://www.tei-c.org/tei-simple/pm-config";
declare namespace app="teipublisher.com/app";
declare namespace functx="http://www.functx.com";



declare function pmf:code($config as map(*), $node as element(), $class as xs:string+, $content as node()*, $lang as item()?) {
    <pre class="sourcecode" data-language="{if ($lang) then $lang else 'xquery'}">
        { replace(string-join($content/node()), "^\s+?(.*)\s+$", "$1") }
    </pre>
};

(:~
 : Return an ID which may be used to look up a document. Change this if the xml:id
 : which uniquely identifies a document is *not* attached to the root element.
 :)
declare function app:get-id2($node as node()) {
    root($node)/*/@xml:id
};

(:~
 : Returns a path relative to $config:data-root used to locate a document in the database.
 :)
 declare function app:get-relpath2($node as node()) {
     let $root := if (ends-with($config:data-root, "/")) then $config:data-root else $config:data-root || "/"
     return
         substring-after(document-uri(root($node)), $root)
 };

declare function app:get-identifier2($node as node()) {
    if ($config:address-by-id) then
        app:get-id2($node)
    else
        app:get-relpath2($node)
};




declare function functx2:icon($ClassIcon as xs:string, $icon as xs:string) {
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
                        ' ')
                        (:space important see cheatsheet :)
 } ;
 
 declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {
   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;
 
 

(:  -------------------------------------------------------------------------- :)
(:                  #EM other functions copied or created                      :)
(:  -------------------------------------------------------------------------- :) 

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

(: 
 : deep copy of  the element and all sub elements
:)
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
(:  --------------------------------------------------- :)
(:                  #EM behaviours                      :)
(:  --------------------------------------------------- :)

(: 
 : adds the line breaks in html and optional labels
:)
declare function pmf:breakPyu($config as map(*), $node as element(), $class as xs:string+, 
                                $content, $type as xs:string?, $break as xs:string?, $label as item()*, $hyphen as xs:string) {
    switch($type)
        case "page" return
            (: à tester :)
            <span class="pageNumber {$class}">{pmf:apply-children($config, $node, $label)}</span>
        case "line" return
            (if ($break='yes') then 
            	if ($hyphen='yes') then ('-',<br/>)
            	else <br/>
            else(),
            <span class="lineNumber {$class}">({pmf:apply-children($config, $node, $label)})</span>)
        case "element" return
            (if ($break='yes') then 
            	if ($hyphen='yes') then ('-',<br/>)
            	else <br/>
            else(),
            <span class="{$class}"><span class="label">{$label}</span>{ pmf:apply-children($config, $node, $content) }</span>)
        default return
            (: default = no break :)
            <span class="{$class}">({pmf:apply-children($config, $node, $label)})</span>
};

(: 
 : creates definition lists
:)
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

(: à vérifier :)
declare function pmf:link2($config as map(*), $node as element(), $class as xs:string+, $content, $link as item()?) {
    <a href="{$link}" class="{$class}">{pmf:apply-children($config, $node, $content)}</a>
};


(: 
 : creates an apparatus list 
:)

declare function pmf:list-app($config as map(*), $node as element(), $class as xs:string+, $content) {
    <ul class="{$class} list-inline">
    	{pmf:apply-children($config, $node, $content)}
    </ul>
};

(: 
 : maybe to rewrite!
:)
declare function pmf:listItem-app($config as map(*), $node as element(), $class as xs:string+, $content) {
    let $loc :=
        if ($node/@loc) then $node/@loc
        else
           ()     	
            return
                 	<li class="{$class} list-inline-item">
                       	{ if ($loc) then 
                           	<span class="loc">({pmf:apply-children($config, $node, $loc)})</span>
                           	else ()
                        }
                    	{ pmf:apply-children($config, $node, $content) }
                    </li>
          
};

(: 
 : creates list of graphic elements (to verify)
:)
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

(: 
 : creates list with icons
:)
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
            <li class="listItemImage {$class}">
				 {functx2:icon($classIcon, $icon)}
            	<span>{pmf:apply-children($config, $node, $content)}</span>
            </li>
};

(: 
 : adds a fragment class for milestones
:)
declare function pmf:milestone($config as map(*), $node as element(), $class as xs:string+, $content, $unit as xs:string+, $label as item()*) {
    switch($unit)
        case "fragment" return
            <span class="{$class} fragment">{pmf:apply-children($config, $node, $label)}</span>
        case "face" return
            <span class="badge">{pmf:apply-children($config, $node, $label)}</span>
        case "pb" return
            <span class="badge">{pmf:apply-children($config, $node, $label)}</span>
       case "pb-phys" return            
           <span class="badge" style="float:right;">{pmf:apply-children($config, $node, $label)}</span>
        default return
            ''
};


(: 
 : creates a bootstrap popover (for inline apparatus criticus)
 : to revise
:)
declare function pmf:popover($config as map(*), $node as element(), $class as xs:string+, $content,
                            $note-ref as xs:string, $pop-title as xs:string, $pop-content as item()*) {
(: todo = rajouter transformat pour rdg et lem:)
	let $masterfile := $config:bibliography-masterfile 
	let $prefix := $config:bibliography-prefix || $config:bibliography-prefix-separator
	let $doc := doc($config:data-root || '/' || $masterfile)    
    let $root := $node/ancestor-or-self::tei:TEI
    let $odd := $config:odd    
    (: do not use web transormation otherwise the trans-formation will produce html markup (spans) that will not be passed to the popover title :)
    let $lem := $pm-config:web-transform($node/tei:lem, map { "root": $node/tei:lem }, $odd )	
      
    let $popover-content := <ul>
                                {
                                	for $rdg at $pos in $pop-content 
                                	
                                	let $total-attributes := count($rdg/@*)
                                	let $attributes :=$rdg/@*
                                	
									let $items := 
          								for $attribute in $attributes	
          										return
          											for $value in tokenize($attribute, ' ')          										
          												return local-name($attribute) ||':' || string($value)
          							let $myArray :=  for $item in $items return $item 
          							
          							let $rdg :=
                                		$pm-config:web-transform($rdg, map { "root": $rdg }, $odd )	
                                	
                                	return 
                                	
									<li>{$lem}<i>{$rdg}</i>:
										{
												for $i at $pos in $myArray 
													let $att-name := substring-before($i,':')
	          										let $att-value := substring-after($i,':')
													
													let $item :=
														switch ($att-name)
															case "resp" return substring-after($att-value, '#') 
															case "source" return app:find-source($att-value,$root)
															default return "default"
													let $total := count($myArray)
													let $separator :=
														if ($pos = 1) then () 
														else if ($pos = $total) then ' and '
														else ','
													let $space := '&#x20;'  
													return 
													<span>{$separator}{$space}{$item}</span>
										}
									</li>
									}
								</ul>
    let $popid := concat('pop',translate(util:node-id($node),'.',''))
   
    (: copied from sarit :)
    return
        (<button type="button"
                class="btn btn-primary popover-app" 
                data-toggle="popover" 
                data-placement="top"
                data-popover-content="#{$popid}" data-html="true"
                data-original-title="{$pop-title}&lt;i&gt;{string-join($lem,'')}&lt;/i&gt;"
                aria-describedby="{$popid}">{$note-ref}</button>,
        <div class="popover fade top in" role="tooltip" id="{$popid}" style="">
            <div class="arrow" style="left: 50%;"></div>
            <h3 class="popover-title">{$pop-title}</h3>
            <div class="popover-body">
                {$popover-content}
            </div>
        </div>)
};


(: 
 : creates the epigraphic publication links between a master bibliography and a <bibl><ptr> combinaison 
:)

declare function pmf:refbibl($config as map(*), $node as element(), $class as xs:string+, $content) {
	let $prefix := $config:bibliography-prefix || $config:bibliography-prefix-separator	
	let $masterfile := $config:bibliography-masterfile 	
		for $i in tokenize($content, ' ') 
			let $target := substring-after(data($i),$prefix)
			let $masterfile := $config:bibliography-masterfile 
			let $doc := doc($config:data-root || '/' || $masterfile)
			let $ref := $doc//tei:biblStruct[@xml:id=$target]			
    		return
				app:get-bibl-link($ref,$masterfile)
};

(: 
 : creates a link to the master bibliography 
 : rewrite $title-mid with regex for replacing <i> by span class=hi ?
:)
declare function app:get-bibl-link($ref as node()*, $masterfile as xs:string) {
    let $title-short := $ref//tei:title[@type='short'][1]/text()    
    (: the data contains some markup from the zotero db to tag some italics or sup :)
    let $title-short := replace ($title-short, "<i\\b[^>]*>(.*?)</i>", "<span class='hi'>$1</span>")
    let $title-long := $ref//tei:title[not(@type='short')][1]
    let $target := $ref/@xml:id
    (: tabs=no: to avoid the tabpanel and image gallery :)
    let $link := $pages:app-root || '/works/' || $masterfile || '?tabs=no' || '&amp;odd=' || $config:odd || '#' || $target
    let $class := 'refbibl'
    return 
        app:make-bibl-link($link,$title-short,$title-long,$class)
};

declare function app:make-bibl-link($link, $title-short, $title-long, $class as xs:string+) {
    <a href="{$link}" title="{$title-long}" class="{$class}">{$title-short}</a>
};



declare function app:make-bibl-tooltip($link,$key, $title-short, $class as xs:string+, $placement as xs:string?) {
    <a href="{$link}" class="{$class}" data-toggle="tooltip" data-placement="{$placement}" title="{$title-short}" data-original-title="{$title-short}">{$key}</a>
};

declare function pmf:bibl-initials-for-ref($config as map(*), $node as element(), $class as xs:string+, $content, $placement as xs:string?) {
	let $prefix := $config:bibliography-prefix || $config:bibliography-prefix-separator	
	let $masterfile := $config:bibliography-masterfile (: default could be overwritten by parameter given in ODD :)
		for $i in tokenize($content, ' ') 
			let $target := substring-after(data($i),$prefix)
			let $masterfile := $config:bibliography-masterfile (: default could be overwritten by parameter given in ODD :)
			let $doc := doc($config:data-root || '/' || $masterfile)
			let $ref := $doc//tei:biblStruct[@xml:id=$target]	
			(:let $target := $ref/@xml:id:)
			let $link := $pages:app-root || '/works/' || $masterfile || '?tabs=no' || '&amp;odd=' || $config:odd || '#' || $target
			let $key := if (exists($ref/@n)) then string($ref/@n) else ()
			let $key := if (ends-with($key, '.')) then substring-before($key,'.') else $key
			(: use case : 'et al. as end of abbreviation :)
			let $title-short := $ref//tei:title[@type='short'][1]/text() 
			let $title-short := replace ($title-short, "<i\\b[^>]*>(.*?)</i>", "<span class='hi'>$1</span>")
			let $placement := if ($placement) then $placement else 'top'
            let $result := if ($key!='') then  
                                app:make-bibl-tooltip($link,$key,$title-short,$class,$placement)
                                else ()
    		return
    		  $result
    		  
};


(: 
 : finds the good bibl node 
:)
declare function app:find-source ($source as xs:string, $root as element()){
	let $doc := doc($config:data-root || '/' || $config:bibliography-masterfile)

	let $citedRange := $root//tei:bibl[@xml:id=(substring-after($source, '#'))]/tei:citedRange 
	let $source :=		
		(: if internal id :)
			if (starts-with($source, "#")) then 
				let $source := substring-after($source, '#') 
				(: to find the target in the master bibliography:)
				let $biblStruct-target := substring-after($root//tei:bibl[@xml:id=$source]/tei:ptr/@target,$config:bibliography-prefix-separator)
				
				return
					app:get-bibl-link($doc//tei:biblStruct[@xml:id=$biblStruct-target],$config:bibliography-masterfile)
					
					
			(: if external id :)
			else if (starts-with($source, $config:bibliography-prefix)) then 
					let $source := substring-after($source,$config:bibliography-prefix-separator)
					let $biblStruct := $doc//tei:biblStruct[@xml:id=$source]	
					
					return
						app:get-bibl-link($doc//tei:biblStruct[@xml:id=$source],$config:bibliography-masterfile)
					
			else 
				 element {'span'} { attribute class {'danger'}, ' !! something is missing !!' } 
		return 
			$source || ' ' || $citedRange
				
};
(: 
 : when an has to be repeated (cf. gaps and lacunae)
:)
declare function pmf:repeat-string($config as map(*), $node as element(), 
    $content as xs:string?, $count as xs:integer?, $stringToRepeat as xs:string?) {
    let $stringToRepeat := $stringToRepeat
    let $count := $count
    for $i in (1 to $count) 
        return $stringToRepeat
};

(: 
 : gets the content of a node pointed to with @target (ptr)
:)
declare function pmf:resolve-pointer($config as map(*), $node as element(), $class as xs:string+, $content, $target as xs:string?) {
		let $target := $target
		let $file := util:document-name($node)
		let $doc := doc($config:data-root || '/' || $file)
		for $i in $doc//tei:*
		where (contains ($i/@xml:id, $target)) 
			return
				<span class="{$class}">					
					{ pmf:apply-children($config, $node, $i) }
				</span>				
};




(: 
 : creates a html5 section element
:)
(: à supprimer dans mesur où hr n'est pas utilisé et donc fait doublon avec la fonction section :)
declare function pmf:section($config as map(*), $node as element(), $class as xs:string+, $hr as xs:string?, $content) {
    (: #EM à revoir : pas de h3 vide si pas de valeur, faire une fonction ?:)
     (: #EM à revoir : controler la class :)
    <section class="{$class}">{ 
       (: if ($hr='yes') then element hr{ attribute class {'hr'} } else(),:)
        pmf:apply-children($config, $node, $content) 
    }
    </section>
};

(: 
 : creates a html5 collapsible section element - 
:)
declare function pmf:section-collapsible($config as map(*), $node as element(), $class as xs:string+, $id as xs:string, $button-title as xs:string?, $local-function as xs:string?, $content) {
    let $xml-edition := $node
    return
    <section class="{$class}">
        <div class="panel panel-default">             
              { if ($button-title != '') then
              <div class="panel-heading">
                
                 <h4 class="panel-title">
                    <a class="accordion-toggle" data-toggle="collapse" href="#collapse-{$id}">
                        {$button-title}
                    </a>
                    <hr/>
                 </h4>
               
                </div>
                 else ()
                 }
            
             <div id="collapse-{$id}" class="panel-collapse collapse in">
                 <div class="panel-body">                    
                    { pmf:apply-children($config, $node, $content) }
                 </div>
             </div>
        </div>
    </section>
};


(: 
 : creates a html5 collapsible section element - 
:)
declare function pmf:section-collapsible-with-tabs($config as map(*), $node as element(), $class as xs:string+, $id as xs:string, $button-title as xs:string?, $break as xs:string?, $content) {
    let $work := $node/ancestor-or-self::tei:TEI
    let $relPath := app:get-identifier2($work)
    return
    <section class="{$class}">
        <div class="panel panel-default">             
              { if ($button-title != '') then
              <div class="panel-heading">
                 <h4 class="panel-title">
                     <a class="accordion-toggle" data-toggle="collapse" href="#collapse-{$id}">
                         {$button-title}
                     </a>
                     <hr/>
                 </h4>                  
                </div>
                 else ()
                 }
             <div id="collapse-{$id}" class="panel-collapse collapse in">
                 { 
                        let $tabs := array {"Logical","Physical","XML"}
                        return  
                        <div class="panel-body">
                            <ul class="nav nav-tabs">
                              <li class="active"><a data-toggle="tab" href="#{$tabs?1}">{$tabs?1}</a></li>
                              <li><a data-toggle="tab" href="#{$tabs?2}">{$tabs?2}</a></li>
                              <li><a data-toggle="tab" href="#{$tabs?3}">{$tabs?3}</a></li>
                            </ul>                 
                            <div class="tab-content">                               
                                <div id="{$tabs?1}" class="tab-pane fade in active">
                                    { $pm-config:web-transform($node/node(), map { "root": $node/tei:div, "break": 'Logical' }, $config?odd ) }
                                </div>
                                <div id="{$tabs?2}" class="tab-pane fade">
                                    { $pm-config:web-transform($node/node(), map { "root": $node/tei:div, "break": 'Physical' }, $config?odd ) }
                                </div>
                                <div id="{$tabs?3}" class="tab-pane fade">
                                    { $pm-config:web-transform($node/node(), map { "root": $node/tei:div, "break": 'XML' }, $config?odd ) }
                                </div>
                             </div>
                       </div>
                    }
             </div>
        </div>
    </section>
};



(: 
 : creates a hr with class
:)
declare function pmf:separator($config as map(*), $node as element(), $class as xs:string+, $content) {
     	element { "hr" }
     		{ attribute class { $class } 
     	}
};

(: 
 : creates a span element
:)
declare function pmf:span($config as map(*), $node as element(), $class as xs:string+, $content) {
    <span class="{$class}">
    {
        pmf:apply-children($config, $node, $content)
    }
    </span>
};

(: 
 : creates a div with xml tei code in it 
:)
declare function pmf:xml($config as map(*), $node as element(), $class as xs:string+, $content) {    
        let $type := $node/@type
        let $content2 := local:copy($content)
        (:let $content3 := util:serialize($content2,"method=xml omit-xml-declaration=yes indent=no"):)
        let $content3 := util:serialize($content2,"indent=no")
        return
            <div class="{class} xml-tab {@type}">
                <pre>
                	<code class="epidoc">{$content3}</code>
                </pre>
            </div>
};


(:  --------------------------------------------------- :)
(:                  #EM tests                           :)
(:  --------------------------------------------------- :)

(: mars 2017:)
(:  
declare function pmf:relatedItem($config as map(*), $node as element(), $class as xs:string+, $content) {
	let $biblio := $node/tei:TEI//tei:biblStruct
	return
    <span class="relatedItem">
          { pmf:apply-children($config, $node, $content) }
    </span>
};
declare function app:relatedItem($funExpr as function($context as node()) as item()*, 
    $currenDoc as document-node())  as node()*
{
   $currenDoc//Name[. = $funExpr(.) ]
}
:)

(: may 2017 :)
declare function pmf:tooltip-link($config as map(*), $node as element(), $class as xs:string+, $content, $tooltip-text as xs:string) {
	<a href="#" data-toggle="tooltip" data-placement="right" title="{$tooltip-text}" class="{$class}">
	 	{ pmf:apply-children($config, $node, $content) }
	</a>
};

(: à revoir
declare function pmf:xsl-underdotted($config as map(*), $node as element(), 
    $class as xs:string, $content as node()*, $xsl as item()?) {
        <span class="transformed">
        {transform:transform($content, doc('/db/apps/inscriptions/resources/xsl/test.xsl'), ())}
        </span>
};
 :)
 
declare function pmf:tooltip($config as map(*), $node as element(), $class as xs:string+, $content, $tooltip-text as xs:string) {
	<span data-toggle="tooltip" data-placement="top" title="{$tooltip-text}" class="mouseover {$class}" data-html="true">
	 	{ pmf:apply-children($config, $node, $content) }
	</span>
};