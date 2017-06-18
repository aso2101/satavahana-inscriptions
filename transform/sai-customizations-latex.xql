(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/SAI/resources/odd/sai-customizations.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/sai-customizations/latex";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace xi='http://www.w3.org/2001/XInclude';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace latex="http://www.tei-c.org/tei-simple/xquery/functions/latex";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["latex","print"],
                "odd": "/db/apps/SAI/resources/odd/sai-customizations.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))
    let $config := latex:init($config, $input)
    
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
                    latex:body($config, ., ("tei-text"), .)
                case element(ab) return
                    if (ancestor::div[@type='edition'] and $parameters?break='XML') then
                        (: No function found for behavior: xml :)
                        $config?apply($config, ./node())
                    else
                        if (ancestor::div[@type='edition'] and @xml:lang) then
                            latex:inline($config, ., ("tei-ab2"), .)
                        else
                            if (ancestor::div[@type='edition'] and (preceding-sibling::*[1][local-name()='lg'] or following-sibling::*[1][local-name()='lg']) and $parameters?break='Physical') then
                                latex:inline($config, ., ("tei-ab3"), .)
                            else
                                if (ancestor::div[@type='edition'] and (preceding-sibling::*[1][local-name()='lg'] or following-sibling::*[1][local-name()='lg']) and $parameters?break='Logical') then
                                    latex:block($config, ., ("tei-ab4", "prose-block"), .)
                                else
                                    if (ancestor::div[@type='edition']) then
                                        latex:block($config, ., ("tei-ab5"), .)
                                    else
                                        if (ancestor::div[@type='textpart']) then
                                            latex:block($config, ., ("tei-ab6"), .)
                                        else
                                            if (ancestor::div[@type='translation']) then
                                                latex:block($config, ., ("tei-ab7", "well"), .)
                                            else
                                                latex:block($config, ., ("tei-ab8"), .)
                case element(abbr) return
                    latex:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    latex:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    if (@place='below') then
                        latex:inline($config, ., ("tei-add"), .)
                    else
                        $config?apply($config, ./node())
                case element(address) return
                    latex:block($config, ., ("tei-address"), .)
                case element(addrLine) return
                    latex:block($config, ., ("tei-addrLine"), .)
                case element(am) return
                    latex:inline($config, ., ("tei-am"), .)
                case element(anchor) return
                    latex:anchor($config, ., ("tei-anchor"), ., @xml:id)
                case element(argument) return
                    latex:block($config, ., ("tei-argument"), .)
                case element(author) return
                    if (ancestor::teiHeader) then
                        latex:block($config, ., ("tei-author1"), .)
                    else
                        if (ancestor::biblStruct) then
                            latex:inline($config, ., ("tei-author2"), if (surname or forename) then
    (
        latex:inline($config, ., ("tei-author3"), surname),
        if (surname and forename) then
            latex:text($config, ., ("tei-author4"), ', ')
        else
            (),
        latex:inline($config, ., ("tei-author5"), forename),
        if (following-sibling::* or position()=last()) then
            latex:text($config, ., ("tei-author6"), ', ')
        else
            ()
    )

else
    if (name) then
        (
            if (addName) then
                (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                latex:inline($config, ., ("tei-author7"), normalize-space(concat(name,' (',addName,')')))
            else
                (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                latex:inline($config, ., ("tei-author8"), name),
            if (following-sibling::*[2][local-name()='imprint']) then
                latex:inline($config, ., ("tei-author9"), ' +and+ ')
            else
                if (following-sibling::* or position()=last()) then
                    latex:text($config, ., ("tei-author10"), ', ')
                else
                    $config?apply($config, ./node())
        )

    else
        $config?apply($config, ./node()))
                        else
                            $config?apply($config, ./node())
                case element(back) return
                    latex:block($config, ., ("tei-back"), .)
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
                                        latex:inline($config, ., ("tei-bibl5"), .)
                                    else
                                        if (parent::listBibl) then
                                            latex:listItem($config, ., ("tei-bibl6"), .)
                                        else
                                            (: More than one model without predicate found for ident bibl. Choosing first one. :)
                                            latex:inline($config, ., ("tei-bibl7", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct and @unit='series') then
                        (
                            latex:inline($config, ., ("tei-biblScope1"), .),
                            if (following-sibling::*) then
                                latex:text($config, ., ("tei-biblScope2"), ', ')
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct and @unit='volume') then
                            (
                                if (preceding-sibling::*) then
                                    latex:text($config, ., ("tei-biblScope3"), ', ')
                                else
                                    (),
                                if (ancestor::biblStruct and not(following-sibling::biblScope[1][@unit='issue'])) then
                                    latex:inline($config, ., ("tei-biblScope4"), .)
                                else
                                    (),
                                if (ancestor::biblStruct and following-sibling::biblScope[1][@unit='issue']) then
                                    latex:inline($config, ., ("tei-biblScope5"), .)
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct and @unit='issue') then
                                (
                                    latex:inline($config, ., ("tei-biblScope6"), .),
                                    if (following-sibling::*) then
                                        latex:text($config, ., ("tei-biblScope7"), ', ')
                                    else
                                        ()
                                )

                            else
                                $config?apply($config, ./node())
                case element(body) return
                    (
                        latex:index($config, ., ("tei-body1"), ., 'toc'),
                        latex:block($config, ., ("tei-body2"), .)
                    )

                case element(byline) return
                    latex:block($config, ., ("tei-byline"), .)
                case element(c) return
                    latex:inline($config, ., ("tei-c"), .)
                case element(castGroup) return
                    if (child::*) then
                        (: Insert list. :)
                        latex:list($config, ., ("tei-castGroup"), castItem|castGroup)
                    else
                        $config?apply($config, ./node())
                case element(castItem) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    latex:listItem($config, ., ("tei-castItem"), .)
                case element(castList) return
                    if (child::*) then
                        latex:list($config, ., css:get-rendition(., ("tei-castList")), castItem)
                    else
                        $config?apply($config, ./node())
                case element(cb) return
                    latex:break($config, ., ("tei-cb"), ., 'column', @n)
                case element(cell) return
                    (: Insert table cell. :)
                    latex:cell($config, ., ("tei-cell"), ., ())
                case element(choice) return
                    if (sic and corr) then
                        latex:alternate($config, ., ("tei-choice4"), ., corr[1], sic[1])
                    else
                        if (abbr and expan) then
                            latex:alternate($config, ., ("tei-choice5"), ., expan[1], abbr[1])
                        else
                            if (orig and reg) then
                                latex:alternate($config, ., ("tei-choice6"), ., reg[1], orig[1])
                            else
                                $config?apply($config, ./node())
                case element(cit) return
                    if (ancestor::teiHeader) then
                        (: No function found for behavior: :)
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, ./node())
                case element(closer) return
                    latex:block($config, ., ("tei-closer"), .)
                case element(code) return
                    latex:inline($config, ., ("tei-code"), .)
                case element(corr) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        (: simple inline, if in parent choice. :)
                        latex:inline($config, ., ("tei-corr1"), .)
                    else
                        latex:inline($config, ., ("tei-corr2"), .)
                case element(date) return
                    if (text()) then
                        latex:inline($config, ., ("tei-date1"), .)
                    else
                        if (@when and not(text())) then
                            latex:inline($config, ., ("tei-date2"), @when)
                        else
                            if (@type='published') then
                                latex:text($config, ., ("tei-date3"), concat(' (published ',.,')'))
                            else
                                if (text()) then
                                    latex:inline($config, ., ("tei-date5"), .)
                                else
                                    $config?apply($config, ./node())
                case element(dateline) return
                    latex:block($config, ., ("tei-dateline"), .)
                case element(del) return
                    if (@rend='erasure') then
                        latex:inline($config, ., ("tei-del"), .)
                    else
                        $config?apply($config, ./node())
                case element(desc) return
                    latex:inline($config, ., ("tei-desc"), .)
                case element(div) return
                    if (@type='textpart') then
                        latex:block($config, ., ("tei-div1", "texpart"), (
    latex:block($config, ., ("tei-div2", "textpart-label"), concat(upper-case(substring(@n,1,1)),substring(@n,2))),
    latex:block($config, ., ("tei-div3"), .)
)
)
                    else
                        if (@type='textpart') then
                            latex:block($config, ., ("tei-div4", "textpart"), .)
                        else
                            if (@type='bibliography') then
                                (
                                    if (listBibl) then
                                        latex:heading($config, ., ("tei-div5"), 'Secondary bibliography')
                                    else
                                        (),
                                    latex:section($config, ., ("tei-div6", "bibliography-secondary"), listBibl)
                                )

                            else
                                if (@type='translation' and *[text()[normalize-space(.)]]) then
                                    (
                                        latex:heading($config, ., ("tei-div7"),  let $plural := if (count(ab) > 1) then 's' else () return concat(upper-case(substring(@type,1,1)),substring(@type,2),$plural) ),
                                        latex:section($config, ., ("tei-div8", "translation"), .)
                                    )

                                else
                                    if (@type='edition') then
                                        latex:section($config, ., ("tei-div9", (@type)), if (div[@type='textpart']) then
    latex:block($config, ., ("tei-div10", (@type)), .)
else
    latex:block($config, ., ("tei-div11", "diveditionnormal"), .))
                                    else
                                        if (@type='apparatus') then
                                            (
                                                (: No function found for behavior: separator :)
                                                $config?apply($config, ./node()),
                                                latex:section($config, ., ("tei-div13", (@type)), .)
                                            )

                                        else
                                            if (@type='commentary' and not(p ='' or listApp/* ='')) then
                                                (
                                                    latex:heading($config, ., ("tei-div14", (@type)), concat(upper-case(substring(@type,1,1)),substring(@type,2))),
                                                    latex:section($config, ., ("tei-div15", (@type)), .)
                                                )

                                            else
                                                $config?apply($config, ./node())
                case element(docAuthor) return
                    latex:inline($config, ., ("tei-docAuthor"), .)
                case element(docDate) return
                    latex:inline($config, ., ("tei-docDate"), .)
                case element(docEdition) return
                    latex:inline($config, ., ("tei-docEdition"), .)
                case element(docImprint) return
                    latex:inline($config, ., ("tei-docImprint"), .)
                case element(docTitle) return
                    latex:block($config, ., css:get-rendition(., ("tei-docTitle")), .)
                case element(editor) return
                    if (ancestor::titleStmt and @role='general' and (count(following-sibling::editor[@role='general']) = 1)) then
                        latex:inline($config, ., ("tei-editor1"), persName)
                    else
                        if (ancestor::titleStmt and @role='contributor' and (count(following-sibling::editor[@role='contributor']) = 1)) then
                            latex:inline($config, ., ("tei-editor2"), persName)
                        else
                            if (ancestor::titleStmt and @role='general' and following-sibling::editor[@role='general']) then
                                latex:inline($config, ., ("tei-editor3"), persName)
                            else
                                if (ancestor::titleStmt and @role='contributor' and following-sibling::editor[@role='contributor']) then
                                    latex:inline($config, ., ("tei-editor4"), persName)
                                else
                                    if (surname or forename) then
                                        (
                                            latex:inline($config, ., ("tei-editor5"), surname),
                                            if (surname and forename) then
                                                latex:text($config, ., ("tei-editor6"), ', ')
                                            else
                                                (),
                                            latex:inline($config, ., ("tei-editor7"), forename),
                                            if (count(parent::*/editor) = 1) then
                                                latex:text($config, ., ("tei-editor8"), ', ed. ')
                                            else
                                                (),
                                            if (count(parent::*/editor) > 1) then
                                                latex:text($config, ., ("tei-editor9"), ', and ')
                                            else
                                                ()
                                        )

                                    else
                                        if (name) then
                                            (
                                                if (addName) then
                                                    (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                                                    latex:inline($config, ., ("tei-editor10"), normalize-space(concat(name,' (',addName,')')))
                                                else
                                                    (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                                                    latex:inline($config, ., ("tei-editor11"), name),
                                                if (count(parent::*/editor) = 1) then
                                                    latex:text($config, ., ("tei-editor12"), ', ed., ')
                                                else
                                                    if (following-sibling::*[2][local-name()='imprint']) then
                                                        latex:inline($config, ., ("tei-editor13"), ' =and= ')
                                                    else
                                                        if (following-sibling::* or position()=last()) then
                                                            latex:text($config, ., ("tei-editor14"), ', eds., ')
                                                        else
                                                            $config?apply($config, ./node())
                                            )

                                        else
                                            $config?apply($config, ./node())
                case element(email) return
                    latex:inline($config, ., ("tei-email"), .)
                case element(epigraph) return
                    latex:block($config, ., ("tei-epigraph"), .)
                case element(ex) return
                    latex:inline($config, ., ("tei-ex"), .)
                case element(expan) return
                    latex:inline($config, ., ("tei-expan"), .)
                case element(figDesc) return
                    latex:inline($config, ., ("tei-figDesc"), .)
                case element(figure) return
                    if (head or @rendition='simple:display') then
                        latex:block($config, ., ("tei-figure1"), .)
                    else
                        latex:inline($config, ., ("tei-figure2"), .)
                case element(floatingText) return
                    latex:block($config, ., ("tei-floatingText"), .)
                case element(foreign) return
                    latex:inline($config, ., ("tei-foreign"), .)
                case element(formula) return
                    if (@rendition='simple:display') then
                        latex:block($config, ., ("tei-formula1"), .)
                    else
                        latex:inline($config, ., ("tei-formula2"), .)
                case element(front) return
                    latex:block($config, ., ("tei-front"), .)
                case element(fw) return
                    latex:block($config, ., ("tei-fw"), .)
                case element(g) return
                    if (@type) then
                        latex:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if (@reason='lost' and @unit='line' and @quantity=1) then
                        latex:text($config, ., ("tei-gap1"), '.')
                    else
                        if (@reason='lost' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                            latex:inline($config, ., ("tei-gap2", "italic"), .)
                        else
                            if (@reason='illegible' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                latex:inline($config, ., ("tei-gap3", "italic"), .)
                            else
                                if ((@reason='lost' and @unit='line') and child::certainty[@locus='name']) then
                                    latex:inline($config, ., ("tei-gap4", "italic"), .)
                                else
                                    if ((@reason='illegible' and @unit='line') and child::certainty[@locus='name']) then
                                        latex:inline($config, ., ("tei-gap5", "italic"), .)
                                    else
                                        if (@reason='lost' and @unit='line' and @quantity= 1) then
                                            latex:inline($config, ., ("tei-gap6", "italic"), .)
                                        else
                                            if (@reason='illegible' and @unit='line' and @quantity= 1) then
                                                latex:inline($config, ., ("tei-gap7", "italic"), .)
                                            else
                                                if (@reason='lost' and @unit='line' and @extent='unknown') then
                                                    latex:inline($config, ., ("tei-gap8", "italic"), .)
                                                else
                                                    if (@reason='illegible' and @unit='line' and @extent='unknown') then
                                                        latex:inline($config, ., ("tei-gap9", "italic"), .)
                                                    else
                                                        if (@unit='aksarapart' and @quantity=1) then
                                                            latex:inline($config, ., ("tei-gap10", "aksarapart"), '.')
                                                        else
                                                            if ((@reason='lost' or @reason='illegible') and @extent='unknown') then
                                                                latex:inline($config, ., ("tei-gap11"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' /// ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||
							@reason || ')' else ' /// ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                            else
                                                                if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::*[1][local-name()='lb']) then
                                                                    latex:inline($config, ., ("tei-gap12", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' /// ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||
							@reason || ')' else ' /// ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                else
                                                                    if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and preceding-sibling::*[1][local-name()='lb']) then
                                                                        latex:inline($config, ., ("tei-gap13", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||
							')' || ' /// ' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || ' /// ' || $sep )
                                                                    else
                                                                        if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::text()[1]) then
                                                                            latex:inline($config, ., ("tei-gap14", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||
							')' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep)
                                                                        else
                                                                            $config?apply($config, ./node())
                case element(graphic) return
                    latex:graphic($config, ., ("tei-graphic"), ., @url, (), (), (), ())
                case element(group) return
                    latex:block($config, ., ("tei-group"), .)
                case element(head) return
                    if ($parameters?header='short') then
                        latex:inline($config, ., ("tei-head1"), replace(string-join(.//text()[not(parent::ref)]), '^(.*?)[^\w]*$', '$1'))
                    else
                        if (parent::figure) then
                            latex:block($config, ., ("tei-head2"), .)
                        else
                            if (parent::table) then
                                latex:block($config, ., ("tei-head3"), .)
                            else
                                if (parent::lg) then
                                    latex:block($config, ., ("tei-head4"), .)
                                else
                                    if (parent::list) then
                                        latex:block($config, ., ("tei-head5"), .)
                                    else
                                        if (parent::div[@type='edition']) then
                                            latex:block($config, ., ("tei-head6"), .)
                                        else
                                            (: More than one model without predicate found for ident head. Choosing first one. :)
                                            if (parent::div and not(@n)) then
                                                latex:heading($config, ., ("tei-head7"), .)
                                            else
                                                if (parent::div and @n) then
                                                    latex:link($config, ., ("tei-head8"), ., @n)
                                                else
                                                    $config?apply($config, ./node())
                case element(hi) return
                    if (@rendition) then
                        latex:inline($config, ., css:get-rendition(., ("tei-hi1")), .)
                    else
                        if (not(@rendition)) then
                            latex:inline($config, ., ("tei-hi2"), .)
                        else
                            $config?apply($config, ./node())
                case element(imprimatur) return
                    latex:block($config, ., ("tei-imprimatur"), .)
                case element(item) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    latex:listItem($config, ., ("tei-item"), .)
                case element(l) return
                    if ($parameters?break='Logical' and parent::lg[@met='Anuṣṭubh' or @met='Āryā']) then
                        (: Distich display for Anuṣṭubh or Āryā stances. See also lg spec. :)
                        latex:inline($config, ., ("tei-l1"), if (@n) then
    (
        latex:inline($config, ., ("tei-l2", "verse-number"), @n),
        latex:inline($config, ., ("tei-l3"), .)
    )

else
    $config?apply($config, ./node()))
                    else
                        if ($parameters?break='Logical') then
                            latex:block($config, ., ("tei-l4"), if (@n) then
    (
        latex:block($config, ., ("tei-l5", "verse-number"), @n),
        latex:block($config, ., ("tei-l6"), .)
    )

else
    $config?apply($config, ./node()))
                        else
                            if ($parameters?break='Physical') then
                                latex:inline($config, ., ("tei-l7"), .)
                            else
                                latex:block($config, ., ("tei-l8"), .)
                case element(label) return
                    latex:inline($config, ., ("tei-label"), .)
                case element(lb) return
                    latex:inline($config, ., ("tei-lb4", "lineNumber"), (
    latex:text($config, ., ("tei-lb5"), ' ('),
    latex:inline($config, ., ("tei-lb6"), if (@n) then @n else count(preceding-sibling::lb) + 1),
    latex:text($config, ., ("tei-lb7"), ') ')
)
)
                case element(lg) return
                    if (ancestor::div[@type='edition'] and $parameters?break='XML') then
                        (: No function found for behavior: xml :)
                        $config?apply($config, ./node())
                    else
                        if ((@met or @n) and $parameters?break='Logical') then
                            latex:block($config, ., ("tei-lg2", "stance-block"), (
    latex:inline($config, ., ("tei-lg3", "stance-number"), @n),
    latex:inline($config, ., ("tei-lg4", "stance-meter"), @met),
    if (@met='Anuṣṭubh' or @met='Āryā') then
        (
            latex:block($config, ., ("tei-lg5", "stance-part", "distich"), (
    if (child::*[following-sibling::l[@n='a']]) then
        latex:inline($config, ., ("tei-lg6"), child::*[following-sibling::l[@n='a']])
    else
        (),
    if (l[@n='a']) then
        latex:inline($config, ., ("tei-lg7"), l[@n='a'])
    else
        (),
    if (child::*[preceding-sibling::l[@n='a']][following-sibling::l[@n='b']]) then
        latex:inline($config, ., ("tei-lg8"), child::*[preceding-sibling::l[@n='a']][following-sibling::l[@n='b']])
    else
        (),
    if (l[@n='b']) then
        latex:inline($config, ., ("tei-lg9"), l[@n='b'])
    else
        ()
)
),
            latex:block($config, ., ("tei-lg10", "stance-part", "distich"), (
    if (child::*[preceding-sibling::l[@n='b']][following-sibling::l[@n='c']]) then
        latex:inline($config, ., ("tei-lg11"), child::*[preceding-sibling::l[@n='b']][following-sibling::l[@n='c']])
    else
        (),
    latex:inline($config, ., ("tei-lg12"), l[@n='c']),
    if (child::*[preceding-sibling::l[@n='c']][following-sibling::l[@n='d']]) then
        latex:inline($config, ., ("tei-lg13"), child::*[preceding-sibling::l[@n='c']][following-sibling::l[@n='d']])
    else
        (),
    latex:inline($config, ., ("tei-lg14"), l[@n='d'])
)
)
        )

    else
        (),
    if (not(@met='Anuṣṭubh' or @met='Āryā')) then
        latex:block($config, ., ("tei-lg15", "stance-part"), .)
    else
        ()
)
)
                        else
                            if ((@met or @n) and $parameters?break='Physical') then
                                latex:inline($config, ., ("tei-lg16"), .)
                            else
                                latex:block($config, ., ("tei-lg17", "block"), .)
                case element(list) return
                    if (@rendition) then
                        latex:list($config, ., css:get-rendition(., ("tei-list1")), item)
                    else
                        if (not(@rendition)) then
                            latex:list($config, ., ("tei-list2"), item)
                        else
                            $config?apply($config, ./node())
                case element(listBibl) return
                    if (child::biblStruct) then
                        latex:list($config, ., ("tei-listBibl1", "list-group"), biblStruct)
                    else
                        if (ancestor::surrogates or ancestor::div[@type='bibliography']) then
                            latex:list($config, ., ("tei-listBibl2"), .)
                        else
                            if (bibl) then
                                latex:list($config, ., ("tei-listBibl3"), bibl)
                            else
                                $config?apply($config, ./node())
                case element(measure) return
                    latex:inline($config, ., ("tei-measure"), .)
                case element(milestone) return
                    if (@unit='fragment') then
                        (: No function found for behavior: milestone :)
                        $config?apply($config, ./node())
                    else
                        if (@unit='face') then
                            (: No function found for behavior: milestone :)
                            $config?apply($config, ./node())
                        else
                            latex:inline($config, ., ("tei-milestone3"), .)
                case element(name) return
                    if (child::choice) then
                        latex:inline($config, ., ("tei-name1"), (
    if (choice/reg[@type='simplified']) then
        latex:inline($config, ., ("tei-name2"), choice/reg[@type='simplified'])
    else
        (),
    latex:text($config, ., ("tei-name3"), ' '),
    if (choice/reg[@type='simplified']) then
        latex:inline($config, ., ("tei-name4"), choice/reg[@type='popular'])
    else
        ()
)
)
                    else
                        latex:inline($config, ., ("tei-name5"), .)
                case element(note) return
                    if (parent::notesStmt and child::text()[normalize-space(.)]) then
                        latex:listItem($config, ., ("tei-note1"), .)
                    else
                        if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                            (
                                latex:inline($config, ., ("tei-note2", (ancestor::div/@type || '-note')), .)
                            )

                        else
                            if (not(ancestor::biblStruct) and parent::bibl) then
                                latex:inline($config, ., ("tei-note3"), .)
                            else
                                if (@type='tags' and ancestor::biblStruct) then
                                    latex:omit($config, ., ("tei-note4"), .)
                                else
                                    if (@type='accessed' and ancestor::biblStruct) then
                                        latex:omit($config, ., ("tei-note5"), .)
                                    else
                                        if (@type='thesisType' and ancestor::biblStruct) then
                                            latex:omit($config, ., ("tei-note6"), .)
                                        else
                                            if (not(@type='url') and ancestor::biblStruct) then
                                                latex:omit($config, ., ("tei-note7"), .)
                                            else
                                                if (ancestor::biblStruct and @type='url') then
                                                    (
                                                        latex:text($config, ., ("tei-note8"), '. URL: <'),
                                                        latex:link($config, ., ("tei-note9"), ., .),
                                                        latex:text($config, ., ("tei-note10"), '>')
                                                    )

                                                else
                                                    if (ancestor::biblStruct and not(preceding-sibling::*[not(@type='tags')][ends-with(.,'.')])) then
                                                        latex:inline($config, ., ("tei-note11"), '. ')
                                                    else
                                                        if (ancestor::listApp) then
                                                            latex:inline($config, ., ("tei-note12"), .)
                                                        else
                                                            latex:inline($config, ., ("tei-note13"), .)
                case element(num) return
                    latex:inline($config, ., ("tei-num"), .)
                case element(opener) return
                    latex:block($config, ., ("tei-opener"), .)
                case element(orig) return
                    latex:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (@rend='stanza') then
                        latex:block($config, ., ("tei-p1"), (
    latex:inline($config, ., ("tei-p2", "stance-number"), concat(@n,'.')),
    latex:paragraph($config, ., ("tei-p3"), .)
)
)
                    else
                        if (ancestor::div[@type='translation']) then
                            latex:block($config, ., ("tei-p4"), .)
                        else
                            if (parent::surrogates) then
                                latex:paragraph($config, ., ("tei-p5"), .)
                            else
                                if (parent::div[@type='bibliography']) then
                                    latex:inline($config, ., ("tei-p6"), .)
                                else
                                    if (parent::support) then
                                        latex:inline($config, ., ("tei-p7"), .)
                                    else
                                        if (parent::provenance) then
                                            latex:inline($config, ., ("tei-p8"), .)
                                        else
                                            if (ancestor::div[@type='commentary']) then
                                                latex:paragraph($config, ., ("tei-p9"), .)
                                            else
                                                if ($parameters?header='short') then
                                                    latex:omit($config, ., ("tei-p10"), .)
                                                else
                                                    latex:block($config, ., ("tei-p11"), .)
                case element(pb) return
                    latex:break($config, ., css:get-rendition(., ("tei-pb")), ., 'page', (concat(if(@n) then concat(@n,' ') else '',if(@facs) then                   concat('@',@facs) else '')))
                case element(pc) return
                    latex:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    latex:block($config, ., ("tei-postscript"), .)
                case element(publisher) return
                    (: More than one model without predicate found for ident publisher. Choosing first one. :)
                    (
                        if (ancestor::biblStruct and preceding-sibling::pubPlace) then
                            latex:text($config, ., ("tei-publisher1"), ': ')
                        else
                            (),
                        if (ancestor::biblStruct) then
                            latex:inline($config, ., ("tei-publisher2"), normalize-space(.))
                        else
                            ()
                    )

                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        latex:inline($config, ., ("tei-pubPlace"), .)
                    else
                        $config?apply($config, ./node())
                case element(q) return
                    if (l) then
                        latex:block($config, ., css:get-rendition(., ("tei-q1")), .)
                    else
                        if (ancestor::p or ancestor::cell) then
                            latex:inline($config, ., css:get-rendition(., ("tei-q2")), .)
                        else
                            latex:block($config, ., css:get-rendition(., ("tei-q3")), .)
                case element(quote) return
                    if (ancestor::teiHeader and parent::cit) then
                        (: If it is inside a cit then it is inline. :)
                        latex:inline($config, ., ("tei-quote1"), .)
                    else
                        if (ancestor::p or ancestor::note) then
                            (: If it is inside a paragraph or a note then it is inline, otherwise it is block level :)
                            latex:inline($config, ., css:get-rendition(., ("tei-quote2")), .)
                        else
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            latex:block($config, ., css:get-rendition(., ("tei-quote3")), .)
                case element(ref) return
                    if (ancestor::div[@type='translation']) then
                        latex:block($config, ., ("tei-ref1", "translation-ref"), .)
                    else
                        if (bibl[ptr[@target]]) then
                            latex:inline($config, ., ("tei-ref2"), bibl/ptr)
                        else
                            if (starts-with(@target,'#EIAD')) then
                                (: For corpus internal links (refs starts with '#'). To customize with corpus prefix (here 'EIAD') but needs declare namespace somewhere for config: :)
                                latex:link($config, ., ("tei-ref3"), ., substring-after(@target,'#') || '.xml' || "?odd=" || request:get-parameter("odd", ()))
                            else
                                if (not(@target)) then
                                    latex:inline($config, ., ("tei-ref4"), .)
                                else
                                    latex:link($config, ., ("tei-ref5"), @target, @target)
                case element(reg) return
                    if (ancestor::biblStruct and @type='popular') then
                        latex:inline($config, ., ("tei-reg1"), .)
                    else
                        if (ancestor::biblStruct and @type='simplified') then
                            latex:inline($config, ., ("tei-reg2"), .)
                        else
                            $config?apply($config, ./node())
                case element(relatedItem) return
                    latex:inline($config, ., ("tei-relatedItem"), .)
                case element(rhyme) return
                    latex:inline($config, ., ("tei-rhyme"), .)
                case element(role) return
                    latex:block($config, ., ("tei-role"), .)
                case element(roleDesc) return
                    latex:block($config, ., ("tei-roleDesc"), .)
                case element(row) return
                    if (@role='label') then
                        latex:row($config, ., ("tei-row1"), .)
                    else
                        (: Insert table row. :)
                        latex:row($config, ., ("tei-row2"), .)
                case element(rs) return
                    latex:inline($config, ., ("tei-rs"), .)
                case element(s) return
                    latex:inline($config, ., ("tei-s"), .)
                case element(salute) return
                    if (parent::closer) then
                        latex:inline($config, ., ("tei-salute1"), .)
                    else
                        latex:block($config, ., ("tei-salute2"), .)
                case element(seg) return
                    if (@type='check') then
                        latex:inline($config, ., ("tei-seg1", "seg"), .)
                    else
                        if (@type='continuous') then
                            latex:inline($config, ., ("tei-seg2"), w)
                        else
                            if (@type='graphemic') then
                                latex:inline($config, ., ("tei-seg3", "seg"), .)
                            else
                                if (@type='phonetic') then
                                    latex:inline($config, ., ("tei-seg4", "seg"), .)
                                else
                                    if (@type='phonemic') then
                                        latex:inline($config, ., ("tei-seg5", "seg"), .)
                                    else
                                        if (@type='t1') then
                                            latex:inline($config, ., ("tei-seg6", "seg"), .)
                                        else
                                            if (@type='translatedlines') then
                                                latex:inline($config, ., ("tei-seg7"), .)
                                            else
                                                latex:inline($config, ., ("tei-seg8"), .)
                case element(sic) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        latex:inline($config, ., ("tei-sic1"), .)
                    else
                        latex:inline($config, ., ("tei-sic2"), .)
                case element(signed) return
                    if (parent::closer) then
                        latex:block($config, ., ("tei-signed1"), .)
                    else
                        latex:inline($config, ., ("tei-signed2"), .)
                case element(sp) return
                    latex:block($config, ., ("tei-sp"), .)
                case element(speaker) return
                    latex:block($config, ., ("tei-speaker"), .)
                case element(spGrp) return
                    latex:block($config, ., ("tei-spGrp"), .)
                case element(stage) return
                    latex:block($config, ., ("tei-stage"), .)
                case element(subst) return
                    latex:inline($config, ., ("tei-subst"), .)
                case element(supplied) return
                    latex:omit($config, ., ("tei-supplied8"), .)
                case element(table) return
                    latex:table($config, ., ("tei-table"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            latex:inline($config, ., ("tei-fileDesc1", "header-short"), sourceDesc/msDesc/msIdentifier/idno),
                            latex:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        latex:title($config, ., ("tei-fileDesc35"), titleStmt)
                case element(profileDesc) return
                    latex:omit($config, ., ("tei-profileDesc"), .)
                case element(revisionDesc) return
                    if ($parameters?headerType='epidoc') then
                        latex:omit($config, ., ("tei-revisionDesc1"), .)
                    else
                        if ($parameters?header='short') then
                            latex:omit($config, ., ("tei-revisionDesc2"), .)
                        else
                            $config?apply($config, ./node())
                case element(encodingDesc) return
                    latex:omit($config, ., ("tei-encodingDesc"), .)
                case element(teiHeader) return
                    latex:metadata($config, ., ("tei-teiHeader1"), .)
                case element(TEI) return
                    latex:document($config, ., ("tei-TEI"), .)
                case element(term) return
                    latex:inline($config, ., ("tei-term"), .)
                case element(text) return
                    latex:body($config, ., ("tei-text"), .)
                case element(time) return
                    latex:inline($config, ., ("tei-time"), .)
                case element(title) return
                    if ($parameters?header='short') then
                        latex:inline($config, ., ("tei-title1"), .)
                    else
                        if (@type='translation' and ancestor::biblStruct) then
                            (
                                latex:text($config, ., ("tei-title2"), ' '),
                                if (preceding-sibling::*[1][@type='transcription']) then
                                    latex:text($config, ., ("tei-title3"), ' — ')
                                else
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        latex:text($config, ., ("tei-title4"), '[')
                                    else
                                        $config?apply($config, ./node()),
                                latex:inline($config, ., ("tei-title5"), .),
                                latex:text($config, ., ("tei-title6"), ']')
                            )

                        else
                            if (@type='transcription' and ancestor::biblStruct) then
                                (
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        latex:text($config, ., ("tei-title7"), ' ')
                                    else
                                        (),
                                    if (preceding-sibling::*[1][local-name()='title']) then
                                        latex:text($config, ., ("tei-title8"), '[')
                                    else
                                        (),
                                    latex:inline($config, ., ("tei-title9"), if ((@level='a' or @level='s' or @level='u') and ancestor::biblStruct) then
    latex:inline($config, ., ("tei-title10"), .)
else
    if ((@level='j' or @level='m') and ancestor::biblStruct) then
        latex:inline($config, ., ("tei-title11"), .)
    else
        latex:inline($config, ., ("tei-title12"), .)),
                                    if (not(following-sibling::*[1][@type='translation'])) then
                                        latex:text($config, ., ("tei-title13"), ']')
                                    else
                                        (),
                                    if (not(@level) and parent::bibl) then
                                        latex:inline($config, ., ("tei-title14"), .)
                                    else
                                        ()
                                )

                            else
                                if (@type='short' and ancestor::biblStruct) then
                                    latex:inline($config, ., ("tei-title15", "vedette"), .)
                                else
                                    if ((@level='a' or @level='s' or @level='u') and ancestor::biblStruct) then
                                        latex:inline($config, ., ("tei-title16"), .)
                                    else
                                        if ((@level='j' or @level='m') and ancestor::biblStruct) then
                                            latex:inline($config, ., ("tei-title17"), .)
                                        else
                                            $config?apply($config, ./node())
                case element(titlePage) return
                    latex:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    latex:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    latex:block($config, ., ("tei-trailer"), .)
                case element(unclear) return
                    (: More than one model without predicate found for ident unclear. Choosing first one. :)
                    latex:inline($config, ., ("tei-unclear1"), .)
                case element(w) return
                    if (@part='I' and $parameters?break='Physical') then
                        latex:inline($config, ., ("tei-w1"), let $part-F := following::w[1] return concat(.,$part-F))
                    else
                        if (@part='F' and $parameters?break='Physical') then
                            latex:omit($config, ., ("tei-w2"), .)
                        else
                            if (@type='hiatus-breaker') then
                                latex:inline($config, ., ("tei-w3"), .)
                            else
                                if (index-of(ancestor::seg[@type='join']/w, self::w) = 1) then
                                    latex:inline($config, ., ("tei-w4"), .)
                                else
                                    if (index-of(ancestor::seg[@type='join']/w, self::w) = count(ancestor::seg[@type='join']/w)) then
                                        latex:inline($config, ., ("tei-w5"), .)
                                    else
                                        $config?apply($config, ./node())
                case element(additional) return
                    if ($parameters?headerType='epidoc') then
                        latex:block($config, ., ("tei-additional"), .)
                    else
                        $config?apply($config, ./node())
                case element(addName) return
                    latex:inline($config, ., ("tei-addName"), .)
                case element(app) return
                    if (ancestor::div[@type='edition']) then
                        (
                            if (lem) then
                                latex:inline($config, ., ("tei-app1"), lem)
                            else
                                (),
                            if (rdg) then
                                (: No function found for behavior: popover :)
                                $config?apply($config, ./node())
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
                    latex:omit($config, ., ("tei-authority"), .)
                case element(biblStruct) return
                    if (parent::listBibl) then
                        latex:listItem($config, ., ("tei-biblStruct1", "list-group-item"), (
    (
        latex:inline($config, ., ("tei-biblStruct2"), if (.//title[@type='short']) then
    (: No function found for behavior: tooltip-link :)
    $config?apply($config, ./node())
else
    (
        if (.//author/surname) then
            latex:inline($config, ., ("tei-biblStruct4"), .//author/surname)
        else
            if (.//author/name) then
                latex:inline($config, ., ("tei-biblStruct5"), .//author/name)
            else
                $config?apply($config, ./node()),
        latex:text($config, ., ("tei-biblStruct6"), ' '),
        latex:inline($config, ., ("tei-biblStruct7"), monogr/imprint/date)
    )
)
    )
,
    (
        if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle') then
            (
                latex:inline($config, ., ("tei-biblStruct8"), analytic/author),
                if (analytic/title[@level='a']) then
                    (
                        latex:inline($config, ., ("tei-biblStruct9"), analytic/title[@level='a']),
                        latex:text($config, ., ("tei-biblStruct10"), ', ')
                    )

                else
                    if (not(analytic/title[@level='a']) and relatedItem[@type='reviewOf']) then
                        (
                            (: When it is a review of another bibliographic entry: so there's is no analytic/title[@level='a']. :)
                            latex:link($config, ., ("tei-biblStruct11"), relatedItem/ref, ()),
                            latex:text($config, ., ("tei-biblStruct12"), ', ')
                        )

                    else
                        $config?apply($config, ./node()),
                if (@type='bookSection' or @type='encyclopediaArticle') then
                    (
                        if (@type='bookSection' or @type='encyclopediaArticle') then
                            latex:text($config, ., ("tei-biblStruct13"), 'in ')
                        else
                            (),
                        latex:inline($config, ., ("tei-biblStruct14"), monogr/title[@level='m']),
                        latex:text($config, ., ("tei-biblStruct15"), ', '),
                        if (monogr/author) then
                            latex:text($config, ., ("tei-biblStruct16"), 'by ')
                        else
                            (),
                        latex:inline($config, ., ("tei-biblStruct17"), monogr/author),
                        if (monogr/editor) then
                            latex:inline($config, ., ("tei-biblStruct18"), monogr/editor)
                        else
                            ()
                    )

                else
                    (),
                if (@type='journalArticle') then
                    (
                        latex:inline($config, ., ("tei-biblStruct19"), monogr/title[@level='j']),
                        latex:text($config, ., ("tei-biblStruct20"), ', ')
                    )

                else
                    (),
                if (.//series) then
                    latex:inline($config, ., ("tei-biblStruct21"), series)
                else
                    (),
                if (.//monogr/imprint) then
                    latex:inline($config, ., ("tei-biblStruct22"), monogr/imprint)
                else
                    ()
            )

        else
            if (@type='book' or @type='manuscript' or @type='thesis' or @type='report') then
                (
                    latex:inline($config, ., ("tei-biblStruct23"), monogr/author),
                    latex:inline($config, ., ("tei-biblStruct24"), monogr/editor),
                    latex:inline($config, ., ("tei-biblStruct25"), monogr/respStmt),
                    if (@type='book' or @type='thesis' or @type='report') then
                        latex:inline($config, ., ("tei-biblStruct26"), monogr/title[@level='m'])
                    else
                        if (@type='manuscript') then
                            latex:inline($config, ., ("tei-biblStruct27"), monogr/title[@level='u'])
                        else
                            $config?apply($config, ./node()),
                    latex:text($config, ., ("tei-biblStruct28"), ', '),
                    if (.//series) then
                        latex:inline($config, ., ("tei-biblStruct29"), series)
                    else
                        (),
                    if (.//series/biblScope[@unit='volume']) then
                        latex:inline($config, ., ("tei-biblStruct30"), biblScope[@unit='volume'])
                    else
                        (),
                    if (monogr/imprint) then
                        (
                            if (@type='manuscript') then
                                latex:text($config, ., ("tei-biblStruct31"), ' manuscript ')
                            else
                                (),
                            if (@type='thesis') then
                                latex:text($config, ., ("tei-biblStruct32"), ' unpublished Ph.D., ')
                            else
                                (),
                            latex:inline($config, ., ("tei-biblStruct33"), monogr/imprint)
                        )

                    else
                        (),
                    if (note) then
                        (
                            latex:inline($config, ., ("tei-biblStruct34"), note)
                        )

                    else
                        ()
                )

            else
                if (@type='journal') then
                    (
                        latex:inline($config, ., ("tei-biblStruct35"), monogr/title[@level='j']),
                        latex:text($config, ., ("tei-biblStruct36"), ', '),
                        if (monogr/imprint) then
                            (
                                latex:inline($config, ., ("tei-biblStruct37"), monogr/imprint)
                            )

                        else
                            (),
                        if (note) then
                            (
                                latex:inline($config, ., ("tei-biblStruct38"), note)
                            )

                        else
                            ()
                    )

                else
                    if (@type='webpage') then
                        (
                            latex:inline($config, ., ("tei-biblStruct39"), monogr/author),
                            latex:inline($config, ., ("tei-biblStruct40"), monogr/title[not(@type='short')]),
                            latex:text($config, ., ("tei-biblStruct41"), ', '),
                            if (monogr/idno[@type='url'] or note[@type='url']) then
                                (
                                    latex:text($config, ., ("tei-biblStruct42"), 'retrieved on '),
                                    latex:inline($config, ., ("tei-biblStruct43"), monogr/note[@type='accessed']/date),
                                    latex:text($config, ., ("tei-biblStruct44"), ' from <'),
                                    if (monogr/idno[@type='url']) then
                                        latex:inline($config, ., ("tei-biblStruct45"), */idno)
                                    else
                                        if (note[@type='url']) then
                                            latex:inline($config, ., ("tei-biblStruct46"), note[@type='url'])
                                        else
                                            $config?apply($config, ./node()),
                                    latex:text($config, ., ("tei-biblStruct47"), '>')
                                )

                            else
                                (),
                            if (note) then
                                (
                                    if (note) then
                                        latex:inline($config, ., ("tei-biblStruct48"), note)
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
                latex:inline($config, ., ("tei-biblStruct49"), */idno[@type='url'])
            else
                ()
        )

    else
        (),
    if (.//*[position()=last()][not(local-name()='note')][not(ends-with(normalize-space(text()),'.'))]) then
        latex:text($config, ., ("tei-biblStruct50"), '.')
    else
        (),
    if (.//note[position()=last()][@type='thesisType' or @type='url' or @type='tags']) then
        latex:text($config, ., ("tei-biblStruct51"), '.')
    else
        ()
)
)
                    else
                        $config?apply($config, ./node())
                case element(dimensions) return
                    (
                        if (ancestor::support) then
                            latex:inline($config, ., ("tei-dimensions1"), .)
                        else
                            (),
                        if (@unit) then
                            latex:inline($config, ., ("tei-dimensions2"), @unit)
                        else
                            ()
                    )

                case element(height) return
                    if (parent::dimensions and @precision='unknown') then
                        latex:omit($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            latex:inline($config, ., ("tei-height2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions and following-sibling::*) then
                                latex:inline($config, ., ("tei-height3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                if (parent::dimensions and not(following-sibling::*)) then
                                    latex:inline($config, ., ("tei-height4"), if (@extent) then concat('(',@extent,') ',.) else .)
                                else
                                    latex:inline($config, ., ("tei-height5"), .)
                case element(width) return
                    if (parent::dimensions and count(following-sibling::*) >= 1) then
                        latex:inline($config, ., ("tei-width1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (parent::dimensions) then
                            latex:inline($config, ., ("tei-width2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            latex:inline($config, ., ("tei-width3"), .)
                case element(depth) return
                    if (parent::dimensions and @precision='unknown') then
                        latex:omit($config, ., ("tei-depth1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            latex:inline($config, ., ("tei-depth2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions) then
                                latex:inline($config, ., ("tei-depth3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                latex:inline($config, ., ("tei-depth4"), .)
                case element(dim) return
                    if (@type='diameter' and (parent::dimensions and following-sibling::*)) then
                        latex:inline($config, ., ("tei-dim1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (@type='diameter' and (parent::dimensions and not(following-sibling::*))) then
                            latex:inline($config, ., ("tei-dim2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            latex:inline($config, ., ("tei-dim3"), .)
                case element(handDesc) return
                    latex:inline($config, ., ("tei-handDesc"), .)
                case element(handNote) return
                    latex:inline($config, ., ("tei-handNote"), .)
                case element(idno) return
                    if (ancestor::biblStruct[@type='webpage'] and @type='url') then
                        latex:link($config, ., ("tei-idno1"), ., ())
                    else
                        if (ancestor::biblStruct and @type='url') then
                            (
                                latex:text($config, ., ("tei-idno2"), '. URL: <'),
                                latex:link($config, ., ("tei-idno3"), ., ()),
                                latex:text($config, ., ("tei-idno4"), '>')
                            )

                        else
                            if ($parameters?header='short') then
                                latex:inline($config, ., ("tei-idno5"), .)
                            else
                                if (ancestor::publicationStmt) then
                                    latex:inline($config, ., ("tei-idno6"), .)
                                else
                                    latex:inline($config, ., ("tei-idno7"), .)
                case element(imprint) return
                    if (ancestor::biblStruct[@type='book' or @type='journal' or @type='manuscript' or @type='report' or @type='thesis']) then
                        (
                            if (pubPlace) then
                                latex:inline($config, ., ("tei-imprint1"), pubPlace)
                            else
                                (),
                            if (publisher) then
                                latex:inline($config, ., ("tei-imprint2"), publisher)
                            else
                                (),
                            if (date and (pubPlace or publisher)) then
                                latex:text($config, ., ("tei-imprint3"), ', ')
                            else
                                (),
                            if (date) then
                                latex:inline($config, ., ("tei-imprint4"), date)
                            else
                                (),
                            if (note) then
                                latex:inline($config, ., ("tei-imprint5"), note)
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct[@type='journalArticle']) then
                            (
                                if (biblScope[@unit='volume']) then
                                    latex:inline($config, ., ("tei-imprint6"), biblScope[@unit='volume'])
                                else
                                    (),
                                if (following-sibling::*[1][@unit='issue']) then
                                    latex:text($config, ., ("tei-imprint7"), ', ')
                                else
                                    (),
                                if (biblScope[@unit='issue']) then
                                    latex:inline($config, ., ("tei-imprint8"), biblScope[@unit='issue'])
                                else
                                    (),
                                if (date) then
                                    latex:inline($config, ., ("tei-imprint9"), date)
                                else
                                    (),
                                if (biblScope[@unit='page']) then
                                    latex:inline($config, ., ("tei-imprint10"), biblScope[@unit='page'])
                                else
                                    (),
                                if (note) then
                                    latex:inline($config, ., ("tei-imprint11"), note)
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct[@type='encyclopediaArticle'] or ancestor::biblStruct[@type='bookSection']) then
                                (
                                    if (biblScope[@unit='volume']) then
                                        latex:inline($config, ., ("tei-imprint12"), biblScope[@unit='volume'])
                                    else
                                        (),
                                    if (pubPlace) then
                                        latex:inline($config, ., ("tei-imprint13"), pubPlace)
                                    else
                                        (),
                                    if (publisher) then
                                        latex:inline($config, ., ("tei-imprint14"), publisher)
                                    else
                                        (),
                                    if (date) then
                                        latex:text($config, ., ("tei-imprint15"), ', ')
                                    else
                                        (),
                                    if (date) then
                                        latex:inline($config, ., ("tei-imprint16"), date)
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        latex:inline($config, ., ("tei-imprint17"), biblScope[@unit='page'])
                                    else
                                        (),
                                    if (note) then
                                        latex:inline($config, ., ("tei-imprint18"), note)
                                    else
                                        ()
                                )

                            else
                                $config?apply($config, ./node())
                case element(layout) return
                    latex:inline($config, ., ("tei-layout"), p)
                case element(lem) return
                    if (ancestor::listApp) then
                        (
                            latex:inline($config, ., ("tei-lem1"), .),
                            if (@source) then
                                (: No function found for behavior: bibl-author-key :)
                                $config?apply($config, ./node())
                            else
                                (),
                            if (starts-with(@resp,'eiad-part:')) then
                                latex:inline($config, ., ("tei-lem3"), substring-after(@resp,'eiad-part:'))
                            else
                                (),
                            if (starts-with(@resp,'#')) then
                                latex:link($config, ., ("tei-lem4"), substring-after(@resp,'#'),  "?odd=" || request:get-parameter("odd", ()) || "&amp;view=" || request:get-parameter("view", ()) || "&amp;id=" || @resp )
                            else
                                (),
                            if (@rend) then
                                latex:inline($config, ., ("tei-lem5"), @rend)
                            else
                                ()
                        )

                    else
                        latex:inline($config, ., ("tei-lem6"), .)
                case element(licence) return
                    latex:omit($config, ., ("tei-licence"), .)
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
                    latex:inline($config, ., ("tei-msDesc"), .)
                case element(notesStmt) return
                    latex:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    latex:inline($config, ., ("tei-objectDesc"), .)
                case element(orgName) return
                    latex:inline($config, ., ("tei-orgName"), .)
                case element(persName) return
                    if (ancestor::div[@type]) then
                        (: No function found for behavior: link2 :)
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, ./node())
                case element(physDesc) return
                    latex:inline($config, ., ("tei-physDesc"), .)
                case element(provenance) return
                    if (parent::history) then
                        latex:inline($config, ., ("tei-provenance"), .)
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
                                latex:link($config, ., ("tei-ptr3"), @target, ())
                            else
                                $config?apply($config, ./node())
                case element(rdg) return
                    if (ancestor::listApp) then
                        (
                            latex:inline($config, ., ("tei-rdg1"), .),
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
                        latex:inline($config, ., ("tei-respStmt1"), persName)
                    else
                        latex:inline($config, ., ("tei-respStmt2"), .)
                case element(series) return
                    if (ancestor::biblStruct) then
                        latex:inline($config, ., ("tei-series1"), (
    latex:inline($config, ., ("tei-series2"), title[@level='s']),
    latex:inline($config, ., ("tei-series3"), biblScope)
)
)
                    else
                        $config?apply($config, ./node())
                case element(space) return
                    if (@type='horizontal' and child::certainty[@locus='name']) then
                        latex:inline($config, ., ("tei-space1"), '◊ [...] ')
                    else
                        if ((@unit='character' or @unit='chars') and child::certainty[@locus='name']) then
                            latex:inline($config, ., ("tei-space2"), '[◊]')
                        else
                            if (@type='horizontal') then
                                latex:inline($config, ., ("tei-space3"), '◊')
                            else
                                if (@type='binding-hole') then
                                    latex:inline($config, ., ("tei-space4"), '◯')
                                else
                                    $config?apply($config, ./node())
                case element(supportDesc) return
                    latex:inline($config, ., ("tei-supportDesc"), .)
                case element(surrogates) return
                    latex:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    latex:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    latex:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' return concat(normalize-space(.),$finale) )
                case element(titleStmt) return
                    (: No function found for behavior: meta :)
                    $config?apply($config, ./node())
                case element(facsimile) return
                    if ($parameters?modal='true') then
                        (: No function found for behavior: image-modals :)
                        $config?apply($config, ./node())
                    else
                        (
                            latex:heading($config, ., ("tei-facsimile2"), 'Facsimiles '),
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
                    latex:escapeChars(.)
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
                latex:escapeChars(.)
    )
};

