(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/SAI/resources/odd/sai-customizations.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/sai-customizations/web";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace xi='http://www.w3.org/2001/XInclude';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

import module namespace ext-html="http://www.tei-c.org/tei-simple/xquery/ext-html" at "xmldb:exist:///db/apps/SAI/modules/ext-html.xql";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "xmldb:exist:///db/apps/tei-publisher/modules/config.xqm";

import module namespace sai-html="http://sai.indology.info" at "xmldb:exist:///db/apps/SAI/modules/sai-html.xql";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["web"],
                "odd": "/db/apps/SAI/resources/odd/sai-customizations.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))
    
    return (
        html:prepare($config, $input),
    
        model:apply($config, $input)
    )
};

declare function model:apply($config as map(*), $input as node()*) {
    let $parameters := 
        if (exists($config?parameters)) then $config?parameters else map {}
    return
    $input !         (
            typeswitch(.)
                case element(text) return
                    html:body($config, ., ("tei-text"), .)
                case element(ab) return
                    if (ancestor::div[@type='edition'] and $parameters?break='XML') then
                        ext-html:xml($config, ., ("tei-ab1"), .)
                    else
                        if (ancestor::div[@type='edition'] and @xml:lang) then
                            html:inline($config, ., ("tei-ab2"), .)
                        else
                            if (ancestor::div[@type='edition'] and (preceding-sibling::*[1][local-name()='lg'] or following-sibling::*[1][local-name()='lg']) and $parameters?break='Physical') then
                                html:inline($config, ., ("tei-ab3"), .)
                            else
                                if (ancestor::div[@type='edition'] and (preceding-sibling::*[1][local-name()='lg'] or following-sibling::*[1][local-name()='lg']) and $parameters?break='Logical') then
                                    html:block($config, ., ("tei-ab4", "prose-block"), .)
                                else
                                    if (ancestor::div[@type='edition']) then
                                        html:block($config, ., ("tei-ab5"), .)
                                    else
                                        if (ancestor::div[@type='textpart']) then
                                            html:block($config, ., ("tei-ab6"), .)
                                        else
                                            if (ancestor::div[@type='translation']) then
                                                html:block($config, ., ("tei-ab7"), .)
                                            else
                                                html:block($config, ., ("tei-ab8"), .)
                case element(abbr) return
                    html:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    html:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    html:inline($config, ., ("tei-add"), .)
                case element(address) return
                    html:block($config, ., ("tei-address"), .)
                case element(addrLine) return
                    html:block($config, ., ("tei-addrLine"), .)
                case element(am) return
                    html:inline($config, ., ("tei-am"), .)
                case element(anchor) return
                    html:anchor($config, ., ("tei-anchor"), ., @xml:id)
                case element(argument) return
                    html:block($config, ., ("tei-argument"), .)
                case element(author) return
                    if (ancestor::biblStruct) then
                        (
                            if (descendant-or-self::surname) then
                                (
                                    html:inline($config, ., ("tei-author1"), descendant-or-self::surname),
                                    html:text($config, ., ("tei-author2"), ', '),
                                    html:inline($config, ., ("tei-author3"), descendant-or-self::forename)
                                )

                            else
                                if (name) then
                                    html:inline($config, ., ("tei-author4"), name)
                                else
                                    $config?apply($config, ./node()),
                            if (child::* and following-sibling::author and (count(following-sibling::author) = 1)) then
                                html:text($config, ., ("tei-author5"), ' &#x26; ')
                            else
                                if (child::* and following-sibling::author and (count(following-sibling::author) > 1)) then
                                    html:text($config, ., ("tei-author6"), ', ')
                                else
                                    if (child::* and not(following-sibling::author)) then
                                        html:text($config, ., ("tei-author7"), if (ends-with(name/forename,'.')) then '' else '. ')
                                    else
                                        $config?apply($config, ./node())
                        )

                    else
                        $config?apply($config, ./node())
                case element(back) return
                    html:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl[@ana='#photo'] and following-sibling::bibl) then
                        html:listItem($config, ., ("tei-bibl1", "list-inline-item"), .)
                    else
                        if ((parent::listBibl[@ana='#photo'] and not(following-sibling::bibl))) then
                            html:listItem($config, ., ("tei-bibl2", "list-inline-item"), .)
                        else
                            if (parent::listBibl[@ana='#photo-estampage'] and following-sibling::bibl) then
                                html:listItem($config, ., ("tei-bibl3", "list-inline-item"), .)
                            else
                                if (parent::listBibl[@ana='#photo-estampage'] and not(following-sibling::bibl)) then
                                    html:listItem($config, ., ("tei-bibl4", "list-inline-item"), .)
                                else
                                    if (parent::listBibl[@ana='#rti'] and following-sibling::bibl) then
                                        html:listItem($config, ., ("tei-bibl5", "list-inline-item"), .)
                                    else
                                        if (parent::listBibl[@ana='#photo'] and not(following-sibling::bibl)) then
                                            html:listItem($config, ., ("tei-bibl6", "list-inline-item"), .)
                                        else
                                            if (parent::listBibl and ancestor::div[@type='bibliography']) then
                                                ext-html:listItemImage($config, ., ("tei-bibl7"), ., (), 'bookmark')
                                            else
                                                if (@rend='parens') then
                                                    html:inline($config, ., ("tei-bibl8", "bibl"), .)
                                                else
                                                    html:inline($config, ., ("tei-bibl9", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct) then
                        html:inline($config, ., ("tei-biblScope"), .)
                    else
                        $config?apply($config, ./node())
                case element(body) return
                    (
                        html:index($config, ., ("tei-body1"), 'toc', .),
                        html:block($config, ., ("tei-body2"), .)
                    )

                case element(byline) return
                    html:block($config, ., ("tei-byline"), .)
                case element(c) return
                    html:inline($config, ., ("tei-c"), .)
                case element(castGroup) return
                    if (child::*) then
                        (: Insert list. :)
                        html:list($config, ., ("tei-castGroup"), castItem|castGroup)
                    else
                        $config?apply($config, ./node())
                case element(castItem) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    html:listItem($config, ., ("tei-castItem"), .)
                case element(castList) return
                    if (child::*) then
                        html:list($config, ., css:get-rendition(., ("tei-castList")), castItem)
                    else
                        $config?apply($config, ./node())
                case element(cb) return
                    html:break($config, ., ("tei-cb"), ., 'column', @n)
                case element(cell) return
                    (: Insert table cell. :)
                    html:cell($config, ., ("tei-cell"), ., ())
                case element(choice) return
                    if (sic and corr) then
                        ext-html:tooltip($config, ., ("tei-choice1"), corr[1], concat('Correction for <i>',sic[1],'</>'))
                    else
                        if (reg and not(orig)) then
                            html:inline($config, ., ("tei-choice2"), reg)
                        else
                            $config?apply($config, ./node())
                case element(cit) return
                    (
                        html:inline($config, ., ("tei-cit1"), quote),
                        html:text($config, ., ("tei-cit2"), '('),
                        html:inline($config, ., ("tei-cit3"), bibl),
                        html:text($config, ., ("tei-cit4"), ')')
                    )

                case element(closer) return
                    html:block($config, ., ("tei-closer"), .)
                case element(code) return
                    html:inline($config, ., ("tei-code"), .)
                case element(corr) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        (: simple inline, if in parent choice. :)
                        html:inline($config, ., ("tei-corr1"), .)
                    else
                        html:inline($config, ., ("tei-corr2"), .)
                case element(date) return
                    if (@type and ancestor::biblStruct) then
                        (
                            if (@type='cover') then
                                html:inline($config, ., ("tei-date1"), .)
                            else
                                (),
                            if (@type='published') then
                                (
                                    html:text($config, ., ("tei-date2"), ' (published '),
                                    html:inline($config, ., ("tei-date3"), .),
                                    html:text($config, ., ("tei-date4"), ')')
                                )

                            else
                                ()
                        )

                    else
                        if (@when) then
                            (: desactive le comportement alternate de tei_simplePrint :)
                            html:inline($config, ., ("tei-date7"), .)
                        else
                            if (text()) then
                                html:inline($config, ., ("tei-date8"), .)
                            else
                                $config?apply($config, ./node())
                case element(dateline) return
                    html:block($config, ., ("tei-dateline"), .)
                case element(del) return
                    if (@rend='erasure') then
                        html:inline($config, ., ("tei-del"), .)
                    else
                        $config?apply($config, ./node())
                case element(desc) return
                    html:inline($config, ., ("tei-desc"), .)
                case element(div) return
                    if (@type='textpart') then
                        html:block($config, ., ("tei-div1", "texpart"), (
    html:block($config, ., ("tei-div2", "textpart-label"), concat(upper-case(substring(@n,1,1)),substring(@n,2))),
    html:block($config, ., ("tei-div3"), .)
)
)
                    else
                        if (@type='bibliography' and listBibl//*[text()[normalize-space(.)]]) then
                            ext-html:section-collapsible($config, ., ("tei-div4", "bibliography"), @type, 'Secondary bibliography', (), listBibl)
                        else
                            if (@type='translation' and *[text()[normalize-space(.)]]) then
                                (
                                    ext-html:section-collapsible($config, ., ("tei-div5", "translation"), @type,  let $plural := if (count(ab) > 1) then 's' else () return concat(upper-case(substring(@type,1,1)),substring(@type,2),$plural) , 'process-tabs', .)
                                )

                            else
                                if (@type='edition') then
                                    ext-html:section-collapsible-with-tabs($config, ., ("tei-div6", "edition"), @type, 'Edition', 'Logical', .)
                                else
                                    if (@type='apparatus' and *//*[text()[normalize-space(.)]]) then
                                        ext-html:section-collapsible($config, ., ("tei-div7", "apparatus"), @type, concat(upper-case(substring(@type,1,1)),substring(@type,2)), (), .)
                                    else
                                        if (@type='commentary' and *//*[text()[normalize-space(.)]]) then
                                            (
                                                ext-html:section-collapsible($config, ., ("tei-div8", "commentary", "cust-collapse"), @type, concat(upper-case(substring(@type,1,1)),substring(@type,2)), (), .)
                                            )

                                        else
                                            $config?apply($config, ./node())
                case element(docAuthor) return
                    html:inline($config, ., ("tei-docAuthor"), .)
                case element(docDate) return
                    html:inline($config, ., ("tei-docDate"), .)
                case element(docEdition) return
                    html:inline($config, ., ("tei-docEdition"), .)
                case element(docImprint) return
                    html:inline($config, ., ("tei-docImprint"), .)
                case element(docTitle) return
                    html:block($config, ., css:get-rendition(., ("tei-docTitle")), .)
                case element(editor) return
                    if (ancestor::biblStruct) then
                        (
                            if (name) then
                                html:inline($config, ., ("tei-editor1"), .)
                            else
                                if (descendant-or-self::surname) then
                                    (
                                        html:inline($config, ., ("tei-editor2"), descendant-or-self::forename),
                                        html:text($config, ., ("tei-editor3"), ' '),
                                        html:inline($config, ., ("tei-editor4"), descendant-or-self::surname)
                                    )

                                else
                                    $config?apply($config, ./node()),
                            if (following-sibling::editor and (count(following-sibling::editor) = 1)) then
                                html:text($config, ., ("tei-editor5"), ' &#x26; ')
                            else
                                if (following-sibling::editor and (count(following-sibling::editor) > 1)) then
                                    html:text($config, ., ("tei-editor6"), ', ')
                                else
                                    if (not(following-sibling::editor)) then
                                        html:text($config, ., ("tei-editor7"), ', ')
                                    else
                                        $config?apply($config, ./node())
                        )

                    else
                        if (ancestor::titleStmt) then
                            (
                                if (@role='general') then
                                    (
                                        html:inline($config, ., ("tei-editor8", "text-muted"), '[General editor: '),
                                        html:inline($config, ., ("tei-editor9", "text-muted"), concat(normalize-space(.),'.]'))
                                    )

                                else
                                    ()
                            )

                        else
                            $config?apply($config, ./node())
                case element(email) return
                    html:inline($config, ., ("tei-email"), .)
                case element(epigraph) return
                    html:block($config, ., ("tei-epigraph"), .)
                case element(ex) return
                    html:inline($config, ., ("tei-ex"), .)
                case element(expan) return
                    html:inline($config, ., ("tei-expan"), .)
                case element(figDesc) return
                    html:block($config, ., ("tei-figDesc", "text-center"), .)
                case element(figure) return
                    if (head) then
                        html:figure($config, ., ("tei-figure1", "figure"), *[not(self::head)], head/node())
                    else
                        html:block($config, ., ("tei-figure2", "figure", "text-center"), .)
                case element(floatingText) return
                    html:block($config, ., ("tei-floatingText"), .)
                case element(foreign) return
                    html:inline($config, ., ("tei-foreign"), .)
                case element(formula) return
                    if (@rendition='simple:display') then
                        html:block($config, ., ("tei-formula1"), .)
                    else
                        html:inline($config, ., ("tei-formula2"), .)
                case element(front) return
                    html:block($config, ., ("tei-front"), .)
                case element(fw) return
                    if (@place='marginleft') then
                        html:inline($config, ., ("tei-fw1", "fw"), .)
                    else
                        if (@place='marginright') then
                            html:inline($config, ., ("tei-fw2", "fw"), .)
                        else
                            $config?apply($config, ./node())
                case element(g) return
                    if (@type) then
                        html:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if (@reason='lost' and @unit='line' and @quantity=1) then
                        html:inline($config, ., ("tei-gap1"), '.')
                    else
                        if (@reason='lost' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                            html:inline($config, ., ("tei-gap2", "italic"), .)
                        else
                            if (@reason='illegible' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                html:inline($config, ., ("tei-gap3", "italic"), .)
                            else
                                if ((@reason='lost' and @unit='line') and child::certainty[@locus='name']) then
                                    html:inline($config, ., ("tei-gap4", "italic"), .)
                                else
                                    if ((@reason='illegible' and @unit='line') and child::certainty[@locus='name']) then
                                        html:inline($config, ., ("tei-gap5", "italic"), .)
                                    else
                                        if (@reason='lost' and @unit='line' and @quantity= 1) then
                                            html:inline($config, ., ("tei-gap6", "italic"), .)
                                        else
                                            if (@reason='illegible' and @unit='line' and @quantity= 1) then
                                                html:inline($config, ., ("tei-gap7", "italic"), .)
                                            else
                                                if (@reason='lost' and @unit='line' and @extent='unknown') then
                                                    html:inline($config, ., ("tei-gap8", "italic"), .)
                                                else
                                                    if (@reason='illegible' and @unit='line' and @extent='unknown') then
                                                        html:inline($config, ., ("tei-gap9", "italic"), .)
                                                    else
                                                        if (@reason='lost' and @extent='unknown') then
                                                            html:inline($config, ., ("tei-gap10", "italic"), .)
                                                        else
                                                            if (@unit='aksarapart' and @quantity=1) then
                                                                html:inline($config, ., ("tei-gap11", "aksarapart"), '.')
                                                            else
                                                                if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='lost') then
                                                                    html:inline($config, ., ("tei-gap12"), ' +')
                                                                else
                                                                    if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='illegible') then
                                                                        html:inline($config, ., ("tei-gap13"), ' ?')
                                                                    else
                                                                        if ((@reason='lost' or @reason='illegible') and @extent='unknown') then
                                                                            html:inline($config, ., ("tei-gap14"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||        @reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                        else
                                                                            if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::*[1][local-name()='lb']) then
                                                                                html:inline($config, ., ("tei-gap15", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||        @reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                            else
                                                                                if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and preceding-sibling::*[1][local-name()='lb']) then
                                                                                    html:inline($config, ., ("tei-gap16", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||        ')' || ' ' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || ' ' || $sep )
                                                                                else
                                                                                    if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::text()[1]) then
                                                                                        html:inline($config, ., ("tei-gap17", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||        ')' else (string-join((for $i in 1 to xs:integer($quantity) return ' ' || $charToRepeat),' ')) || $sep)
                                                                                    else
                                                                                        $config?apply($config, ./node())
                case element(graphic) return
                    if (ancestor::listPlace) then
                        html:graphic($config, ., ("tei-graphic1"), ., concat("/exist/apps/SAI-data/",@url), @width, @height, @scale, desc)
                    else
                        sai-html:graphic-cust($config, ., ("tei-graphic2"), @url)
                case element(group) return
                    html:block($config, ., ("tei-group"), .)
                case element(head) return
                    if ($parameters?header='short') then
                        html:inline($config, ., ("tei-head1"), replace(string-join(.//text()[not(parent::ref)]), '^(.*?)[^\w]*$', '$1'))
                    else
                        if (parent::figure) then
                            html:block($config, ., ("tei-head2"), .)
                        else
                            if (parent::table) then
                                html:block($config, ., ("tei-head3"), .)
                            else
                                if (parent::lg) then
                                    html:block($config, ., ("tei-head4"), .)
                                else
                                    if (parent::list) then
                                        html:block($config, ., ("tei-head5"), .)
                                    else
                                        if (parent::div[@type='edition']) then
                                            html:block($config, ., ("tei-head6"), .)
                                        else
                                            (: More than one model without predicate found for ident head. Choosing first one. :)
                                            if (parent::div and not(@n)) then
                                                html:heading($config, ., ("tei-head7"), ., count(ancestor::div))
                                            else
                                                if (parent::div and @n) then
                                                    sai-html:link($config, ., ("tei-head8"), ., @n)
                                                else
                                                    $config?apply($config, ./node())
                case element(hi) return
                    if (@type='italic') then
                        html:inline($config, ., ("tei-hi1"), .)
                    else
                        if (@type='bold') then
                            html:inline($config, ., ("tei-hi2"), .)
                        else
                            $config?apply($config, ./node())
                case element(imprimatur) return
                    html:block($config, ., ("tei-imprimatur"), .)
                case element(item) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    html:listItem($config, ., ("tei-item"), .)
                case element(l) return
                    if ($parameters?break='Logical' and parent::lg[@met='Anuṣṭubh' or @met='Āryā']) then
                        (: Distich display for Anuṣṭubh or Āryā stances. See also lg spec. :)
                        html:inline($config, ., ("tei-l1"), if (@n) then
    (
        html:inline($config, ., ("tei-l2", "verse-number"), @n),
        html:inline($config, ., ("tei-l3"), .)
    )

else
    $config?apply($config, ./node()))
                    else
                        if ($parameters?break='Logical') then
                            html:block($config, ., ("tei-l4"), if (@n) then
    (
        html:block($config, ., ("tei-l5", "verse-number"), @n),
        html:block($config, ., ("tei-l6"), .)
    )

else
    $config?apply($config, ./node()))
                        else
                            if ($parameters?break='Physical') then
                                html:inline($config, ., ("tei-l7"), .)
                            else
                                html:block($config, ., ("tei-l8"), .)
                case element(label) return
                    html:inline($config, ., ("tei-label"), .)
                case element(lb) return
                    (: More than one model without predicate found for ident lb. Choosing first one. :)
                    if (ancestor::lg and $parameters?break='Physical') then
                        ext-html:breakPyu($config, ., ("tei-lb1", (if (@break='no') then 'break-no' else ())), ., 'line', 'yes', if (@n) then @n else count(preceding-sibling::lb) + 1, if (@break='no') then 'yes' else 'no')
                    else
                        if ($parameters?break='Physical') then
                            ext-html:breakPyu($config, ., ("tei-lb2", (if (@break='no') then 'break-no' else ())), ., 'line', 'yes', if (@n) then @n else count(preceding-sibling::lb) + 1, if (@break='no') then 'yes' else 'no')
                        else
                            if (ancestor::lg and $parameters?break='Logical') then
                                ext-html:breakPyu($config, ., ("tei-lb3", (if (@break='no') then 'break-no' else ())), ., 'line', 'no', if (@n) then @n else count(preceding-sibling::lb) + 1, if (@break='no') then 'yes' else 'no')
                            else
                                if ($parameters?break='Logical') then
                                    ext-html:breakPyu($config, ., ("tei-lb4", (if (@break='no') then 'break-no' else ())), ., 'line', 'no', if (@n) then @n else count(preceding-sibling::lb) + 1, if (@break='no') then 'yes' else 'no')
                                else
                                    $config?apply($config, ./node())
                case element(lg) return
                    if (ancestor::div[@type='edition'] and $parameters?break='XML') then
                        ext-html:xml($config, ., ("tei-lg1"), .)
                    else
                        if ((@met or @n) and $parameters?break='Logical') then
                            html:block($config, ., ("tei-lg2", "stance-block"), (
    html:inline($config, ., ("tei-lg3", "stance-number"), @n),
    html:inline($config, ., ("tei-lg4", "stance-meter"), @met),
    if (@met='Anuṣṭubh' or @met='Āryā') then
        (
            html:block($config, ., ("tei-lg5", "stance-part", "distich"), (
    if (child::*[following-sibling::l[@n='a']]) then
        html:inline($config, ., ("tei-lg6"), child::*[following-sibling::l[@n='a']])
    else
        (),
    if (l[@n='a']) then
        html:inline($config, ., ("tei-lg7"), l[@n='a'])
    else
        (),
    if (child::*[preceding-sibling::l[@n='a']][following-sibling::l[@n='b']]) then
        html:inline($config, ., ("tei-lg8"), child::*[preceding-sibling::l[@n='a']][following-sibling::l[@n='b']])
    else
        (),
    if (l[@n='b']) then
        html:inline($config, ., ("tei-lg9"), l[@n='b'])
    else
        ()
)
),
            html:block($config, ., ("tei-lg10", "stance-part", "distich"), (
    if (child::*[preceding-sibling::l[@n='b']][following-sibling::l[@n='c']]) then
        html:inline($config, ., ("tei-lg11"), child::*[preceding-sibling::l[@n='b']][following-sibling::l[@n='c']])
    else
        (),
    html:inline($config, ., ("tei-lg12"), l[@n='c']),
    if (child::*[preceding-sibling::l[@n='c']][following-sibling::l[@n='d']]) then
        html:inline($config, ., ("tei-lg13"), child::*[preceding-sibling::l[@n='c']][following-sibling::l[@n='d']])
    else
        (),
    html:inline($config, ., ("tei-lg14"), l[@n='d'])
)
)
        )

    else
        (),
    if (not(@met='Anuṣṭubh' or @met='Āryā')) then
        html:block($config, ., ("tei-lg15", "stance-part"), .)
    else
        ()
)
)
                        else
                            if ((@met or @n) and $parameters?break='Physical') then
                                html:inline($config, ., ("tei-lg16"), .)
                            else
                                html:block($config, ., ("tei-lg17", "block"), .)
                case element(list) return
                    if (@rendition) then
                        html:list($config, ., css:get-rendition(., ("tei-list1")), item)
                    else
                        if (not(@rendition)) then
                            html:list($config, ., ("tei-list2"), item)
                        else
                            $config?apply($config, ./node())
                case element(listBibl) return
                    if (child::biblStruct) then
                        html:list($config, ., ("tei-listBibl1", "list-group", "master-bibliography"), biblStruct)
                    else
                        if (@ana='#photo-estampage') then
                            html:block($config, ., ("tei-listBibl2"), .)
                        else
                            if (@ana='#photo') then
                                html:block($config, ., ("tei-listBibl3"), .)
                            else
                                if (@ana='#rti') then
                                    html:block($config, ., ("tei-listBibl4"), .)
                                else
                                    if (ancestor::div[@type='bibliography']) then
                                        html:list($config, ., ("tei-listBibl5"), .)
                                    else
                                        if (bibl) then
                                            html:list($config, ., ("tei-listBibl6"), bibl)
                                        else
                                            $config?apply($config, ./node())
                case element(measure) return
                    html:inline($config, ., ("tei-measure"), .)
                case element(milestone) return
                    if (@unit='fragment') then
                        ext-html:milestone($config, ., ("tei-milestone1"), ., 'fragment', '///')
                    else
                        if (@unit='face') then
                            ext-html:milestone($config, ., ("tei-milestone2"), ., 'face', if (@n) then @n else (count(preceding-sibling::milestone[@unit='face']) + 1))
                        else
                            html:inline($config, ., ("tei-milestone3"), .)
                case element(name) return
                    if (child::choice and ancestor::biblStruct) then
                        html:inline($config, ., ("tei-name1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (./choice/reg[@type='simplified']) then
            html:inline($config, ., ("tei-name2"), choice/reg[@type='simplified'])
        else
            (),
        html:text($config, ., ("tei-name3"), ' '),
        if (./choice/reg[@type='simplified']) then
            html:inline($config, ., ("tei-name4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        html:inline($config, ., ("tei-name5"), .)
                case element(note) return
                    if (@type='tags' and ancestor::biblStruct) then
                        html:omit($config, ., ("tei-note1"), .)
                    else
                        if (@type='tag' and ancestor::biblStruct) then
                            html:omit($config, ., ("tei-note2"), .)
                        else
                            if (@type='accessed' and ancestor::biblStruct) then
                                html:omit($config, ., ("tei-note3"), .)
                            else
                                if (@type='thesisType' and ancestor::biblStruct) then
                                    html:omit($config, ., ("tei-note4"), .)
                                else
                                    if (not(@type) and ancestor::biblStruct) then
                                        html:omit($config, ., ("tei-note5"), .)
                                    else
                                        if (preceding-sibling::*[1][local-name()='relatedItem']) then
                                            (
                                                html:text($config, ., ("tei-note6"), '. '),
                                                html:inline($config, ., ("tei-note7"), .),
                                                html:text($config, ., ("tei-note8"), ' '),
                                                sai-html:link($config, ., ("tei-note9"), 'See related item',  '?tabs=no&amp;odd=' || request:get-parameter('odd', ()) || '?' || ../relatedItem/ref/@target)
                                            )

                                        else
                                            if (@type='url' and ancestor::biblStruct) then
                                                (
                                                    html:text($config, ., ("tei-note10"), '. URL: <'),
                                                    sai-html:link($config, ., ("tei-note11"), ., ()),
                                                    html:text($config, ., ("tei-note12"), '>')
                                                )

                                            else
                                                if ((ancestor::listApp or ancestor::listBibl) and (preceding-sibling::*[1][local-name() ='lem' or local-name()='rdg'] or parent::bibl)) then
                                                    (
                                                        html:inline($config, ., ("tei-note13", (ancestor::div/@type || '-note')), .)
                                                    )

                                                else
                                                    if (parent::notesStmt and child::text()[normalize-space(.)]) then
                                                        html:listItem($config, ., ("tei-note14"), .)
                                                    else
                                                        if (not(ancestor::biblStruct) and parent::bibl) then
                                                            html:inline($config, ., ("tei-note15"), .)
                                                        else
                                                            html:inline($config, ., ("tei-note16"), .)
                case element(num) return
                    html:inline($config, ., ("tei-num"), .)
                case element(opener) return
                    html:block($config, ., ("tei-opener"), .)
                case element(orig) return
                    html:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (@rend='stanza') then
                        html:block($config, ., ("tei-p1"), (
    html:inline($config, ., ("tei-p2", "stance-number"), concat(@n,'.')),
    html:paragraph($config, ., ("tei-p3"), .)
)
)
                    else
                        if (ancestor::div[@type='translation']) then
                            html:block($config, ., ("tei-p4"), .)
                        else
                            if (parent::surrogates) then
                                html:paragraph($config, ., ("tei-p5"), .)
                            else
                                if ($parameters?headerType='epidoc' and parent::div[@type='bibliography']) then
                                    html:inline($config, ., ("tei-p6"), .)
                                else
                                    if (parent::support) then
                                        html:inline($config, ., ("tei-p7"), .)
                                    else
                                        if (parent::provenance) then
                                            html:inline($config, ., ("tei-p8"), .)
                                        else
                                            if (ancestor::div[@type='commentary']) then
                                                html:paragraph($config, ., ("tei-p9"), .)
                                            else
                                                if (ancestor::desc) then
                                                    html:paragraph($config, ., ("tei-p10"), .)
                                                else
                                                    if ($parameters?header='short') then
                                                        html:omit($config, ., ("tei-p11"), .)
                                                    else
                                                        if (parent::div[@type='bibliography']) then
                                                            html:omit($config, ., ("tei-p12"), .)
                                                        else
                                                            html:block($config, ., ("tei-p13"), .)
                case element(pb) return
                    if (@type and $parameters?break='Physical') then
                        ext-html:milestone($config, ., ("tei-pb1"), ., 'pb-phys', let $n := if (@n) then @n else (count(preceding-sibling::milestone[@unit='face']) + 1) return @type || ' ' || $n)
                    else
                        if (@type and $parameters?break='Logical') then
                            ext-html:milestone($config, ., ("tei-pb2"), ., 'pb', if (@n) then @n else (count(preceding-sibling::milestone[@unit='face']) + 1))
                        else
                            html:omit($config, ., ("tei-pb3"), .)
                case element(pc) return
                    html:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    html:block($config, ., ("tei-postscript"), .)
                case element(publisher) return
                    if (ancestor::biblStruct) then
                        (
                            html:inline($config, ., ("tei-publisher1"), .),
                            if (parent::imprint/date) then
                                html:text($config, ., ("tei-publisher2"), ', ')
                            else
                                ()
                        )

                    else
                        html:inline($config, ., ("tei-publisher3"), .)
                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        (
                            html:inline($config, ., ("tei-pubPlace1"), .),
                            if (parent::imprint/pubPlace) then
                                html:text($config, ., ("tei-pubPlace2"), ': ')
                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(q) return
                    if (l) then
                        html:block($config, ., css:get-rendition(., ("tei-q1")), .)
                    else
                        if (ancestor::p or ancestor::cell) then
                            html:inline($config, ., css:get-rendition(., ("tei-q2")), .)
                        else
                            html:block($config, ., css:get-rendition(., ("tei-q3")), .)
                case element(quote) return
                    if (ancestor::teiHeader and parent::cit) then
                        (: If it is inside a cit then it is inline. :)
                        html:inline($config, ., ("tei-quote1"), .)
                    else
                        if (@rend='double') then
                            (: @rend='double' is rendered as double quotes. :)
                            html:inline($config, ., ("tei-quote2"), .)
                        else
                            if (ancestor::p or ancestor::note or ancestor::desc) then
                                html:inline($config, ., ("tei-quote3"), .)
                            else
                                (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                                html:block($config, ., css:get-rendition(., ("tei-quote4")), .)
                case element(ref) return
                    if (@rend='no-link') then
                        html:inline($config, ., ("tei-ref1"), .)
                    else
                        if (ancestor::div[@type='translation']) then
                            html:block($config, ., ("tei-ref2", "translation-ref"), .)
                        else
                            if (bibl[ptr[@target]]) then
                                html:inline($config, ., ("tei-ref3"), bibl/ptr)
                            else
                                if (starts-with(@target, concat('#', $config:project-code))) then
                                    sai-html:link($config, ., ("tei-ref4"), ., substring-after(@target,'#') || '.xml' || '?odd='|| request:get-parameter('odd', ()))
                                else
                                    if (not(@target)) then
                                        html:inline($config, ., ("tei-ref5"), .)
                                    else
                                        sai-html:link($config, ., ("tei-ref6"), @target, @target)
                case element(reg) return
                    if (@type='popular') then
                        (
                            html:text($config, ., ("tei-reg1"), '['),
                            html:inline($config, ., ("tei-reg2"), .),
                            html:text($config, ., ("tei-reg3"), ']')
                        )

                    else
                        if (@type='1' or @type='2' or @type='3'or @type='4'or @type='5'or @type='6' or @type='7') then
                            (
                                html:text($config, ., ("tei-reg4"), '['),
                                html:inline($config, ., ("tei-reg5"), .),
                                html:text($config, ., ("tei-reg6"), ']')
                            )

                        else
                            if (@type='simplified' or not(@type)) then
                                (
                                    html:inline($config, ., ("tei-reg7"), .),
                                    if (following-sibling::reg) then
                                        html:text($config, ., ("tei-reg8"), ' ')
                                    else
                                        ()
                                )

                            else
                                html:inline($config, ., ("tei-reg9"), reg)
                case element(relatedItem) return
                    (
                        html:text($config, ., ("tei-relatedItem1"), '. '),
                        html:inline($config, ., ("tei-relatedItem2"), .),
                        if (following-sibling::note) then
                            (
                                html:text($config, ., ("tei-relatedItem3"), '. '),
                                html:inline($config, ., ("tei-relatedItem4"), following-sibling::note)
                            )

                        else
                            ()
                    )

                case element(rhyme) return
                    html:inline($config, ., ("tei-rhyme"), .)
                case element(role) return
                    html:block($config, ., ("tei-role"), .)
                case element(roleDesc) return
                    html:block($config, ., ("tei-roleDesc"), .)
                case element(row) return
                    if (@role='label') then
                        html:row($config, ., ("tei-row1"), .)
                    else
                        (: Insert table row. :)
                        html:row($config, ., ("tei-row2"), .)
                case element(rs) return
                    html:inline($config, ., ("tei-rs"), .)
                case element(s) return
                    html:inline($config, ., ("tei-s"), .)
                case element(salute) return
                    if (parent::closer) then
                        html:inline($config, ., ("tei-salute1"), .)
                    else
                        html:block($config, ., ("tei-salute2"), .)
                case element(seg) return
                    if (@type='check') then
                        html:inline($config, ., ("tei-seg1", "seg"), .)
                    else
                        if (@type='graphemic') then
                            html:inline($config, ., ("tei-seg2", "seg"), .)
                        else
                            if (@type='phonetic') then
                                html:inline($config, ., ("tei-seg3", "seg"), .)
                            else
                                if (@type='phonemic') then
                                    html:inline($config, ., ("tei-seg4", "seg"), .)
                                else
                                    if (@type='translatedlines') then
                                        html:inline($config, ., ("tei-seg5"), .)
                                    else
                                        html:inline($config, ., ("tei-seg6"), .)
                case element(sic) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        html:inline($config, ., ("tei-sic1"), .)
                    else
                        html:inline($config, ., ("tei-sic2"), .)
                case element(signed) return
                    if (parent::closer) then
                        html:block($config, ., ("tei-signed1"), .)
                    else
                        html:inline($config, ., ("tei-signed2"), .)
                case element(sp) return
                    html:block($config, ., ("tei-sp"), .)
                case element(speaker) return
                    html:block($config, ., ("tei-speaker"), .)
                case element(spGrp) return
                    html:block($config, ., ("tei-spGrp"), .)
                case element(stage) return
                    html:block($config, ., ("tei-stage"), .)
                case element(subst) return
                    html:inline($config, ., ("tei-subst"), .)
                case element(supplied) return
                    if (parent::choice) then
                        html:inline($config, ., ("tei-supplied1"), .)
                    else
                        if (@reason='omitted') then
                            html:inline($config, ., ("tei-supplied2", ('supplied')), .)
                        else
                            if (@reason='lost' and not(ancestor::seg[@type='join'])) then
                                html:inline($config, ., ("tei-supplied3", ('supplied')), .)
                            else
                                html:inline($config, ., ("tei-supplied4", ('supplied')), .)
                case element(table) return
                    html:table($config, ., ("tei-table"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            html:inline($config, ., ("tei-fileDesc1", "header-short"), sourceDesc/msDesc/msIdentifier/idno),
                            html:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        (: More than one model without predicate found for ident fileDesc. Choosing first one. :)
                        ext-html:dl($config, ., ("tei-fileDesc3"), (
    (
        ext-html:dt($config, ., ("tei-fileDesc4"), 'Support '),
        ext-html:dd($config, ., ("tei-fileDesc5"), (
    html:inline($config, ., ("tei-fileDesc6"), sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support),
    html:inline($config, ., ("tei-fileDesc7"), sourceDesc/msDesc/physDesc/decoDesc)
)
),
        ext-html:dt($config, ., ("tei-fileDesc8"), 'Text '),
        ext-html:dd($config, ., ("tei-fileDesc9"), (
    html:inline($config, ., ("tei-fileDesc10"), sourceDesc/msDesc/msContents/msItem/textLang),
    html:inline($config, ., ("tei-fileDesc11"), sourceDesc/msDesc/physDesc/objectDesc/layoutDesc/layout),
    html:inline($config, ., ("tei-fileDesc12"), sourceDesc/msDesc/physDesc/handDesc)
)
),
        if (sourceDesc/msDesc/history/origin/origDate[text()[normalize-space(.)]]) then
            ext-html:dt($config, ., ("tei-fileDesc13"), 'Date ')
        else
            (),
        if (sourceDesc/msDesc/history/origin/origDate[text()[normalize-space(.)]]) then
            ext-html:dd($config, ., ("tei-fileDesc14"), sourceDesc/msDesc/history/origin/origDate)
        else
            (),
        if (sourceDesc/msDesc/history/origin) then
            ext-html:dt($config, ., ("tei-fileDesc15"), 'Origin ')
        else
            (),
        if (sourceDesc/msDesc/history/origin) then
            ext-html:dd($config, ., ("tei-fileDesc16"), sourceDesc/msDesc/history/origin/origPlace)
        else
            (),
        if (sourceDesc/msDesc/history/provenance) then
            ext-html:dt($config, ., ("tei-fileDesc17"), 'Provenance')
        else
            (),
        if (sourceDesc/msDesc/history/provenance) then
            ext-html:dd($config, ., ("tei-fileDesc18"), sourceDesc/msDesc/history/provenance)
        else
            (),
        if (sourceDesc/msDesc/additional//*[text()[normalize-space(.)]]) then
            ext-html:dt($config, ., ("tei-fileDesc19"), 'Visual Documentation')
        else
            (),
        if (sourceDesc/msDesc/additional//*[text()[normalize-space(.)]]) then
            ext-html:dd($config, ., ("tei-fileDesc20"), sourceDesc/msDesc/additional)
        else
            (),
        if (notesStmt/note[text()[normalize-space(.)]]) then
            ext-html:dt($config, ., ("tei-fileDesc21"), 'Note ')
        else
            (),
        if (notesStmt/note[text()[normalize-space(.)]]) then
            ext-html:dd($config, ., ("tei-fileDesc22"), notesStmt)
        else
            (),
        if (notesStmt/note[text()[normalize-space(.)]]) then
            ext-html:dt($config, ., ("tei-fileDesc23"), 'Note ')
        else
            (),
        if (notesStmt/note[text()[normalize-space(.)]]) then
            ext-html:dd($config, ., ("tei-fileDesc24"), notesStmt)
        else
            (),
        if (titleStmt/editor or titleStmt/respStmt) then
            ext-html:dt($config, ., ("tei-fileDesc25"), 'Credits ')
        else
            (),
        if (titleStmt/editor or titleStmt/respStmt) then
            (: See elementSpec/@ident='editor' for details. :)
            ext-html:dd($config, ., ("tei-fileDesc26"), if (titleStmt/editor or titleStmt/editor) then
    (
        html:inline($config, ., ("tei-fileDesc27"), titleStmt/respStmt),
        html:inline($config, ., ("tei-fileDesc28"), titleStmt/editor)
    )

else
    $config?apply($config, ./node()))
        else
            ()
    )
,
    if (../..//div[@type='bibliography']/p[text()[normalize-space(.)]]) then
        (
            ext-html:dt($config, ., ("tei-fileDesc29"), 'Publication history'),
            ext-html:dd($config, ., ("tei-fileDesc30"), ../..//div[@type='bibliography']/p)
        )

    else
        ()
)
)
                case element(profileDesc) return
                    html:omit($config, ., ("tei-profileDesc"), .)
                case element(revisionDesc) return
                    if ($parameters?headerType='epidoc') then
                        html:omit($config, ., ("tei-revisionDesc1"), .)
                    else
                        if ($parameters?header='short') then
                            html:omit($config, ., ("tei-revisionDesc2"), .)
                        else
                            $config?apply($config, ./node())
                case element(encodingDesc) return
                    html:omit($config, ., ("tei-encodingDesc"), .)
                case element(teiHeader) return
                    if ($parameters?header='short') then
                        html:inline($config, ., ("tei-teiHeader3"), .)
                    else
                        if ($parameters?headerType='epidoc') then
                            html:block($config, ., ("tei-teiHeader4"), .)
                        else
                            html:metadata($config, ., ("tei-teiHeader5"), .)
                case element(TEI) return
                    html:document($config, ., ("tei-TEI"), .)
                case element(term) return
                    html:inline($config, ., ("tei-term"), .)
                case element(text) return
                    html:body($config, ., ("tei-text"), .)
                case element(time) return
                    html:inline($config, ., ("tei-time"), .)
                case element(title) return
                    if ($parameters?header='short') then
                        html:inline($config, ., ("tei-title1"), .)
                    else
                        if (@type='translation' and ancestor::biblStruct) then
                            (
                                html:text($config, ., ("tei-title2"), ' '),
                                if (preceding-sibling::*[1][@type='transcription']) then
                                    html:text($config, ., ("tei-title3"), ' — ')
                                else
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        html:text($config, ., ("tei-title4"), '[')
                                    else
                                        $config?apply($config, ./node()),
                                html:inline($config, ., ("tei-title5"), .),
                                html:text($config, ., ("tei-title6"), ']')
                            )

                        else
                            if (@type='transcription' and ancestor::biblStruct) then
                                (
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        html:text($config, ., ("tei-title7"), ' ')
                                    else
                                        (),
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        html:text($config, ., ("tei-title8"), '[')
                                    else
                                        (),
                                    html:inline($config, ., ("tei-title9"), if ((@level='a' or @level='s' or @level='u') and ancestor::biblStruct) then
    html:inline($config, ., ("tei-title10"), .)
else
    if ((@level='j' or @level='m') and ancestor::biblStruct) then
        html:inline($config, ., ("tei-title11"), .)
    else
        html:inline($config, ., ("tei-title12"), .)),
                                    if (not(following-sibling::*[1][@type='translation'])) then
                                        html:text($config, ., ("tei-title13"), ']')
                                    else
                                        (),
                                    if (not(@level) and parent::bibl) then
                                        html:inline($config, ., ("tei-title14"), .)
                                    else
                                        ()
                                )

                            else
                                if (@type='short' and ancestor::biblStruct) then
                                    html:inline($config, ., ("tei-title15", "vedette"), .)
                                else
                                    if ((@level='a' or @level='s' or @level='u') and ancestor::biblStruct) then
                                        html:inline($config, ., ("tei-title16"), .)
                                    else
                                        if ((@level='j' or @level='m') and ancestor::biblStruct) then
                                            html:inline($config, ., ("tei-title17"), .)
                                        else
                                            $config?apply($config, ./node())
                case element(titlePage) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    html:block($config, ., ("tei-trailer"), .)
                case element(unclear) return
                    html:inline($config, ., ("tei-unclear1"), .)
                case element(w) return
                    if (@part='I' and $parameters?break='Physical') then
                        html:inline($config, ., ("tei-w1"), let $part-F := following::w[1] return concat(.,$part-F))
                    else
                        if (@part='F' and $parameters?break='Physical') then
                            html:omit($config, ., ("tei-w2"), .)
                        else
                            if (@type='hiatus-breaker') then
                                html:inline($config, ., ("tei-w3"), .)
                            else
                                if (index-of(ancestor::seg[@type='join']/w, self::w) = 1) then
                                    html:inline($config, ., ("tei-w4"), .)
                                else
                                    if (index-of(ancestor::seg[@type='join']/w, self::w) = count(ancestor::seg[@type='join']/w)) then
                                        html:inline($config, ., ("tei-w5"), .)
                                    else
                                        $config?apply($config, ./node())
                case element(additional) return
                    if ($parameters?headerType='epidoc') then
                        html:block($config, ., ("tei-additional"), .)
                    else
                        $config?apply($config, ./node())
                case element(analytic) return
                    if (ancestor::biblStruct) then
                        (
                            html:inline($config, ., ("tei-analytic1"), author),
                            if (following-sibling::*) then
                                html:text($config, ., ("tei-analytic2"), ', ')
                            else
                                (),
                            html:inline($config, ., ("tei-analytic3"), title)
                        )

                    else
                        $config?apply($config, ./node())
                case element(addName) return
                    html:inline($config, ., ("tei-addName"), .)
                case element(app) return
                    if (ancestor::div[@type='edition']) then
                        (
                            if (lem) then
                                html:inline($config, ., ("tei-app1"), lem)
                            else
                                ()
                        )

                    else
                        if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                            (
                                ext-html:listItem-app($config, ., ("tei-app2"), .)
                            )

                        else
                            $config?apply($config, ./node())
                case element(authority) return
                    html:omit($config, ., ("tei-authority"), .)
                case element(biblStruct) return
                    html:block($config, ., ("tei-biblStruct1", "bibl-citation"), (
    if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle' or @type='newspaperArticle') then
        (
            html:inline($config, ., ("tei-biblStruct2"), ./analytic/author),
            html:text($config, ., ("tei-biblStruct3"), ' '),
            if (relatedItem[@type='reviewOf']) then
                (
                    html:text($config, ., ("tei-biblStruct4"), ' review of '),
                    sai-html:link($config, ., ("tei-biblStruct5"), let $ref := substring-after(./relatedItem/ref/@target,'#') return ancestor::listBibl/biblStruct[@xml:id=$ref]/*/title[@type='short']/text(),  '?tabs=no&amp;odd=' || request:get-parameter('odd', ()) || '?' || ./relatedItem/ref/@target),
                    if (following-sibling::*) then
                        html:text($config, ., ("tei-biblStruct6"), ', ')
                    else
                        ()
                )

            else
                (),
            if (./analytic/title[not(@type='short')]) then
                (
                    html:text($config, ., ("tei-biblStruct7"), '“'),
                    html:inline($config, ., ("tei-biblStruct8"), ./analytic/title[not(@type='short')]),
                    html:text($config, ., ("tei-biblStruct9"), '.” ')
                )

            else
                (),
            if (@type='bookSection' or @type='encyclopediaArticle') then
                html:text($config, ., ("tei-biblStruct10"), 'in ')
            else
                (),
            html:inline($config, ., ("tei-biblStruct11"), ./monogr/title),
            if (following-sibling::*) then
                html:text($config, ., ("tei-biblStruct12"), ', ')
            else
                (),
            if (./monogr/author and (@type='bookSection' or @type='encyclopediaArticle')) then
                (
                    html:text($config, ., ("tei-biblStruct13"), 'by '),
                    html:inline($config, ., ("tei-biblStruct14"), ./monogr/author)
                )

            else
                ()
        )

    else
        (),
    if (@type='book' or @type='thesis' or @type='manuscript') then
        (
            html:inline($config, ., ("tei-biblStruct15"), ./monogr/author),
            html:inline($config, ., ("tei-biblStruct16", "monogr-title"), ./monogr/title[not(@type='short')]),
            html:text($config, ., ("tei-biblStruct17"), '. ')
        )

    else
        (),
    if (./monogr/editor) then
        (
            html:text($config, ., ("tei-biblStruct18"), 'edited by '),
            html:inline($config, ., ("tei-biblStruct19"), ./monogr/editor)
        )

    else
        (),
    html:inline($config, ., ("tei-biblStruct20"), ./series),
    if (monogr/biblScope[@unit='vol']) then
        html:inline($config, ., ("tei-biblStruct21"), ./monogr/biblScope[@unit='vol'])
    else
        (),
    if (monogr/imprint/date) then
        html:inline($config, ., ("tei-biblStruct22"), ./monogr/imprint)
    else
        (),
    if (monogr/biblScope[@unit='pp']) then
        (
            html:text($config, ., ("tei-biblStruct23"), ': '),
            html:inline($config, ., ("tei-biblStruct24"), monogr/biblScope[@unit='pp'])
        )

    else
        (),
    html:inline($config, ., ("tei-biblStruct25"), ./monogr/edition),
    html:inline($config, ., ("tei-biblStruct26"), .//note),
    if (not(./relatedItem/note)) then
        html:text($config, ., ("tei-biblStruct27"), '.')
    else
        ()
)
)
                case element(dimensions) return
                    if (ancestor::supportDesc or ancestor::layoutDesc) then
                        (
                            html:inline($config, ., ("tei-dimensions1"), .),
                            if (@unit) then
                                html:inline($config, ., ("tei-dimensions2"), @unit)
                            else
                                ()
                        )

                    else
                        html:inline($config, ., ("tei-dimensions3"), .)
                case element(edition) return
                    if (ancestor::biblStruct) then
                        (
                            html:text($config, ., ("tei-edition1"), '. '),
                            html:inline($config, ., ("tei-edition2"), .)
                        )

                    else
                        $config?apply($config, ./node())
                case element(forename) return
                    if (child::choice and ancestor::biblStruct) then
                        html:inline($config, ., ("tei-forename1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (choice/reg[@type='simplified']) then
            html:inline($config, ., ("tei-forename2"), choice/reg[@type='simplified'])
        else
            (),
        html:text($config, ., ("tei-forename3"), ' '),
        if (choice/reg[@type='simplified']) then
            html:inline($config, ., ("tei-forename4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        html:inline($config, ., ("tei-forename5"), .)
                case element(height) return
                    if (parent::dimensions and @precision='unknown') then
                        html:omit($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            html:inline($config, ., ("tei-height2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions and not(following-sibling::*)) then
                                html:inline($config, ., ("tei-height3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                    html:inline($config, ., ("tei-height4"), .)
                                else
                                    $config?apply($config, ./node())
                case element(width) return
                    if (parent::dimensions and count(following-sibling::*) >= 1) then
                        html:inline($config, ., ("tei-width1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (parent::dimensions) then
                            html:inline($config, ., ("tei-width2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                html:inline($config, ., ("tei-width3"), .)
                            else
                                $config?apply($config, ./node())
                case element(depth) return
                    if (parent::dimensions and @precision='unknown') then
                        html:omit($config, ., ("tei-depth1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            html:inline($config, ., ("tei-depth2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions) then
                                html:inline($config, ., ("tei-depth3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                html:inline($config, ., ("tei-depth4"), .)
                case element(dim) return
                    if (@type='diameter' and (parent::dimensions and following-sibling::*)) then
                        html:inline($config, ., ("tei-dim1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (@type='diameter' and (parent::dimensions and not(following-sibling::*))) then
                            html:inline($config, ., ("tei-dim2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                html:inline($config, ., ("tei-dim3"), .)
                            else
                                $config?apply($config, ./node())
                case element(handDesc) return
                    html:inline($config, ., ("tei-handDesc"), .)
                case element(handNote) return
                    html:inline($config, ., ("tei-handNote"), let $finale := if (ends-with(normalize-space(.),'.')) then () else if (*[text()[normalize-space(.)]]) then '.* ' else () return (.,$finale))
                case element(idno) return
                    if ($parameters?header='short') then
                        html:inline($config, ., ("tei-idno1"), .)
                    else
                        if (ancestor::publicationStmt) then
                            html:inline($config, ., ("tei-idno2"), .)
                        else
                            html:inline($config, ., ("tei-idno3"), .)
                case element(imprint) return
                    if (ancestor::biblStruct) then
                        (
                            html:inline($config, ., ("tei-imprint1"), pubPlace),
                            html:inline($config, ., ("tei-imprint2"), publisher),
                            if (following-sibling::date) then
                                html:text($config, ., ("tei-imprint3"), ', ')
                            else
                                (),
                            html:inline($config, ., ("tei-imprint4"), date),
                            if (biblScope[@unit='page']) then
                                html:text($config, ., ("tei-imprint5"), ': ')
                            else
                                (),
                            html:inline($config, ., ("tei-imprint6"), biblScope[@unit='page'])
                        )

                    else
                        $config?apply($config, ./node())
                case element(layout) return
                    html:inline($config, ., ("tei-layout"), .)
                (: There should be no dot before note if this element follows immediately after lem. This rule should be refined and limited to cases where lem had no source or rend. :)
                case element(lem) return
                    if (ancestor::listApp) then
                        (
                            html:inline($config, ., ("tei-lem1"), .),
                            if (@rend and not(following-sibling::*[1][local-name()='rdg'])) then
                                html:inline($config, ., ("tei-lem2", "bibl-rend"), if (ends-with(@rend,'.')) then substring-before(@rend,'.') else @rend)
                            else
                                (),
                            if (@rend and following-sibling::*[1][local-name()='rdg']) then
                                html:inline($config, ., ("tei-lem3", "bibl-rend"), @rend)
                            else
                                (),
                            if (@source) then
                                ext-html:bibl-initials-for-ref($config, ., ("tei-lem4", "bibl-initials"), @source, right)
                            else
                                (),
                            if (starts-with(@resp,concat($config:project-code,'-part:'))) then
                                html:inline($config, ., ("tei-lem5"), substring-after(@resp,concat($config:project-code,'-part:')))
                            else
                                (),
                            if (starts-with(@resp,'#')) then
                                sai-html:link($config, ., ("tei-lem6"), substring-after(@resp,'#'),  '?odd=' || request:get-parameter('odd', ()) || '&amp;view=' || request:get-parameter('view', ()) || '&amp;id='|| @resp)
                            else
                                (),
                            if (not(following-sibling::*[1][local-name() = ('rdg', 'note')]) or (@source or @rend)) then
                                html:inline($config, ., ("tei-lem7", "period"), '.')
                            else
                                ()
                        )

                    else
                        html:inline($config, ., ("tei-lem8"), .)
                case element(licence) return
                    html:omit($config, ., ("tei-licence"), .)
                case element(listApp) return
                    if (parent::div[@type='commentary']) then
                        ext-html:list-app($config, ., ("tei-listApp3"), .)
                    else
                        (: More than one model without predicate found for ident listApp. Choosing first one. :)
                        (
                            if (parent::div[@type='apparatus'] and @corresp) then
                                html:inline($config, ., ("tei-listApp1", "textpart-label"), let $id := substring-after(@corresp,'#') return preceding::div[@type='edition']//div[@type='textpart'][@xml:id=$id]/@n)
                            else
                                (),
                            if (parent::div[@type='apparatus']) then
                                ext-html:list-app($config, ., ("tei-listApp2"), .)
                            else
                                ()
                        )

                case element(notesStmt) return
                    html:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    html:inline($config, ., ("tei-objectDesc"), .)
                case element(persName) return
                    if (ancestor::div[@type]) then
                        sai-html:link($config, ., ("tei-persName1"), ., ())
                    else
                        if (ancestor::person and @type) then
                            html:inline($config, ., ("tei-persName2"), .)
                        else
                            if (ancestor::person) then
                                html:inline($config, ., ("tei-persName3"), .)
                            else
                                $config?apply($config, ./node())
                case element(physDesc) return
                    html:inline($config, ., ("tei-physDesc"), .)
                case element(provenance) return
                    if (parent::history) then
                        html:inline($config, ., ("tei-provenance"), .)
                    else
                        $config?apply($config, ./node())
                case element(ptr) return
                    if (parent::bibl and @target) then
                        sai-html:make-bibl-link($config, ., ("tei-ptr1"), @target, .)
                    else
                        if (not(parent::bibl) and not(text()) and @target[starts-with(.,'#')]) then
                            ext-html:resolve-pointer($config, ., ("tei-ptr2"), ., substring-after(@target,'#'))
                        else
                            if (not(text())) then
                                sai-html:link($config, ., ("tei-ptr3"), @target, ())
                            else
                                $config?apply($config, ./node())
                case element(rdg) return
                    if (ancestor::listApp) then
                        (
                            html:inline($config, ., ("tei-rdg1"), .),
                            if (@source and ancestor::listApp) then
                                ext-html:refbibl($config, ., ("tei-rdg2", "author-initials"), .)
                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(respStmt) return
                    html:inline($config, ., ("tei-respStmt"), concat(normalize-space(.),'. '))
                case element(series) return
                    if (ancestor::biblStruct) then
                        (
                            html:inline($config, ., ("tei-series1"), title),
                            if (biblScope) then
                                html:text($config, ., ("tei-series2"), ', ')
                            else
                                (),
                            html:inline($config, ., ("tei-series3"), biblScope),
                            html:text($config, ., ("tei-series4"), ', ')
                        )

                    else
                        $config?apply($config, ./node())
                case element(space) return
                    if (@type='horizontal' and child::certainty[@locus='name']) then
                        html:inline($config, ., ("tei-space1"), '◊ [...] ')
                    else
                        if ((@unit='character' or @unit='chars') and child::certainty[@locus='name']) then
                            html:inline($config, ., ("tei-space2"), '[◊]')
                        else
                            if (@type='horizontal') then
                                html:inline($config, ., ("tei-space3"), '◊')
                            else
                                if (@type='binding-hole') then
                                    html:inline($config, ., ("tei-space4"), '◯')
                                else
                                    if (@type='defect') then
                                        html:inline($config, ., ("tei-space5"), '□')
                                    else
                                        $config?apply($config, ./node())
                case element(supportDesc) return
                    html:inline($config, ., ("tei-supportDesc"), .)
                case element(surname) return
                    if (child::choice and ancestor::biblStruct) then
                        html:inline($config, ., ("tei-surname1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (choice/reg[@type='simplified']) then
            html:inline($config, ., ("tei-surname2"), choice/reg[@type='simplified'])
        else
            (),
        html:text($config, ., ("tei-surname3"), ' '),
        if (choice/reg[@type='simplified']) then
            html:inline($config, ., ("tei-surname4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        html:inline($config, ., ("tei-surname5"), .)
                case element(surrogates) return
                    html:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    html:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    html:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' return concat(normalize-space(.),$finale))
                case element(titleStmt) return
                    if ($parameters?header='short') then
                        (
                            sai-html:link($config, ., ("tei-titleStmt3"), title[1], $parameters?doc)
                        )

                    else
                        html:block($config, ., ("tei-titleStmt4"), .)
                case element(facsimile) return
                    if ($parameters?modal='true') then
                        sai-html:image-modals($config, ., ("tei-facsimile1"), graphic)
                    else
                        ext-html:section-collapsible($config, ., ("tei-facsimile2", "facsimile"), 'facsimile', 'Facsimiles', (), .)
                case element(geo) return
                    html:block($config, ., ("tei-geo"), .)
                case element(listPlace) return
                    if (@type='subsidiary') then
                        ext-html:section-collapsible($config, ., ("tei-listPlace"), @type, 'Sites located here', (), .)
                    else
                        $config?apply($config, ./node())
                case element(person) return
                    if (ancestor::listPerson) then
                        (
                            ext-html:dl($config, ., ("tei-person1"), (
    if (persName[not(@type)]) then
        (
            ext-html:dt($config, ., ("tei-person2"), 'Attested name'),
            sai-html:name-orthography($config, ., ("tei-person3"))
        )

    else
        (),
    if (persName[@type='pra-reconstruction']) then
        (
            ext-html:dt($config, ., ("tei-person4"), 'Normalized name'),
            ext-html:dd($config, ., ("tei-person5"), persName[@type='pra-reconstruction'])
        )

    else
        (),
    if (persName[@type='san-reconstruction']) then
        (
            ext-html:dt($config, ., ("tei-person6"), 'Sanskrit equivalent'),
            ext-html:dd($config, ., ("tei-person7"), persName[@type='san-reconstruction'])
        )

    else
        (),
    if (addName[@type='family']) then
        (
            ext-html:dt($config, ., ("tei-person8"), 'Family name'),
            ext-html:dd($config, ., ("tei-person9"), addName[@type='family'])
        )

    else
        ()
)
),
                            if (state or trait or residence or occupation) then
                                (
                                    ext-html:dl($config, ., ("tei-person10"), (
    if (state[@type='political']) then
        (
            ext-html:dt($config, ., ("tei-person11"), 'Political roles '),
            sai-html:state-or-trait($config, ., ("tei-person12"), state[@type='political'])
        )

    else
        (),
    if (state[@type='social']) then
        (
            ext-html:dt($config, ., ("tei-person13"), 'Social identifiers '),
            sai-html:state-or-trait($config, ., ("tei-person14"), state[@type='social'])
        )

    else
        (),
    if (trait[@type='ethnicity']) then
        (
            ext-html:dt($config, ., ("tei-person15"), 'Ethnicity '),
            sai-html:state-or-trait($config, ., ("tei-person16"), trait[@type='ethnicity'])
        )

    else
        (),
    if (trait[@type='gotra']) then
        (
            ext-html:dt($config, ., ("tei-person17"), 'Gotra '),
            sai-html:state-or-trait($config, ., ("tei-person18"), trait[@type='gotra'])
        )

    else
        (),
    if (occupation) then
        (
            ext-html:dt($config, ., ("tei-person19"), 'Occupation '),
            sai-html:state-or-trait($config, ., ("tei-person20"), occupation)
        )

    else
        ()
)
)
                                )

                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(place) return
                    if (ancestor::listPlace and not(ancestor::listPlace/ancestor::listPlace)) then
                        (
                            ext-html:dl($config, ., ("tei-place1"), (
    if (placeName[@type='modern']) then
        (
            ext-html:dt($config, ., ("tei-place2"), 'Modern names '),
            ext-html:dd($config, ., ("tei-place3"), placeName[@type='modern'])
        )

    else
        (),
    if (placeName[@type='ancient']) then
        (
            ext-html:dt($config, ., ("tei-place4"), 'Ancient names '),
            ext-html:dd($config, ., ("tei-place5"), placeName[@type='ancient'])
        )

    else
        (),
    if (desc) then
        (
            ext-html:dt($config, ., ("tei-place6"), 'Description'),
            ext-html:dd($config, ., ("tei-place7"), desc)
        )

    else
        ()
)
)
                        )

                    else
                        if (ancestor::listPlace) then
                            (
                                html:heading($config, ., ("tei-place8"), placeName, 4),
                                html:block($config, ., ("tei-place9"), desc)
                            )

                        else
                            $config?apply($config, ./node())
                case element(placeName) return
                    if (ancestor::div[@type] or ancestor::origPlace) then
                        sai-html:link($config, ., ("tei-placeName1"), ., ())
                    else
                        if (@xml:lang and @type='modern' and following-sibling::*[1][local-name()='placeName'][@type='modern']) then
                            sai-html:name-with-language($config, ., ("tei-placeName2"), .)
                        else
                            if (@xml:lang and @type='modern') then
                                sai-html:name-with-language($config, ., ("tei-placeName3"), .)
                            else
                                if (@xml:lang and @type='ancient' and following-sibling::*[1][local-name()='placeName'][@type='ancient']) then
                                    sai-html:name-with-language($config, ., ("tei-placeName4"), .)
                                else
                                    if (@xml:lang and @type='ancient') then
                                        sai-html:name-with-language($config, ., ("tei-placeName5"), .)
                                    else
                                        $config?apply($config, ./node())
                case element(exist:match) return
                    html:match($config, ., .)
                case element() return
                    if (namespace-uri(.) = 'http://www.tei-c.org/ns/1.0') then
                        $config?apply($config, ./node())
                    else
                        .
                case text() | xs:anyAtomicType return
                    html:escapeChars(.)
                default return 
                    $config?apply($config, ./node())

        )

};

declare function model:apply-children($config as map(*), $node as element(), $content as item()*) {
        
    $content ! (
        typeswitch(.)
            case element() return
                if (. is $node) then
                    $config?apply($config, ./node())
                else
                    $config?apply($config, .)
            default return
                html:escapeChars(.)
    )
};

