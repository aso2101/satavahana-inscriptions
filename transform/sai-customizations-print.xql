(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/SAI/resources/odd/sai-customizations.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/sai-customizations/fo";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace xi='http://www.w3.org/2001/XInclude';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace fo="http://www.tei-c.org/tei-simple/xquery/functions/fo";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "xmldb:exist:///db/apps/tei-publisher/modules/config.xqm";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["fo","print"],
                "odd": "/db/apps/SAI/resources/odd/sai-customizations.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))
    let $config := fo:init($config, $input)
    
    return (
        
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
                    fo:body($config, ., ("tei-text"), .)
                case element(ab) return
                    if (ancestor::div[@type='edition'] and $parameters?break='XML') then
                        (: No function found for behavior: xml :)
                        $config?apply($config, ./node())
                    else
                        if (ancestor::div[@type='edition'] and @xml:lang) then
                            fo:inline($config, ., ("tei-ab2"), .)
                        else
                            if (ancestor::div[@type='edition'] and (preceding-sibling::*[1][local-name()='lg'] or following-sibling::*[1][local-name()='lg']) and $parameters?break='Physical') then
                                fo:inline($config, ., ("tei-ab3"), .)
                            else
                                if (ancestor::div[@type='edition'] and (preceding-sibling::*[1][local-name()='lg'] or following-sibling::*[1][local-name()='lg']) and $parameters?break='Logical') then
                                    fo:block($config, ., ("tei-ab4", "prose-block"), .)
                                else
                                    if (ancestor::div[@type='edition']) then
                                        fo:block($config, ., ("tei-ab5"), .)
                                    else
                                        if (ancestor::div[@type='textpart']) then
                                            fo:block($config, ., ("tei-ab6"), .)
                                        else
                                            if (ancestor::div[@type='translation']) then
                                                fo:block($config, ., ("tei-ab7"), .)
                                            else
                                                fo:block($config, ., ("tei-ab8"), .)
                case element(abbr) return
                    fo:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    fo:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    fo:inline($config, ., ("tei-add"), .)
                case element(address) return
                    fo:block($config, ., ("tei-address"), .)
                case element(addrLine) return
                    fo:block($config, ., ("tei-addrLine"), .)
                case element(am) return
                    fo:inline($config, ., ("tei-am"), .)
                case element(anchor) return
                    fo:anchor($config, ., ("tei-anchor"), ., @xml:id)
                case element(argument) return
                    fo:block($config, ., ("tei-argument"), .)
                case element(author) return
                    if (ancestor::biblStruct) then
                        (
                            if (descendant-or-self::surname) then
                                (
                                    fo:inline($config, ., ("tei-author1"), descendant-or-self::surname),
                                    fo:text($config, ., ("tei-author2"), ', '),
                                    fo:inline($config, ., ("tei-author3"), descendant-or-self::forename)
                                )

                            else
                                if (name) then
                                    fo:inline($config, ., ("tei-author4"), name)
                                else
                                    $config?apply($config, ./node()),
                            if (child::* and following-sibling::author and (count(following-sibling::author) = 1)) then
                                fo:text($config, ., ("tei-author5"), ' &#x26; ')
                            else
                                if (child::* and following-sibling::author and (count(following-sibling::author) > 1)) then
                                    fo:text($config, ., ("tei-author6"), ', ')
                                else
                                    if (child::* and not(following-sibling::author)) then
                                        fo:text($config, ., ("tei-author7"), if (ends-with(name/forename,'.')) then '' else '. ')
                                    else
                                        $config?apply($config, ./node())
                        )

                    else
                        $config?apply($config, ./node())
                case element(back) return
                    fo:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl[@ana='#photo'] and following-sibling::bibl) then
                        fo:listItem($config, ., ("tei-bibl1", "list-inline-item"), .)
                    else
                        if ((parent::listBibl[@ana='#photo'] and not(following-sibling::bibl))) then
                            fo:listItem($config, ., ("tei-bibl2", "list-inline-item"), .)
                        else
                            if (parent::listBibl[@ana='#photo-estampage'] and following-sibling::bibl) then
                                fo:listItem($config, ., ("tei-bibl3", "list-inline-item"), .)
                            else
                                if (parent::listBibl[@ana='#photo-estampage'] and not(following-sibling::bibl)) then
                                    fo:listItem($config, ., ("tei-bibl4", "list-inline-item"), .)
                                else
                                    if (parent::listBibl[@ana='#rti'] and following-sibling::bibl) then
                                        fo:listItem($config, ., ("tei-bibl5", "list-inline-item"), .)
                                    else
                                        if (parent::listBibl[@ana='#photo'] and not(following-sibling::bibl)) then
                                            fo:listItem($config, ., ("tei-bibl6", "list-inline-item"), .)
                                        else
                                            if (parent::listBibl and ancestor::div[@type='bibliography']) then
                                                (: No function found for behavior: listItemImage :)
                                                $config?apply($config, ./node())
                                            else
                                                if (@rend='parens') then
                                                    fo:inline($config, ., ("tei-bibl8", "bibl"), .)
                                                else
                                                    fo:inline($config, ., ("tei-bibl9", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-biblScope"), .)
                    else
                        $config?apply($config, ./node())
                case element(body) return
                    (
                        fo:index($config, ., ("tei-body1"), ., 'toc'),
                        fo:block($config, ., ("tei-body2"), .)
                    )

                case element(byline) return
                    fo:block($config, ., ("tei-byline"), .)
                case element(c) return
                    fo:inline($config, ., ("tei-c"), .)
                case element(castGroup) return
                    if (child::*) then
                        (: Insert list. :)
                        fo:list($config, ., ("tei-castGroup"), castItem|castGroup)
                    else
                        $config?apply($config, ./node())
                case element(castItem) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    fo:listItem($config, ., ("tei-castItem"), .)
                case element(castList) return
                    if (child::*) then
                        fo:list($config, ., css:get-rendition(., ("tei-castList")), castItem)
                    else
                        $config?apply($config, ./node())
                case element(cb) return
                    fo:break($config, ., ("tei-cb"), ., 'column', @n)
                case element(cell) return
                    (: Insert table cell. :)
                    fo:cell($config, ., ("tei-cell"), ., ())
                case element(choice) return
                    if (sic and corr) then
                        (: No function found for behavior: tooltip :)
                        $config?apply($config, ./node())
                    else
                        if (reg and not(orig)) then
                            fo:inline($config, ., ("tei-choice2"), reg)
                        else
                            $config?apply($config, ./node())
                case element(cit) return
                    (
                        fo:inline($config, ., ("tei-cit1"), quote),
                        fo:text($config, ., ("tei-cit2"), '('),
                        fo:inline($config, ., ("tei-cit3"), bibl),
                        fo:text($config, ., ("tei-cit4"), ')')
                    )

                case element(closer) return
                    fo:block($config, ., ("tei-closer"), .)
                case element(code) return
                    fo:inline($config, ., ("tei-code"), .)
                case element(corr) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        (: simple inline, if in parent choice. :)
                        fo:inline($config, ., ("tei-corr1"), .)
                    else
                        fo:inline($config, ., ("tei-corr2"), .)
                case element(date) return
                    if (@type and ancestor::biblStruct) then
                        (
                            if (@type='cover') then
                                fo:inline($config, ., ("tei-date1"), .)
                            else
                                (),
                            if (@type='published') then
                                (
                                    fo:text($config, ., ("tei-date2"), ' (published '),
                                    fo:inline($config, ., ("tei-date3"), .),
                                    fo:text($config, ., ("tei-date4"), ')')
                                )

                            else
                                ()
                        )

                    else
                        if (text()) then
                            fo:inline($config, ., ("tei-date5"), .)
                        else
                            if (@when and not(text())) then
                                fo:inline($config, ., ("tei-date6"), @when)
                            else
                                if (text()) then
                                    fo:inline($config, ., ("tei-date8"), .)
                                else
                                    $config?apply($config, ./node())
                case element(dateline) return
                    fo:block($config, ., ("tei-dateline"), .)
                case element(del) return
                    if (@rend='erasure') then
                        fo:inline($config, ., ("tei-del"), .)
                    else
                        $config?apply($config, ./node())
                case element(desc) return
                    fo:inline($config, ., ("tei-desc"), .)
                case element(div) return
                    if (@type='textpart') then
                        fo:block($config, ., ("tei-div1", "texpart"), (
    fo:block($config, ., ("tei-div2", "textpart-label"), concat(upper-case(substring(@n,1,1)),substring(@n,2))),
    fo:block($config, ., ("tei-div3"), .)
)
)
                    else
                        if (@type='bibliography' and listBibl//*[text()[normalize-space(.)]]) then
                            (: No function found for behavior: section-collapsible :)
                            $config?apply($config, ./node())
                        else
                            if (@type='translation' and *[text()[normalize-space(.)]]) then
                                (
                                    (: No function found for behavior: section-collapsible :)
                                    $config?apply($config, ./node())
                                )

                            else
                                if (@type='edition') then
                                    (: No function found for behavior: section-collapsible-with-tabs :)
                                    $config?apply($config, ./node())
                                else
                                    if (@type='apparatus' and *//*[text()[normalize-space(.)]]) then
                                        (: No function found for behavior: section-collapsible :)
                                        $config?apply($config, ./node())
                                    else
                                        if (@type='commentary' and *//*[text()[normalize-space(.)]]) then
                                            (
                                                (: No function found for behavior: section-collapsible :)
                                                $config?apply($config, ./node())
                                            )

                                        else
                                            $config?apply($config, ./node())
                case element(docAuthor) return
                    fo:inline($config, ., ("tei-docAuthor"), .)
                case element(docDate) return
                    fo:inline($config, ., ("tei-docDate"), .)
                case element(docEdition) return
                    fo:inline($config, ., ("tei-docEdition"), .)
                case element(docImprint) return
                    fo:inline($config, ., ("tei-docImprint"), .)
                case element(docTitle) return
                    fo:block($config, ., css:get-rendition(., ("tei-docTitle")), .)
                case element(editor) return
                    if (ancestor::biblStruct) then
                        (
                            if (name) then
                                fo:inline($config, ., ("tei-editor1"), .)
                            else
                                if (descendant-or-self::surname) then
                                    (
                                        fo:inline($config, ., ("tei-editor2"), descendant-or-self::forename),
                                        fo:text($config, ., ("tei-editor3"), ' '),
                                        fo:inline($config, ., ("tei-editor4"), descendant-or-self::surname)
                                    )

                                else
                                    $config?apply($config, ./node()),
                            if (following-sibling::editor and (count(following-sibling::editor) = 1)) then
                                fo:text($config, ., ("tei-editor5"), ' &#x26; ')
                            else
                                if (following-sibling::editor and (count(following-sibling::editor) > 1)) then
                                    fo:text($config, ., ("tei-editor6"), ', ')
                                else
                                    if (not(following-sibling::editor)) then
                                        fo:text($config, ., ("tei-editor7"), ', ')
                                    else
                                        $config?apply($config, ./node())
                        )

                    else
                        if (ancestor::titleStmt) then
                            (
                                if (@role='general') then
                                    (
                                        fo:inline($config, ., ("tei-editor8", "text-muted"), '[General editor: '),
                                        fo:inline($config, ., ("tei-editor9", "text-muted"), concat(normalize-space(.),'.]'))
                                    )

                                else
                                    ()
                            )

                        else
                            $config?apply($config, ./node())
                case element(email) return
                    fo:inline($config, ., ("tei-email"), .)
                case element(epigraph) return
                    fo:block($config, ., ("tei-epigraph"), .)
                case element(ex) return
                    fo:inline($config, ., ("tei-ex"), .)
                case element(expan) return
                    fo:inline($config, ., ("tei-expan"), .)
                case element(figDesc) return
                    fo:block($config, ., ("tei-figDesc", "text-center"), .)
                case element(figure) return
                    if (head) then
                        fo:figure($config, ., ("tei-figure1", "figure"), *[not(self::head)], head/node())
                    else
                        fo:block($config, ., ("tei-figure2", "figure", "text-center"), .)
                case element(floatingText) return
                    fo:block($config, ., ("tei-floatingText"), .)
                case element(foreign) return
                    fo:inline($config, ., ("tei-foreign"), .)
                case element(formula) return
                    if (@rendition='simple:display') then
                        fo:block($config, ., ("tei-formula1"), .)
                    else
                        fo:inline($config, ., ("tei-formula2"), .)
                case element(front) return
                    fo:block($config, ., ("tei-front"), .)
                case element(fw) return
                    if (@place='marginleft') then
                        fo:inline($config, ., ("tei-fw1", "fw"), .)
                    else
                        if (@place='marginright') then
                            fo:inline($config, ., ("tei-fw2", "fw"), .)
                        else
                            $config?apply($config, ./node())
                case element(g) return
                    if (@type) then
                        fo:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if (@reason='lost' and @unit='line' and @quantity=1) then
                        fo:inline($config, ., ("tei-gap1"), '.')
                    else
                        if (@reason='lost' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                            fo:inline($config, ., ("tei-gap2", "italic"), .)
                        else
                            if (@reason='illegible' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                fo:inline($config, ., ("tei-gap3", "italic"), .)
                            else
                                if ((@reason='lost' and @unit='line') and child::certainty[@locus='name']) then
                                    fo:inline($config, ., ("tei-gap4", "italic"), .)
                                else
                                    if ((@reason='illegible' and @unit='line') and child::certainty[@locus='name']) then
                                        fo:inline($config, ., ("tei-gap5", "italic"), .)
                                    else
                                        if (@reason='lost' and @unit='line' and @quantity= 1) then
                                            fo:inline($config, ., ("tei-gap6", "italic"), .)
                                        else
                                            if (@reason='illegible' and @unit='line' and @quantity= 1) then
                                                fo:inline($config, ., ("tei-gap7", "italic"), .)
                                            else
                                                if (@reason='lost' and @unit='line' and @extent='unknown') then
                                                    fo:inline($config, ., ("tei-gap8", "italic"), .)
                                                else
                                                    if (@reason='illegible' and @unit='line' and @extent='unknown') then
                                                        fo:inline($config, ., ("tei-gap9", "italic"), .)
                                                    else
                                                        if (@reason='lost' and @extent='unknown') then
                                                            fo:inline($config, ., ("tei-gap10", "italic"), .)
                                                        else
                                                            if (@unit='aksarapart' and @quantity=1) then
                                                                fo:inline($config, ., ("tei-gap11", "aksarapart"), '.')
                                                            else
                                                                if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='lost') then
                                                                    fo:inline($config, ., ("tei-gap12"), ' +')
                                                                else
                                                                    if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='illegible') then
                                                                        fo:inline($config, ., ("tei-gap13"), ' ?')
                                                                    else
                                                                        if ((@reason='lost' or @reason='illegible') and @extent='unknown') then
                                                                            fo:inline($config, ., ("tei-gap14"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||        @reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                        else
                                                                            if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::*[1][local-name()='lb']) then
                                                                                fo:inline($config, ., ("tei-gap15", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||        @reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                            else
                                                                                if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and preceding-sibling::*[1][local-name()='lb']) then
                                                                                    fo:inline($config, ., ("tei-gap16", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||        ')' || ' ' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || ' ' || $sep )
                                                                                else
                                                                                    if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::text()[1]) then
                                                                                        fo:inline($config, ., ("tei-gap17", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||        ')' else (string-join((for $i in 1 to xs:integer($quantity) return ' ' || $charToRepeat),' ')) || $sep)
                                                                                    else
                                                                                        $config?apply($config, ./node())
                case element(graphic) return
                    if (ancestor::listPlace) then
                        fo:graphic($config, ., ("tei-graphic1"), ., concat("/exist/apps/SAI-data/",@url), @width, @height, @scale, desc)
                    else
                        (: No function found for behavior: graphic-cust :)
                        $config?apply($config, ./node())
                case element(group) return
                    fo:block($config, ., ("tei-group"), .)
                case element(head) return
                    if ($parameters?header='short') then
                        fo:inline($config, ., ("tei-head1"), replace(string-join(.//text()[not(parent::ref)]), '^(.*?)[^\w]*$', '$1'))
                    else
                        if (parent::figure) then
                            fo:block($config, ., ("tei-head2"), .)
                        else
                            if (parent::table) then
                                fo:block($config, ., ("tei-head3"), .)
                            else
                                if (parent::lg) then
                                    fo:block($config, ., ("tei-head4"), .)
                                else
                                    if (parent::list) then
                                        fo:block($config, ., ("tei-head5"), .)
                                    else
                                        if (parent::div[@type='edition']) then
                                            fo:block($config, ., ("tei-head6"), .)
                                        else
                                            (: More than one model without predicate found for ident head. Choosing first one. :)
                                            if (parent::div and not(@n)) then
                                                fo:heading($config, ., ("tei-head7"), .)
                                            else
                                                if (parent::div and @n) then
                                                    fo:link($config, ., ("tei-head8"), ., @n)
                                                else
                                                    $config?apply($config, ./node())
                case element(hi) return
                    if (@type='italic') then
                        fo:inline($config, ., ("tei-hi1"), .)
                    else
                        if (@type='bold') then
                            fo:inline($config, ., ("tei-hi2"), .)
                        else
                            $config?apply($config, ./node())
                case element(imprimatur) return
                    fo:block($config, ., ("tei-imprimatur"), .)
                case element(item) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    fo:listItem($config, ., ("tei-item"), .)
                case element(l) return
                    if ($parameters?break='Logical' and parent::lg[@met='Anuṣṭubh' or @met='Āryā']) then
                        (: Distich display for Anuṣṭubh or Āryā stances. See also lg spec. :)
                        fo:inline($config, ., ("tei-l1"), if (@n) then
    (
        fo:inline($config, ., ("tei-l2", "verse-number"), @n),
        fo:inline($config, ., ("tei-l3"), .)
    )

else
    $config?apply($config, ./node()))
                    else
                        if ($parameters?break='Logical') then
                            fo:block($config, ., ("tei-l4"), if (@n) then
    (
        fo:block($config, ., ("tei-l5", "verse-number"), @n),
        fo:block($config, ., ("tei-l6"), .)
    )

else
    $config?apply($config, ./node()))
                        else
                            if ($parameters?break='Physical') then
                                fo:inline($config, ., ("tei-l7"), .)
                            else
                                fo:block($config, ., ("tei-l8"), .)
                case element(label) return
                    fo:inline($config, ., ("tei-label"), .)
                case element(lb) return
                    fo:inline($config, ., ("tei-lb5", "lineNumber"), (
    fo:text($config, ., ("tei-lb6"), ' ('),
    fo:inline($config, ., ("tei-lb7"), if (@n) then @n else count(preceding-sibling::lb) + 1),
    fo:text($config, ., ("tei-lb8"), ') ')
)
)
                case element(lg) return
                    if (ancestor::div[@type='edition'] and $parameters?break='XML') then
                        (: No function found for behavior: xml :)
                        $config?apply($config, ./node())
                    else
                        if ((@met or @n) and $parameters?break='Logical') then
                            fo:block($config, ., ("tei-lg2", "stance-block"), (
    fo:inline($config, ., ("tei-lg3", "stance-number"), @n),
    fo:inline($config, ., ("tei-lg4", "stance-meter"), @met),
    if (@met='Anuṣṭubh' or @met='Āryā') then
        (
            fo:block($config, ., ("tei-lg5", "stance-part", "distich"), (
    if (child::*[following-sibling::l[@n='a']]) then
        fo:inline($config, ., ("tei-lg6"), child::*[following-sibling::l[@n='a']])
    else
        (),
    if (l[@n='a']) then
        fo:inline($config, ., ("tei-lg7"), l[@n='a'])
    else
        (),
    if (child::*[preceding-sibling::l[@n='a']][following-sibling::l[@n='b']]) then
        fo:inline($config, ., ("tei-lg8"), child::*[preceding-sibling::l[@n='a']][following-sibling::l[@n='b']])
    else
        (),
    if (l[@n='b']) then
        fo:inline($config, ., ("tei-lg9"), l[@n='b'])
    else
        ()
)
),
            fo:block($config, ., ("tei-lg10", "stance-part", "distich"), (
    if (child::*[preceding-sibling::l[@n='b']][following-sibling::l[@n='c']]) then
        fo:inline($config, ., ("tei-lg11"), child::*[preceding-sibling::l[@n='b']][following-sibling::l[@n='c']])
    else
        (),
    fo:inline($config, ., ("tei-lg12"), l[@n='c']),
    if (child::*[preceding-sibling::l[@n='c']][following-sibling::l[@n='d']]) then
        fo:inline($config, ., ("tei-lg13"), child::*[preceding-sibling::l[@n='c']][following-sibling::l[@n='d']])
    else
        (),
    fo:inline($config, ., ("tei-lg14"), l[@n='d'])
)
)
        )

    else
        (),
    if (not(@met='Anuṣṭubh' or @met='Āryā')) then
        fo:block($config, ., ("tei-lg15", "stance-part"), .)
    else
        ()
)
)
                        else
                            if ((@met or @n) and $parameters?break='Physical') then
                                fo:inline($config, ., ("tei-lg16"), .)
                            else
                                fo:block($config, ., ("tei-lg17", "block"), .)
                case element(list) return
                    if (@rendition) then
                        fo:list($config, ., css:get-rendition(., ("tei-list1")), item)
                    else
                        if (not(@rendition)) then
                            fo:list($config, ., ("tei-list2"), item)
                        else
                            $config?apply($config, ./node())
                case element(listBibl) return
                    if (child::biblStruct) then
                        fo:list($config, ., ("tei-listBibl1", "list-group", "master-bibliography"), biblStruct)
                    else
                        if (@ana='#photo-estampage') then
                            fo:block($config, ., ("tei-listBibl2"), .)
                        else
                            if (@ana='#photo') then
                                fo:block($config, ., ("tei-listBibl3"), .)
                            else
                                if (@ana='#rti') then
                                    fo:block($config, ., ("tei-listBibl4"), .)
                                else
                                    if (ancestor::div[@type='bibliography']) then
                                        fo:list($config, ., ("tei-listBibl5"), .)
                                    else
                                        if (bibl) then
                                            fo:list($config, ., ("tei-listBibl6"), bibl)
                                        else
                                            $config?apply($config, ./node())
                case element(measure) return
                    fo:inline($config, ., ("tei-measure"), .)
                case element(milestone) return
                    if (@unit='fragment') then
                        (: No function found for behavior: milestone :)
                        $config?apply($config, ./node())
                    else
                        if (@unit='face') then
                            (: No function found for behavior: milestone :)
                            $config?apply($config, ./node())
                        else
                            fo:inline($config, ., ("tei-milestone3"), .)
                case element(name) return
                    if (child::choice and ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-name1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (./choice/reg[@type='simplified']) then
            fo:inline($config, ., ("tei-name2"), choice/reg[@type='simplified'])
        else
            (),
        fo:text($config, ., ("tei-name3"), ' '),
        if (./choice/reg[@type='simplified']) then
            fo:inline($config, ., ("tei-name4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        fo:inline($config, ., ("tei-name5"), .)
                case element(note) return
                    if (@type='tags' and ancestor::biblStruct) then
                        fo:omit($config, ., ("tei-note1"), .)
                    else
                        if (@type='tag' and ancestor::biblStruct) then
                            fo:omit($config, ., ("tei-note2"), .)
                        else
                            if (@type='accessed' and ancestor::biblStruct) then
                                fo:omit($config, ., ("tei-note3"), .)
                            else
                                if (@type='thesisType' and ancestor::biblStruct) then
                                    fo:omit($config, ., ("tei-note4"), .)
                                else
                                    if (not(@type) and ancestor::biblStruct) then
                                        fo:omit($config, ., ("tei-note5"), .)
                                    else
                                        if (preceding-sibling::*[1][local-name()='relatedItem']) then
                                            (
                                                fo:text($config, ., ("tei-note6"), '. '),
                                                fo:inline($config, ., ("tei-note7"), .),
                                                fo:text($config, ., ("tei-note8"), ' '),
                                                fo:link($config, ., ("tei-note9"), 'See related item',  '?tabs=no&amp;odd=' || request:get-parameter('odd', ()) || '?' || ../relatedItem/ref/@target)
                                            )

                                        else
                                            if (@type='url' and ancestor::biblStruct) then
                                                (
                                                    fo:text($config, ., ("tei-note10"), '. URL: <'),
                                                    fo:link($config, ., ("tei-note11"), ., ()),
                                                    fo:text($config, ., ("tei-note12"), '>')
                                                )

                                            else
                                                if ((ancestor::listApp or ancestor::listBibl) and (preceding-sibling::*[1][local-name() ='lem' or local-name()='rdg'] or parent::bibl)) then
                                                    (
                                                        fo:inline($config, ., ("tei-note13", (ancestor::div/@type || '-note')), .)
                                                    )

                                                else
                                                    if (parent::notesStmt and child::text()[normalize-space(.)]) then
                                                        fo:listItem($config, ., ("tei-note14"), .)
                                                    else
                                                        if (not(ancestor::biblStruct) and parent::bibl) then
                                                            fo:inline($config, ., ("tei-note15"), .)
                                                        else
                                                            fo:inline($config, ., ("tei-note16"), .)
                case element(num) return
                    fo:inline($config, ., ("tei-num"), .)
                case element(opener) return
                    fo:block($config, ., ("tei-opener"), .)
                case element(orig) return
                    fo:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (@rend='stanza') then
                        fo:block($config, ., ("tei-p1"), (
    fo:inline($config, ., ("tei-p2", "stance-number"), concat(@n,'.')),
    fo:paragraph($config, ., ("tei-p3"), .)
)
)
                    else
                        if (ancestor::div[@type='translation']) then
                            fo:block($config, ., ("tei-p4"), .)
                        else
                            if (parent::surrogates) then
                                fo:paragraph($config, ., ("tei-p5"), .)
                            else
                                if ($parameters?headerType='epidoc' and parent::div[@type='bibliography']) then
                                    fo:inline($config, ., ("tei-p6"), .)
                                else
                                    if (parent::support) then
                                        fo:inline($config, ., ("tei-p7"), .)
                                    else
                                        if (parent::provenance) then
                                            fo:inline($config, ., ("tei-p8"), .)
                                        else
                                            if (ancestor::div[@type='commentary']) then
                                                fo:paragraph($config, ., ("tei-p9"), .)
                                            else
                                                if (ancestor::desc) then
                                                    fo:paragraph($config, ., ("tei-p10"), .)
                                                else
                                                    if ($parameters?header='short') then
                                                        fo:omit($config, ., ("tei-p11"), .)
                                                    else
                                                        if (parent::div[@type='bibliography']) then
                                                            fo:omit($config, ., ("tei-p12"), .)
                                                        else
                                                            fo:block($config, ., ("tei-p13"), .)
                case element(pb) return
                    if (@type and $parameters?break='Physical') then
                        (: No function found for behavior: milestone :)
                        $config?apply($config, ./node())
                    else
                        if (@type and $parameters?break='Logical') then
                            (: No function found for behavior: milestone :)
                            $config?apply($config, ./node())
                        else
                            fo:omit($config, ., ("tei-pb3"), .)
                case element(pc) return
                    fo:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    fo:block($config, ., ("tei-postscript"), .)
                case element(publisher) return
                    if (ancestor::biblStruct) then
                        (
                            fo:inline($config, ., ("tei-publisher1"), .),
                            if (parent::imprint/date) then
                                fo:text($config, ., ("tei-publisher2"), ', ')
                            else
                                ()
                        )

                    else
                        fo:inline($config, ., ("tei-publisher3"), .)
                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        (
                            fo:inline($config, ., ("tei-pubPlace1"), .),
                            if (parent::imprint/pubPlace) then
                                fo:text($config, ., ("tei-pubPlace2"), ': ')
                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(q) return
                    if (l) then
                        fo:block($config, ., css:get-rendition(., ("tei-q1")), .)
                    else
                        if (ancestor::p or ancestor::cell) then
                            fo:inline($config, ., css:get-rendition(., ("tei-q2")), .)
                        else
                            fo:block($config, ., css:get-rendition(., ("tei-q3")), .)
                case element(quote) return
                    if (ancestor::teiHeader and parent::cit) then
                        (: If it is inside a cit then it is inline. :)
                        fo:inline($config, ., ("tei-quote1"), .)
                    else
                        if (@rend='double') then
                            (: @rend='double' is rendered as double quotes. :)
                            fo:inline($config, ., ("tei-quote2"), .)
                        else
                            if (ancestor::p or ancestor::note or ancestor::desc) then
                                fo:inline($config, ., ("tei-quote3"), .)
                            else
                                (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                                fo:block($config, ., css:get-rendition(., ("tei-quote4")), .)
                case element(ref) return
                    if (@rend='no-link') then
                        fo:inline($config, ., ("tei-ref1"), .)
                    else
                        if (ancestor::div[@type='translation']) then
                            fo:block($config, ., ("tei-ref2", "translation-ref"), .)
                        else
                            if (bibl[ptr[@target]]) then
                                fo:inline($config, ., ("tei-ref3"), bibl/ptr)
                            else
                                if (starts-with(@target, concat('#', $config:project-code))) then
                                    fo:link($config, ., ("tei-ref4"), ., substring-after(@target,'#') || '.xml' || '?odd='|| request:get-parameter('odd', ()))
                                else
                                    if (not(@target)) then
                                        fo:inline($config, ., ("tei-ref5"), .)
                                    else
                                        fo:link($config, ., ("tei-ref6"), @target, @target)
                case element(reg) return
                    if (@type='popular') then
                        (
                            fo:text($config, ., ("tei-reg1"), '['),
                            fo:inline($config, ., ("tei-reg2"), .),
                            fo:text($config, ., ("tei-reg3"), ']')
                        )

                    else
                        if (@type='1' or @type='2' or @type='3'or @type='4'or @type='5'or @type='6' or @type='7') then
                            (
                                fo:text($config, ., ("tei-reg4"), '['),
                                fo:inline($config, ., ("tei-reg5"), .),
                                fo:text($config, ., ("tei-reg6"), ']')
                            )

                        else
                            if (@type='simplified' or not(@type)) then
                                (
                                    fo:inline($config, ., ("tei-reg7"), .),
                                    if (following-sibling::reg) then
                                        fo:text($config, ., ("tei-reg8"), ' ')
                                    else
                                        ()
                                )

                            else
                                fo:inline($config, ., ("tei-reg9"), reg)
                case element(relatedItem) return
                    (
                        fo:text($config, ., ("tei-relatedItem1"), '. '),
                        fo:inline($config, ., ("tei-relatedItem2"), .),
                        if (following-sibling::note) then
                            (
                                fo:text($config, ., ("tei-relatedItem3"), '. '),
                                fo:inline($config, ., ("tei-relatedItem4"), following-sibling::note)
                            )

                        else
                            ()
                    )

                case element(rhyme) return
                    fo:inline($config, ., ("tei-rhyme"), .)
                case element(role) return
                    fo:block($config, ., ("tei-role"), .)
                case element(roleDesc) return
                    fo:block($config, ., ("tei-roleDesc"), .)
                case element(row) return
                    if (@role='label') then
                        fo:row($config, ., ("tei-row1"), .)
                    else
                        (: Insert table row. :)
                        fo:row($config, ., ("tei-row2"), .)
                case element(rs) return
                    fo:inline($config, ., ("tei-rs"), .)
                case element(s) return
                    fo:inline($config, ., ("tei-s"), .)
                case element(salute) return
                    if (parent::closer) then
                        fo:inline($config, ., ("tei-salute1"), .)
                    else
                        fo:block($config, ., ("tei-salute2"), .)
                case element(seg) return
                    if (@type='check') then
                        fo:inline($config, ., ("tei-seg1", "seg"), .)
                    else
                        if (@type='graphemic') then
                            fo:inline($config, ., ("tei-seg2", "seg"), .)
                        else
                            if (@type='phonetic') then
                                fo:inline($config, ., ("tei-seg3", "seg"), .)
                            else
                                if (@type='phonemic') then
                                    fo:inline($config, ., ("tei-seg4", "seg"), .)
                                else
                                    if (@type='translatedlines') then
                                        fo:inline($config, ., ("tei-seg5"), .)
                                    else
                                        fo:inline($config, ., ("tei-seg6"), .)
                case element(sic) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        fo:inline($config, ., ("tei-sic1"), .)
                    else
                        fo:inline($config, ., ("tei-sic2"), .)
                case element(signed) return
                    if (parent::closer) then
                        fo:block($config, ., ("tei-signed1"), .)
                    else
                        fo:inline($config, ., ("tei-signed2"), .)
                case element(sp) return
                    fo:block($config, ., ("tei-sp"), .)
                case element(speaker) return
                    fo:block($config, ., ("tei-speaker"), .)
                case element(spGrp) return
                    fo:block($config, ., ("tei-spGrp"), .)
                case element(stage) return
                    fo:block($config, ., ("tei-stage"), .)
                case element(subst) return
                    fo:inline($config, ., ("tei-subst"), .)
                case element(supplied) return
                    fo:text($config, ., ("tei-supplied5"), .)
                case element(table) return
                    fo:table($config, ., ("tei-table"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            fo:inline($config, ., ("tei-fileDesc1", "header-short"), sourceDesc/msDesc/msIdentifier/idno),
                            fo:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        fo:title($config, ., ("tei-fileDesc31"), titleStmt)
                case element(profileDesc) return
                    fo:omit($config, ., ("tei-profileDesc"), .)
                case element(revisionDesc) return
                    if ($parameters?headerType='epidoc') then
                        fo:omit($config, ., ("tei-revisionDesc1"), .)
                    else
                        if ($parameters?header='short') then
                            fo:omit($config, ., ("tei-revisionDesc2"), .)
                        else
                            $config?apply($config, ./node())
                case element(encodingDesc) return
                    fo:omit($config, ., ("tei-encodingDesc"), .)
                case element(teiHeader) return
                    fo:omit($config, ., ("tei-teiHeader2"), .)
                case element(TEI) return
                    fo:document($config, ., ("tei-TEI"), .)
                case element(term) return
                    fo:inline($config, ., ("tei-term"), .)
                case element(text) return
                    fo:body($config, ., ("tei-text"), .)
                case element(time) return
                    fo:inline($config, ., ("tei-time"), .)
                case element(title) return
                    if ($parameters?header='short') then
                        fo:inline($config, ., ("tei-title1"), .)
                    else
                        if (@type='translation' and ancestor::biblStruct) then
                            (
                                fo:text($config, ., ("tei-title2"), ' '),
                                if (preceding-sibling::*[1][@type='transcription']) then
                                    fo:text($config, ., ("tei-title3"), ' — ')
                                else
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        fo:text($config, ., ("tei-title4"), '[')
                                    else
                                        $config?apply($config, ./node()),
                                fo:inline($config, ., ("tei-title5"), .),
                                fo:text($config, ., ("tei-title6"), ']')
                            )

                        else
                            if (@type='transcription' and ancestor::biblStruct) then
                                (
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        fo:text($config, ., ("tei-title7"), ' ')
                                    else
                                        (),
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        fo:text($config, ., ("tei-title8"), '[')
                                    else
                                        (),
                                    fo:inline($config, ., ("tei-title9"), if ((@level='a' or @level='s' or @level='u') and ancestor::biblStruct) then
    fo:inline($config, ., ("tei-title10"), .)
else
    if ((@level='j' or @level='m') and ancestor::biblStruct) then
        fo:inline($config, ., ("tei-title11"), .)
    else
        fo:inline($config, ., ("tei-title12"), .)),
                                    if (not(following-sibling::*[1][@type='translation'])) then
                                        fo:text($config, ., ("tei-title13"), ']')
                                    else
                                        (),
                                    if (not(@level) and parent::bibl) then
                                        fo:inline($config, ., ("tei-title14"), .)
                                    else
                                        ()
                                )

                            else
                                if (@type='short' and ancestor::biblStruct) then
                                    fo:inline($config, ., ("tei-title15", "vedette"), .)
                                else
                                    if ((@level='a' or @level='s' or @level='u') and ancestor::biblStruct) then
                                        fo:inline($config, ., ("tei-title16"), .)
                                    else
                                        if ((@level='j' or @level='m') and ancestor::biblStruct) then
                                            fo:inline($config, ., ("tei-title17"), .)
                                        else
                                            $config?apply($config, ./node())
                case element(titlePage) return
                    fo:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    fo:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    fo:block($config, ., ("tei-trailer"), .)
                case element(unclear) return
                    (: More than one model without predicate found for ident unclear. Choosing first one. :)
                    fo:inline($config, ., ("tei-unclear1"), .)
                case element(w) return
                    if (@part='I' and $parameters?break='Physical') then
                        fo:inline($config, ., ("tei-w1"), let $part-F := following::w[1] return concat(.,$part-F))
                    else
                        if (@part='F' and $parameters?break='Physical') then
                            fo:omit($config, ., ("tei-w2"), .)
                        else
                            if (@type='hiatus-breaker') then
                                fo:inline($config, ., ("tei-w3"), .)
                            else
                                if (index-of(ancestor::seg[@type='join']/w, self::w) = 1) then
                                    fo:inline($config, ., ("tei-w4"), .)
                                else
                                    if (index-of(ancestor::seg[@type='join']/w, self::w) = count(ancestor::seg[@type='join']/w)) then
                                        fo:inline($config, ., ("tei-w5"), .)
                                    else
                                        $config?apply($config, ./node())
                case element(additional) return
                    if ($parameters?headerType='epidoc') then
                        fo:block($config, ., ("tei-additional"), .)
                    else
                        $config?apply($config, ./node())
                case element(analytic) return
                    if (ancestor::biblStruct) then
                        (
                            fo:inline($config, ., ("tei-analytic1"), author),
                            if (following-sibling::*) then
                                fo:text($config, ., ("tei-analytic2"), ', ')
                            else
                                (),
                            fo:inline($config, ., ("tei-analytic3"), title)
                        )

                    else
                        $config?apply($config, ./node())
                case element(addName) return
                    fo:inline($config, ., ("tei-addName"), .)
                case element(app) return
                    if (ancestor::div[@type='edition']) then
                        (
                            if (lem) then
                                fo:inline($config, ., ("tei-app1"), lem)
                            else
                                ()
                        )

                    else
                        if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                            (
                                (: No function found for behavior: listItem-app :)
                                $config?apply($config, ./node())
                            )

                        else
                            $config?apply($config, ./node())
                case element(authority) return
                    fo:omit($config, ., ("tei-authority"), .)
                case element(biblStruct) return
                    fo:block($config, ., ("tei-biblStruct1", "bibl-citation"), (
    if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle' or @type='newspaperArticle') then
        (
            fo:inline($config, ., ("tei-biblStruct2"), ./analytic/author),
            fo:text($config, ., ("tei-biblStruct3"), ' '),
            if (relatedItem[@type='reviewOf']) then
                (
                    fo:text($config, ., ("tei-biblStruct4"), ' review of '),
                    fo:link($config, ., ("tei-biblStruct5"), let $ref := substring-after(./relatedItem/ref/@target,'#') return ancestor::listBibl/biblStruct[@xml:id=$ref]/*/title[@type='short']/text(),  '?tabs=no&amp;odd=' || request:get-parameter('odd', ()) || '?' || ./relatedItem/ref/@target),
                    if (following-sibling::*) then
                        fo:text($config, ., ("tei-biblStruct6"), ', ')
                    else
                        ()
                )

            else
                (),
            if (./analytic/title[not(@type='short')]) then
                (
                    fo:text($config, ., ("tei-biblStruct7"), '“'),
                    fo:inline($config, ., ("tei-biblStruct8"), ./analytic/title[not(@type='short')]),
                    fo:text($config, ., ("tei-biblStruct9"), '.” ')
                )

            else
                (),
            if (@type='bookSection' or @type='encyclopediaArticle') then
                fo:text($config, ., ("tei-biblStruct10"), 'in ')
            else
                (),
            fo:inline($config, ., ("tei-biblStruct11"), ./monogr/title),
            if (following-sibling::*) then
                fo:text($config, ., ("tei-biblStruct12"), ', ')
            else
                (),
            if (./monogr/author and (@type='bookSection' or @type='encyclopediaArticle')) then
                (
                    fo:text($config, ., ("tei-biblStruct13"), 'by '),
                    fo:inline($config, ., ("tei-biblStruct14"), ./monogr/author)
                )

            else
                ()
        )

    else
        (),
    if (@type='book' or @type='thesis' or @type='manuscript') then
        (
            fo:inline($config, ., ("tei-biblStruct15"), ./monogr/author),
            fo:inline($config, ., ("tei-biblStruct16", "monogr-title"), ./monogr/title[not(@type='short')]),
            fo:text($config, ., ("tei-biblStruct17"), '. ')
        )

    else
        (),
    if (./monogr/editor) then
        (
            fo:text($config, ., ("tei-biblStruct18"), 'edited by '),
            fo:inline($config, ., ("tei-biblStruct19"), ./monogr/editor)
        )

    else
        (),
    fo:inline($config, ., ("tei-biblStruct20"), ./series),
    if (monogr/biblScope[@unit='vol']) then
        fo:inline($config, ., ("tei-biblStruct21"), ./monogr/biblScope[@unit='vol'])
    else
        (),
    if (monogr/imprint/date) then
        fo:inline($config, ., ("tei-biblStruct22"), ./monogr/imprint)
    else
        (),
    if (monogr/biblScope[@unit='pp']) then
        (
            fo:text($config, ., ("tei-biblStruct23"), ': '),
            fo:inline($config, ., ("tei-biblStruct24"), monogr/biblScope[@unit='pp'])
        )

    else
        (),
    fo:inline($config, ., ("tei-biblStruct25"), ./monogr/edition),
    fo:inline($config, ., ("tei-biblStruct26"), .//note),
    if (not(./relatedItem/note)) then
        fo:text($config, ., ("tei-biblStruct27"), '.')
    else
        ()
)
)
                case element(dimensions) return
                    if (ancestor::supportDesc or ancestor::layoutDesc) then
                        (
                            fo:inline($config, ., ("tei-dimensions1"), .),
                            if (@unit) then
                                fo:inline($config, ., ("tei-dimensions2"), @unit)
                            else
                                ()
                        )

                    else
                        fo:inline($config, ., ("tei-dimensions3"), .)
                case element(edition) return
                    if (ancestor::biblStruct) then
                        (
                            fo:text($config, ., ("tei-edition1"), '. '),
                            fo:inline($config, ., ("tei-edition2"), .)
                        )

                    else
                        $config?apply($config, ./node())
                case element(forename) return
                    if (child::choice and ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-forename1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (choice/reg[@type='simplified']) then
            fo:inline($config, ., ("tei-forename2"), choice/reg[@type='simplified'])
        else
            (),
        fo:text($config, ., ("tei-forename3"), ' '),
        if (choice/reg[@type='simplified']) then
            fo:inline($config, ., ("tei-forename4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        fo:inline($config, ., ("tei-forename5"), .)
                case element(height) return
                    if (parent::dimensions and @precision='unknown') then
                        fo:omit($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            fo:inline($config, ., ("tei-height2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions and not(following-sibling::*)) then
                                fo:inline($config, ., ("tei-height3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                    fo:inline($config, ., ("tei-height4"), .)
                                else
                                    $config?apply($config, ./node())
                case element(width) return
                    if (parent::dimensions and count(following-sibling::*) >= 1) then
                        fo:inline($config, ., ("tei-width1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (parent::dimensions) then
                            fo:inline($config, ., ("tei-width2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                fo:inline($config, ., ("tei-width3"), .)
                            else
                                $config?apply($config, ./node())
                case element(depth) return
                    if (parent::dimensions and @precision='unknown') then
                        fo:omit($config, ., ("tei-depth1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            fo:inline($config, ., ("tei-depth2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions) then
                                fo:inline($config, ., ("tei-depth3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                fo:inline($config, ., ("tei-depth4"), .)
                case element(dim) return
                    if (@type='diameter' and (parent::dimensions and following-sibling::*)) then
                        fo:inline($config, ., ("tei-dim1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (@type='diameter' and (parent::dimensions and not(following-sibling::*))) then
                            fo:inline($config, ., ("tei-dim2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                fo:inline($config, ., ("tei-dim3"), .)
                            else
                                $config?apply($config, ./node())
                case element(handDesc) return
                    fo:inline($config, ., ("tei-handDesc"), .)
                case element(handNote) return
                    fo:inline($config, ., ("tei-handNote"), let $finale := if (ends-with(normalize-space(.),'.')) then () else if (*[text()[normalize-space(.)]]) then '.* ' else () return (.,$finale))
                case element(idno) return
                    if ($parameters?header='short') then
                        fo:inline($config, ., ("tei-idno1"), .)
                    else
                        if (ancestor::publicationStmt) then
                            fo:inline($config, ., ("tei-idno2"), .)
                        else
                            fo:inline($config, ., ("tei-idno3"), .)
                case element(imprint) return
                    if (ancestor::biblStruct) then
                        (
                            fo:inline($config, ., ("tei-imprint1"), pubPlace),
                            fo:inline($config, ., ("tei-imprint2"), publisher),
                            if (following-sibling::date) then
                                fo:text($config, ., ("tei-imprint3"), ', ')
                            else
                                (),
                            fo:inline($config, ., ("tei-imprint4"), date),
                            if (biblScope[@unit='page']) then
                                fo:text($config, ., ("tei-imprint5"), ': ')
                            else
                                (),
                            fo:inline($config, ., ("tei-imprint6"), biblScope[@unit='page'])
                        )

                    else
                        $config?apply($config, ./node())
                case element(layout) return
                    fo:inline($config, ., ("tei-layout"), .)
                (: There should be no dot before note if this element follows immediately after lem. This rule should be refined and limited to cases where lem had no source or rend. :)
                case element(lem) return
                    if (ancestor::listApp) then
                        (
                            fo:inline($config, ., ("tei-lem1"), .),
                            if (@rend and not(following-sibling::*[1][local-name()='rdg'])) then
                                fo:inline($config, ., ("tei-lem2", "bibl-rend"), if (ends-with(@rend,'.')) then substring-before(@rend,'.') else @rend)
                            else
                                (),
                            if (@rend and following-sibling::*[1][local-name()='rdg']) then
                                fo:inline($config, ., ("tei-lem3", "bibl-rend"), @rend)
                            else
                                (),
                            if (@source) then
                                (: No function found for behavior: bibl-initials-for-ref :)
                                $config?apply($config, ./node())
                            else
                                (),
                            if (starts-with(@resp,concat($config:project-code,'-part:'))) then
                                fo:inline($config, ., ("tei-lem5"), substring-after(@resp,concat($config:project-code,'-part:')))
                            else
                                (),
                            if (starts-with(@resp,'#')) then
                                fo:link($config, ., ("tei-lem6"), substring-after(@resp,'#'),  '?odd=' || request:get-parameter('odd', ()) || '&amp;view=' || request:get-parameter('view', ()) || '&amp;id='|| @resp)
                            else
                                (),
                            if (not(following-sibling::*[1][local-name() = ('rdg', 'note')]) or (@source or @rend)) then
                                fo:inline($config, ., ("tei-lem7", "period"), '.')
                            else
                                ()
                        )

                    else
                        fo:inline($config, ., ("tei-lem8"), .)
                case element(licence) return
                    fo:omit($config, ., ("tei-licence"), .)
                case element(listApp) return
                    if (parent::div[@type='commentary']) then
                        (: No function found for behavior: list-app :)
                        $config?apply($config, ./node())
                    else
                        (: More than one model without predicate found for ident listApp. Choosing first one. :)
                        (
                            if (parent::div[@type='apparatus'] and @corresp) then
                                fo:inline($config, ., ("tei-listApp1", "textpart-label"), let $id := substring-after(@corresp,'#') return preceding::div[@type='edition']//div[@type='textpart'][@xml:id=$id]/@n)
                            else
                                (),
                            if (parent::div[@type='apparatus']) then
                                (: No function found for behavior: list-app :)
                                $config?apply($config, ./node())
                            else
                                ()
                        )

                case element(notesStmt) return
                    fo:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    fo:inline($config, ., ("tei-objectDesc"), .)
                case element(persName) return
                    if (ancestor::div[@type]) then
                        fo:link($config, ., ("tei-persName1"), ., ())
                    else
                        if (ancestor::person and @type) then
                            fo:inline($config, ., ("tei-persName2"), .)
                        else
                            if (ancestor::person) then
                                fo:inline($config, ., ("tei-persName3"), .)
                            else
                                $config?apply($config, ./node())
                case element(physDesc) return
                    fo:inline($config, ., ("tei-physDesc"), .)
                case element(provenance) return
                    if (parent::history) then
                        fo:inline($config, ., ("tei-provenance"), .)
                    else
                        $config?apply($config, ./node())
                case element(ptr) return
                    if (parent::bibl and @target) then
                        (: No function found for behavior: make-bibl-link :)
                        $config?apply($config, ./node())
                    else
                        if (not(parent::bibl) and not(text()) and @target[starts-with(.,'#')]) then
                            (: No function found for behavior: resolve-pointer :)
                            $config?apply($config, ./node())
                        else
                            if (not(text())) then
                                fo:link($config, ., ("tei-ptr3"), @target, ())
                            else
                                $config?apply($config, ./node())
                case element(rdg) return
                    if (ancestor::listApp) then
                        (
                            fo:inline($config, ., ("tei-rdg1"), .),
                            if (@source and ancestor::listApp) then
                                (: No function found for behavior: refbibl :)
                                $config?apply($config, ./node())
                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(respStmt) return
                    fo:inline($config, ., ("tei-respStmt"), concat(normalize-space(.),'. '))
                case element(series) return
                    if (ancestor::biblStruct) then
                        (
                            fo:inline($config, ., ("tei-series1"), title),
                            if (biblScope) then
                                fo:text($config, ., ("tei-series2"), ', ')
                            else
                                (),
                            fo:inline($config, ., ("tei-series3"), biblScope),
                            fo:text($config, ., ("tei-series4"), ', ')
                        )

                    else
                        $config?apply($config, ./node())
                case element(space) return
                    if (@type='horizontal' and child::certainty[@locus='name']) then
                        fo:inline($config, ., ("tei-space1"), '◊ [...] ')
                    else
                        if ((@unit='character' or @unit='chars') and child::certainty[@locus='name']) then
                            fo:inline($config, ., ("tei-space2"), '[◊]')
                        else
                            if (@type='horizontal') then
                                fo:inline($config, ., ("tei-space3"), '◊')
                            else
                                if (@type='binding-hole') then
                                    fo:inline($config, ., ("tei-space4"), '◯')
                                else
                                    if (@type='defect') then
                                        fo:inline($config, ., ("tei-space5"), '□')
                                    else
                                        $config?apply($config, ./node())
                case element(supportDesc) return
                    fo:inline($config, ., ("tei-supportDesc"), .)
                case element(surname) return
                    if (child::choice and ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-surname1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (choice/reg[@type='simplified']) then
            fo:inline($config, ., ("tei-surname2"), choice/reg[@type='simplified'])
        else
            (),
        fo:text($config, ., ("tei-surname3"), ' '),
        if (choice/reg[@type='simplified']) then
            fo:inline($config, ., ("tei-surname4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        fo:inline($config, ., ("tei-surname5"), .)
                case element(surrogates) return
                    fo:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    fo:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    fo:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' return concat(normalize-space(.),$finale))
                case element(titleStmt) return
                    (: No function found for behavior: headerType :)
                    $config?apply($config, ./node())
                case element(facsimile) return
                    if ($parameters?modal='true') then
                        (: No function found for behavior: image-modals :)
                        $config?apply($config, ./node())
                    else
                        (: No function found for behavior: section-collapsible :)
                        $config?apply($config, ./node())
                case element(geo) return
                    fo:block($config, ., ("tei-geo"), .)
                case element(listPlace) return
                    if (@type='subsidiary') then
                        (: No function found for behavior: section-collapsible :)
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, ./node())
                case element(person) return
                    if (ancestor::listPerson) then
                        (
                            (: No function found for behavior: dl :)
                            $config?apply($config, ./node()),
                            if (state or trait or residence or occupation) then
                                (
                                    (: No function found for behavior: dl :)
                                    $config?apply($config, ./node())
                                )

                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(place) return
                    if (ancestor::listPlace and not(ancestor::listPlace/ancestor::listPlace)) then
                        (
                            (: No function found for behavior: dl :)
                            $config?apply($config, ./node())
                        )

                    else
                        if (ancestor::listPlace) then
                            (
                                fo:heading($config, ., ("tei-place8"), placeName),
                                fo:block($config, ., ("tei-place9"), desc)
                            )

                        else
                            $config?apply($config, ./node())
                case element(placeName) return
                    if (ancestor::div[@type] or ancestor::origPlace) then
                        fo:link($config, ., ("tei-placeName1"), ., ())
                    else
                        if (@xml:lang and @type='modern' and following-sibling::*[1][local-name()='placeName'][@type='modern']) then
                            (: No function found for behavior: name-with-language :)
                            $config?apply($config, ./node())
                        else
                            if (@xml:lang and @type='modern') then
                                (: No function found for behavior: name-with-language :)
                                $config?apply($config, ./node())
                            else
                                if (@xml:lang and @type='ancient' and following-sibling::*[1][local-name()='placeName'][@type='ancient']) then
                                    (: No function found for behavior: name-with-language :)
                                    $config?apply($config, ./node())
                                else
                                    if (@xml:lang and @type='ancient') then
                                        (: No function found for behavior: name-with-language :)
                                        $config?apply($config, ./node())
                                    else
                                        $config?apply($config, ./node())
                case element() return
                    if (namespace-uri(.) = 'http://www.tei-c.org/ns/1.0') then
                        $config?apply($config, ./node())
                    else
                        .
                case text() | xs:anyAtomicType return
                    fo:escapeChars(.)
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
                fo:escapeChars(.)
    )
};

