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
                                                fo:block($config, ., ("tei-ab7", "well"), .)
                                            else
                                                fo:block($config, ., ("tei-ab8"), .)
                case element(abbr) return
                    fo:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    fo:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    if (@place='below') then
                        fo:inline($config, ., ("tei-add"), .)
                    else
                        $config?apply($config, ./node())
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
                    if (ancestor::teiHeader) then
                        fo:block($config, ., ("tei-author1"), .)
                    else
                        if (ancestor::biblStruct) then
                            fo:inline($config, ., ("tei-author2"), if (surname or forename) then
    (
        fo:inline($config, ., ("tei-author3"), surname),
        if (surname and forename) then
            fo:text($config, ., ("tei-author4"), ', ')
        else
            (),
        fo:inline($config, ., ("tei-author5"), forename),
        if (following-sibling::* or position()=last()) then
            fo:text($config, ., ("tei-author6"), ', ')
        else
            ()
    )

else
    if (name) then
        (
            if (addName) then
                (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                fo:inline($config, ., ("tei-author7"), normalize-space(concat(name,' (',addName,')')))
            else
                (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                fo:inline($config, ., ("tei-author8"), name),
            if (following-sibling::*[2][local-name()='imprint']) then
                fo:inline($config, ., ("tei-author9"), ' +and+ ')
            else
                if (following-sibling::* or position()=last()) then
                    fo:text($config, ., ("tei-author10"), ', ')
                else
                    $config?apply($config, ./node())
        )

    else
        $config?apply($config, ./node()))
                        else
                            $config?apply($config, ./node())
                case element(back) return
                    fo:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl[@ana='#photo']) then
                        (: No function found for behavior: listItemImage :)
                        $config?apply($config, ./node())
                    else
                        if (parent::listBibl[@ana='#photo-estampage']) then
                            (: No function found for behavior: listItemImage :)
                            $config?apply($config, ./node())
                        else
                            if (parent::listBibl[@ana='#rti']) then
                                (: No function found for behavior: listItemImage :)
                                $config?apply($config, ./node())
                            else
                                if (parent::listBibl and ancestor::div[@type='bibliography']) then
                                    (: No function found for behavior: listItemImage :)
                                    $config?apply($config, ./node())
                                else
                                    if (parent::cit) then
                                        fo:inline($config, ., ("tei-bibl5"), .)
                                    else
                                        if (parent::listBibl) then
                                            fo:listItem($config, ., ("tei-bibl6"), .)
                                        else
                                            (: More than one model without predicate found for ident bibl. Choosing first one. :)
                                            fo:inline($config, ., ("tei-bibl7", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct and @unit='series') then
                        (
                            fo:inline($config, ., ("tei-biblScope1"), .),
                            if (following-sibling::*) then
                                fo:text($config, ., ("tei-biblScope2"), ', ')
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct and @unit='volume') then
                            (
                                if (preceding-sibling::*) then
                                    fo:text($config, ., ("tei-biblScope3"), ', ')
                                else
                                    (),
                                if (ancestor::biblStruct and not(following-sibling::biblScope[1][@unit='issue'])) then
                                    fo:inline($config, ., ("tei-biblScope4"), .)
                                else
                                    (),
                                if (ancestor::biblStruct and following-sibling::biblScope[1][@unit='issue']) then
                                    fo:inline($config, ., ("tei-biblScope5"), .)
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct and @unit='issue') then
                                (
                                    fo:inline($config, ., ("tei-biblScope6"), .),
                                    if (following-sibling::*) then
                                        fo:text($config, ., ("tei-biblScope7"), ', ')
                                    else
                                        ()
                                )

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
                        fo:alternate($config, ., ("tei-choice4"), ., corr[1], sic[1])
                    else
                        if (abbr and expan) then
                            fo:alternate($config, ., ("tei-choice5"), ., expan[1], abbr[1])
                        else
                            if (orig and reg) then
                                fo:alternate($config, ., ("tei-choice6"), ., reg[1], orig[1])
                            else
                                $config?apply($config, ./node())
                case element(cit) return
                    if (ancestor::teiHeader) then
                        (: No function found for behavior: :)
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, ./node())
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
                    if (text()) then
                        fo:inline($config, ., ("tei-date1"), .)
                    else
                        if (@when and not(text())) then
                            fo:inline($config, ., ("tei-date2"), @when)
                        else
                            if (@type='published') then
                                fo:text($config, ., ("tei-date3"), concat(' (published ',.,')'))
                            else
                                if (text()) then
                                    fo:inline($config, ., ("tei-date5"), .)
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
                        if (@type='textpart') then
                            fo:block($config, ., ("tei-div4", "textpart"), .)
                        else
                            if (@type='bibliography') then
                                (
                                    if (listBibl) then
                                        fo:heading($config, ., ("tei-div5"), 'Secondary bibliography')
                                    else
                                        (),
                                    fo:section($config, ., ("tei-div6", "bibliography-secondary"), listBibl)
                                )

                            else
                                if (@type='translation' and *[text()[normalize-space(.)]]) then
                                    (
                                        fo:heading($config, ., ("tei-div7"),  let $plural := if (count(ab) > 1) then 's' else () return concat(upper-case(substring(@type,1,1)),substring(@type,2),$plural) ),
                                        fo:section($config, ., ("tei-div8", "translation"), .)
                                    )

                                else
                                    if (@type='edition') then
                                        fo:section($config, ., ("tei-div9", (@type)), if (div[@type='textpart']) then
    fo:block($config, ., ("tei-div10", (@type)), .)
else
    fo:block($config, ., ("tei-div11", "diveditionnormal"), .))
                                    else
                                        if (@type='apparatus') then
                                            (
                                                (: No function found for behavior: separator :)
                                                $config?apply($config, ./node()),
                                                fo:section($config, ., ("tei-div13", (@type)), .)
                                            )

                                        else
                                            if (@type='commentary' and not(p ='' or listApp/* ='')) then
                                                (
                                                    fo:heading($config, ., ("tei-div14", (@type)), concat(upper-case(substring(@type,1,1)),substring(@type,2))),
                                                    fo:section($config, ., ("tei-div15", (@type)), .)
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
                    if (ancestor::titleStmt and @role='general' and (count(following-sibling::editor[@role='general']) = 1)) then
                        fo:inline($config, ., ("tei-editor1"), persName)
                    else
                        if (ancestor::titleStmt and @role='contributor' and (count(following-sibling::editor[@role='contributor']) = 1)) then
                            fo:inline($config, ., ("tei-editor2"), persName)
                        else
                            if (ancestor::titleStmt and @role='general' and following-sibling::editor[@role='general']) then
                                fo:inline($config, ., ("tei-editor3"), persName)
                            else
                                if (ancestor::titleStmt and @role='contributor' and following-sibling::editor[@role='contributor']) then
                                    fo:inline($config, ., ("tei-editor4"), persName)
                                else
                                    if (surname or forename) then
                                        (
                                            fo:inline($config, ., ("tei-editor5"), surname),
                                            if (surname and forename) then
                                                fo:text($config, ., ("tei-editor6"), ', ')
                                            else
                                                (),
                                            fo:inline($config, ., ("tei-editor7"), forename),
                                            if (count(parent::*/editor) = 1) then
                                                fo:text($config, ., ("tei-editor8"), ', ed. ')
                                            else
                                                (),
                                            if (count(parent::*/editor) > 1) then
                                                fo:text($config, ., ("tei-editor9"), ', and ')
                                            else
                                                ()
                                        )

                                    else
                                        if (name) then
                                            (
                                                if (addName) then
                                                    (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                                                    fo:inline($config, ., ("tei-editor10"), normalize-space(concat(name,' (',addName,')')))
                                                else
                                                    (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                                                    fo:inline($config, ., ("tei-editor11"), name),
                                                if (count(parent::*/editor) = 1) then
                                                    fo:text($config, ., ("tei-editor12"), ', ed., ')
                                                else
                                                    if (following-sibling::*[2][local-name()='imprint']) then
                                                        fo:inline($config, ., ("tei-editor13"), ' =and= ')
                                                    else
                                                        if (following-sibling::* or position()=last()) then
                                                            fo:text($config, ., ("tei-editor14"), ', eds., ')
                                                        else
                                                            $config?apply($config, ./node())
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
                    fo:inline($config, ., ("tei-figDesc"), .)
                case element(figure) return
                    if (head or @rendition='simple:display') then
                        fo:block($config, ., ("tei-figure1"), .)
                    else
                        fo:inline($config, ., ("tei-figure2"), .)
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
                    fo:block($config, ., ("tei-fw"), .)
                case element(g) return
                    if (@type) then
                        fo:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if (@reason='lost' and @unit='line' and @quantity=1) then
                        fo:text($config, ., ("tei-gap1"), '.')
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
                                                                    fo:inline($config, ., ("tei-gap12"), '+')
                                                                else
                                                                    if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='illegible') then
                                                                        fo:inline($config, ., ("tei-gap13"), '?')
                                                                    else
                                                                        if ((@reason='lost' or @reason='illegible') and @extent='unknown') then
                                                                            fo:inline($config, ., ("tei-gap14"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||
							@reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                        else
                                                                            if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::*[1][local-name()='lb']) then
                                                                                fo:inline($config, ., ("tei-gap15", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||
							@reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                            else
                                                                                if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and preceding-sibling::*[1][local-name()='lb']) then
                                                                                    fo:inline($config, ., ("tei-gap16", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||
							')' || ' ' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || ' ' || $sep )
                                                                                else
                                                                                    if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::text()[1]) then
                                                                                        fo:inline($config, ., ("tei-gap17", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||
							')' else (string-join((for $i in 1 to xs:integer($quantity) return ' ' || $charToRepeat),' ')) || $sep)
                                                                                    else
                                                                                        $config?apply($config, ./node())
                case element(graphic) return
                    fo:graphic($config, ., ("tei-graphic"), ., @url, (), (), (), ())
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
                    if (@rendition) then
                        fo:inline($config, ., css:get-rendition(., ("tei-hi1")), .)
                    else
                        if (not(@rendition)) then
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
                        fo:list($config, ., ("tei-listBibl1", "list-group"), biblStruct)
                    else
                        if (ancestor::surrogates or ancestor::div[@type='bibliography']) then
                            fo:list($config, ., ("tei-listBibl2"), .)
                        else
                            if (bibl) then
                                fo:list($config, ., ("tei-listBibl3"), bibl)
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
                    if (child::choice) then
                        fo:inline($config, ., ("tei-name1"), (
    if (choice/reg[@type='simplified']) then
        fo:inline($config, ., ("tei-name2"), choice/reg[@type='simplified'])
    else
        (),
    fo:text($config, ., ("tei-name3"), ' '),
    if (choice/reg[@type='simplified']) then
        fo:inline($config, ., ("tei-name4"), choice/reg[@type='popular'])
    else
        ()
)
)
                    else
                        fo:inline($config, ., ("tei-name5"), .)
                case element(note) return
                    if (parent::notesStmt and child::text()[normalize-space(.)]) then
                        fo:listItem($config, ., ("tei-note1"), .)
                    else
                        if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                            (
                                fo:inline($config, ., ("tei-note2", (ancestor::div/@type || '-note')), .)
                            )

                        else
                            if (not(ancestor::biblStruct) and parent::bibl) then
                                fo:inline($config, ., ("tei-note3"), .)
                            else
                                if (@type='tags' and ancestor::biblStruct) then
                                    fo:omit($config, ., ("tei-note4"), .)
                                else
                                    if (@type='accessed' and ancestor::biblStruct) then
                                        fo:omit($config, ., ("tei-note5"), .)
                                    else
                                        if (@type='thesisType' and ancestor::biblStruct) then
                                            fo:omit($config, ., ("tei-note6"), .)
                                        else
                                            if (not(@type='url') and ancestor::biblStruct) then
                                                fo:omit($config, ., ("tei-note7"), .)
                                            else
                                                if (ancestor::biblStruct and @type='url') then
                                                    (
                                                        fo:text($config, ., ("tei-note8"), '. URL: <'),
                                                        fo:link($config, ., ("tei-note9"), ., .),
                                                        fo:text($config, ., ("tei-note10"), '>')
                                                    )

                                                else
                                                    if (ancestor::biblStruct and not(preceding-sibling::*[not(@type='tags')][ends-with(.,'.')])) then
                                                        fo:inline($config, ., ("tei-note11"), '. ')
                                                    else
                                                        if (ancestor::listApp) then
                                                            fo:inline($config, ., ("tei-note12"), .)
                                                        else
                                                            fo:inline($config, ., ("tei-note13"), .)
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
                                if (parent::div[@type='bibliography']) then
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
                                                if ($parameters?header='short') then
                                                    fo:omit($config, ., ("tei-p10"), .)
                                                else
                                                    fo:block($config, ., ("tei-p11"), .)
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
                    (: More than one model without predicate found for ident publisher. Choosing first one. :)
                    (
                        if (ancestor::biblStruct and preceding-sibling::pubPlace) then
                            fo:text($config, ., ("tei-publisher1"), ': ')
                        else
                            (),
                        if (ancestor::biblStruct) then
                            fo:inline($config, ., ("tei-publisher2"), normalize-space(.))
                        else
                            ()
                    )

                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-pubPlace"), .)
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
                        if (ancestor::p or ancestor::note) then
                            (: If it is inside a paragraph or a note then it is inline, otherwise it is block level :)
                            fo:inline($config, ., css:get-rendition(., ("tei-quote2")), .)
                        else
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            fo:block($config, ., css:get-rendition(., ("tei-quote3")), .)
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
                                if (starts-with(@target,'#EIAD')) then
                                    (: For corpus internal links (refs starts with '#'). To customize with corpus prefix (here 'EIAD') but needs declare namespace somewhere for config: :)
                                    fo:link($config, ., ("tei-ref4"), ., substring-after(@target,'#') || '.xml' || "?odd=" || request:get-parameter("odd", ()))
                                else
                                    if (not(@target)) then
                                        fo:inline($config, ., ("tei-ref5"), .)
                                    else
                                        fo:link($config, ., ("tei-ref6"), @target, @target)
                case element(reg) return
                    if (ancestor::biblStruct and @type='popular') then
                        fo:inline($config, ., ("tei-reg1"), .)
                    else
                        if (ancestor::biblStruct and @type='simplified') then
                            fo:inline($config, ., ("tei-reg2"), .)
                        else
                            $config?apply($config, ./node())
                case element(relatedItem) return
                    fo:inline($config, ., ("tei-relatedItem"), .)
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
                    fo:text($config, ., ("tei-supplied7"), .)
                case element(table) return
                    fo:table($config, ., ("tei-table"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            fo:inline($config, ., ("tei-fileDesc1", "header-short"), sourceDesc/msDesc/msIdentifier/idno),
                            fo:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        fo:title($config, ., ("tei-fileDesc35"), titleStmt)
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
                    fo:block($config, ., ("tei-biblStruct1"), (
    (
        fo:inline($config, ., ("tei-biblStruct2"), if (.//title[@type='short']) then
    (: No function found for behavior: bibl-link :)
    $config?apply($config, ./node())
else
    (
        if (.//author/surname) then
            fo:inline($config, ., ("tei-biblStruct4"), .//author/surname)
        else
            if (.//author/name) then
                fo:inline($config, ., ("tei-biblStruct5"), .//author/name)
            else
                $config?apply($config, ./node()),
        fo:text($config, ., ("tei-biblStruct6"), ' '),
        fo:inline($config, ., ("tei-biblStruct7"), monogr/imprint/date)
    )
)
    )
,
    (
        if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle') then
            (
                fo:inline($config, ., ("tei-biblStruct8"), analytic/author),
                if (analytic/title[@level='a']) then
                    (
                        fo:inline($config, ., ("tei-biblStruct9"), analytic/title[@level='a']),
                        fo:text($config, ., ("tei-biblStruct10"), ', ')
                    )

                else
                    if (not(analytic/title[@level='a']) and relatedItem[@type='reviewOf']) then
                        (
                            (: When it is a review of another bibliographic entry: so there's is no analytic/title[@level='a']. :)
                            fo:link($config, ., ("tei-biblStruct11"), relatedItem/ref, ()),
                            fo:text($config, ., ("tei-biblStruct12"), ', ')
                        )

                    else
                        $config?apply($config, ./node()),
                if (@type='bookSection' or @type='encyclopediaArticle') then
                    (
                        if (@type='bookSection' or @type='encyclopediaArticle') then
                            fo:text($config, ., ("tei-biblStruct13"), 'in ')
                        else
                            (),
                        fo:inline($config, ., ("tei-biblStruct14"), monogr/title[@level='m']),
                        fo:text($config, ., ("tei-biblStruct15"), ', '),
                        if (monogr/author) then
                            fo:text($config, ., ("tei-biblStruct16"), 'by ')
                        else
                            (),
                        fo:inline($config, ., ("tei-biblStruct17"), monogr/author),
                        if (monogr/editor) then
                            fo:inline($config, ., ("tei-biblStruct18"), monogr/editor)
                        else
                            ()
                    )

                else
                    (),
                if (@type='journalArticle') then
                    (
                        fo:inline($config, ., ("tei-biblStruct19"), monogr/title[@level='j']),
                        fo:text($config, ., ("tei-biblStruct20"), ', ')
                    )

                else
                    (),
                if (.//series) then
                    fo:inline($config, ., ("tei-biblStruct21"), series)
                else
                    (),
                if (.//monogr/imprint) then
                    fo:inline($config, ., ("tei-biblStruct22"), monogr/imprint)
                else
                    ()
            )

        else
            if (@type='book' or @type='manuscript' or @type='thesis' or @type='report') then
                (
                    fo:inline($config, ., ("tei-biblStruct23"), monogr/author),
                    fo:inline($config, ., ("tei-biblStruct24"), monogr/editor),
                    fo:inline($config, ., ("tei-biblStruct25"), monogr/respStmt),
                    if (@type='book' or @type='thesis' or @type='report') then
                        fo:inline($config, ., ("tei-biblStruct26"), monogr/title[@level='m'])
                    else
                        (),
                    if (@type='manuscript') then
                        fo:inline($config, ., ("tei-biblStruct27"), monogr/title[@level='u'])
                    else
                        (),
                    fo:text($config, ., ("tei-biblStruct28"), ', '),
                    if (.//series) then
                        fo:inline($config, ., ("tei-biblStruct29"), series)
                    else
                        (),
                    if (.//series/biblScope[@unit='volume']) then
                        fo:inline($config, ., ("tei-biblStruct30"), biblScope[@unit='volume'])
                    else
                        (),
                    if (monogr/imprint) then
                        (
                            if (@type='manuscript') then
                                fo:text($config, ., ("tei-biblStruct31"), ' manuscript ')
                            else
                                (),
                            if (@type='thesis') then
                                fo:text($config, ., ("tei-biblStruct32"), ' unpublished Ph.D., ')
                            else
                                (),
                            fo:inline($config, ., ("tei-biblStruct33"), monogr/imprint)
                        )

                    else
                        (),
                    if (note) then
                        (
                            fo:inline($config, ., ("tei-biblStruct34"), note)
                        )

                    else
                        ()
                )

            else
                if (@type='journal') then
                    (
                        fo:inline($config, ., ("tei-biblStruct35"), monogr/title[@level='j']),
                        fo:text($config, ., ("tei-biblStruct36"), ', '),
                        if (monogr/imprint) then
                            (
                                fo:inline($config, ., ("tei-biblStruct37"), monogr/imprint)
                            )

                        else
                            (),
                        if (note) then
                            (
                                fo:inline($config, ., ("tei-biblStruct38"), note)
                            )

                        else
                            ()
                    )

                else
                    if (@type='webpage') then
                        (
                            fo:inline($config, ., ("tei-biblStruct39"), monogr/author),
                            fo:inline($config, ., ("tei-biblStruct40"), monogr/title[not(@type='short')]),
                            fo:text($config, ., ("tei-biblStruct41"), ', '),
                            if (monogr/idno[@type='url'] or note[@type='url']) then
                                (
                                    fo:text($config, ., ("tei-biblStruct42"), 'retrieved on '),
                                    fo:inline($config, ., ("tei-biblStruct43"), monogr/note[@type='accessed']/date),
                                    fo:text($config, ., ("tei-biblStruct44"), ' from <'),
                                    if (monogr/idno[@type='url']) then
                                        fo:inline($config, ., ("tei-biblStruct45"), */idno)
                                    else
                                        if (note[@type='url']) then
                                            fo:inline($config, ., ("tei-biblStruct46"), note[@type='url'])
                                        else
                                            $config?apply($config, ./node()),
                                    fo:text($config, ., ("tei-biblStruct47"), '>')
                                )

                            else
                                (),
                            if (note) then
                                (
                                    if (note) then
                                        fo:inline($config, ., ("tei-biblStruct48"), note)
                                    else
                                        ()
                                )

                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
    )
,
    if (not(@type='webpage')) then
        (
            if (*/idno[@type='url']) then
                fo:inline($config, ., ("tei-biblStruct49"), */idno[@type='url'])
            else
                ()
        )

    else
        (),
    if (.//*[position()=last()][not(local-name()='note')][not(ends-with(normalize-space(text()),'.'))]) then
        fo:text($config, ., ("tei-biblStruct50"), '.')
    else
        (),
    if (.//note[position()=last()][@type='thesisType' or @type='url' or @type='tags']) then
        fo:text($config, ., ("tei-biblStruct51"), '.')
    else
        ()
)
)
                case element(dimensions) return
                    if (ancestor::support) then
                        (
                            fo:inline($config, ., ("tei-dimensions1"), .),
                            if (@unit) then
                                fo:inline($config, ., ("tei-dimensions2"), @unit)
                            else
                                ()
                        )

                    else
                        if (ancestor::layoutDesc) then
                            (
                                if (not(preceding-sibling::dimensions)) then
                                    fo:text($config, ., ("tei-dimensions3"), ' Inscribed area: ')
                                else
                                    (),
                                fo:inline($config, ., ("tei-dimensions4"), .),
                                if (following-sibling::dimensions) then
                                    fo:text($config, ., ("tei-dimensions5"), ';')
                                else
                                    (),
                                if (@unit) then
                                    fo:inline($config, ., ("tei-dimensions6"), @unit)
                                else
                                    (),
                                if (@extent) then
                                    fo:inline($config, ., ("tei-dimensions7"), @extent)
                                else
                                    ()
                            )

                        else
                            fo:inline($config, ., ("tei-dimensions8"), .)
                case element(height) return
                    if (parent::dimensions and @precision='unknown') then
                        fo:omit($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            fo:inline($config, ., ("tei-height2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions and following-sibling::*) then
                                fo:inline($config, ., ("tei-height3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                if (parent::dimensions and not(following-sibling::*)) then
                                    fo:inline($config, ., ("tei-height4"), if (@extent) then concat('(',@extent,') ',.) else .)
                                else
                                    if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                        fo:inline($config, ., ("tei-height5"), .)
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
                    fo:inline($config, ., ("tei-handNote"), .)
                case element(idno) return
                    if (ancestor::biblStruct[@type='webpage'] and @type='url') then
                        fo:link($config, ., ("tei-idno1"), ., ())
                    else
                        if (ancestor::biblStruct and @type='url') then
                            (
                                fo:text($config, ., ("tei-idno2"), '. URL: <'),
                                fo:link($config, ., ("tei-idno3"), ., ()),
                                fo:text($config, ., ("tei-idno4"), '>')
                            )

                        else
                            if ($parameters?header='short') then
                                fo:inline($config, ., ("tei-idno5"), .)
                            else
                                if (ancestor::publicationStmt) then
                                    fo:inline($config, ., ("tei-idno6"), .)
                                else
                                    fo:inline($config, ., ("tei-idno7"), .)
                case element(imprint) return
                    if (ancestor::biblStruct[@type='book' or @type='journal' or @type='manuscript' or @type='report' or @type='thesis']) then
                        (
                            if (pubPlace) then
                                fo:inline($config, ., ("tei-imprint1"), pubPlace)
                            else
                                (),
                            if (publisher) then
                                fo:inline($config, ., ("tei-imprint2"), publisher)
                            else
                                (),
                            if (date and (pubPlace or publisher)) then
                                fo:text($config, ., ("tei-imprint3"), ', ')
                            else
                                (),
                            if (date) then
                                fo:inline($config, ., ("tei-imprint4"), date)
                            else
                                (),
                            if (note) then
                                fo:inline($config, ., ("tei-imprint5"), note)
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct[@type='journalArticle']) then
                            (
                                if (biblScope[@unit='volume']) then
                                    fo:inline($config, ., ("tei-imprint6"), biblScope[@unit='volume'])
                                else
                                    (),
                                if (following-sibling::*[1][@unit='issue']) then
                                    fo:text($config, ., ("tei-imprint7"), ', ')
                                else
                                    (),
                                if (biblScope[@unit='issue']) then
                                    fo:inline($config, ., ("tei-imprint8"), biblScope[@unit='issue'])
                                else
                                    (),
                                if (date) then
                                    fo:inline($config, ., ("tei-imprint9"), date)
                                else
                                    (),
                                if (biblScope[@unit='page']) then
                                    fo:inline($config, ., ("tei-imprint10"), biblScope[@unit='page'])
                                else
                                    (),
                                if (note) then
                                    fo:inline($config, ., ("tei-imprint11"), note)
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct[@type='encyclopediaArticle'] or ancestor::biblStruct[@type='bookSection']) then
                                (
                                    if (biblScope[@unit='volume']) then
                                        fo:inline($config, ., ("tei-imprint12"), biblScope[@unit='volume'])
                                    else
                                        (),
                                    if (pubPlace) then
                                        fo:inline($config, ., ("tei-imprint13"), pubPlace)
                                    else
                                        (),
                                    if (publisher) then
                                        fo:inline($config, ., ("tei-imprint14"), publisher)
                                    else
                                        (),
                                    if (date) then
                                        fo:text($config, ., ("tei-imprint15"), ', ')
                                    else
                                        (),
                                    if (date) then
                                        fo:inline($config, ., ("tei-imprint16"), date)
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        fo:inline($config, ., ("tei-imprint17"), biblScope[@unit='page'])
                                    else
                                        (),
                                    if (note) then
                                        fo:inline($config, ., ("tei-imprint18"), note)
                                    else
                                        ()
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
                            if (starts-with(@resp,'eiad-part:')) then
                                fo:inline($config, ., ("tei-lem5"), substring-after(@resp,'eiad-part:'))
                            else
                                (),
                            if (starts-with(@resp,'#')) then
                                fo:link($config, ., ("tei-lem6"), substring-after(@resp,'#'),  "?odd=" || request:get-parameter("odd", ()) || "&amp;view=" || request:get-parameter("view", ()) || "&amp;id=" || @resp )
                            else
                                (),
                            if (not(following-sibling::*[1][local-name()='rdg']) and (@source or @rend)) then
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
                            if (parent::div[@type='apparatus']) then
                                (: No function found for behavior: list-app :)
                                $config?apply($config, ./node())
                            else
                                ()
                        )

                case element(msDesc) return
                    fo:inline($config, ., ("tei-msDesc"), .)
                case element(notesStmt) return
                    fo:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    fo:inline($config, ., ("tei-objectDesc"), .)
                case element(orgName) return
                    fo:inline($config, ., ("tei-orgName"), .)
                case element(persName) return
                    if (ancestor::div[@type]) then
                        (: No function found for behavior: link2 :)
                        $config?apply($config, ./node())
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
                        (: No function found for behavior: refbibl :)
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
                    if (ancestor::titleStmt and count(child::resp[@type='editor'] >= 1)) then
                        fo:inline($config, ., ("tei-respStmt1"), persName)
                    else
                        fo:inline($config, ., ("tei-respStmt2"), .)
                case element(series) return
                    if (ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-series1"), (
    fo:inline($config, ., ("tei-series2"), title[@level='s']),
    fo:inline($config, ., ("tei-series3"), biblScope)
)
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
                                    $config?apply($config, ./node())
                case element(supportDesc) return
                    fo:inline($config, ., ("tei-supportDesc"), .)
                case element(surrogates) return
                    fo:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    fo:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    fo:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' return concat(normalize-space(.),$finale) )
                case element(titleStmt) return
                    (: No function found for behavior: headerType :)
                    $config?apply($config, ./node())
                case element(facsimile) return
                    if ($parameters?modal='true') then
                        (: No function found for behavior: image-modals :)
                        $config?apply($config, ./node())
                    else
                        (
                            fo:heading($config, ., ("tei-facsimile2"), 'Facsimiles '),
                            (: No function found for behavior: images :)
                            $config?apply($config, ./node())
                        )

                case element(person) return
                    (
                        (: No function found for behavior: dt :)
                        $config?apply($config, ./node()),
                        (: No function found for behavior: dd :)
                        $config?apply($config, ./node()),
                        (: No function found for behavior: dt :)
                        $config?apply($config, ./node())
                    )

                case element(placeName) return
                    if (ancestor::div[@type]) then
                        (: No function found for behavior: link2 :)
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

