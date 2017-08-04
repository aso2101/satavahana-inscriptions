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

import module namespace config="http://www.tei-c.org/tei-simple/config" at "xmldb:exist:///db/apps/tei-publisher/modules/config.xqm";

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
                                                latex:block($config, ., ("tei-ab7"), .)
                                            else
                                                latex:block($config, ., ("tei-ab8"), .)
                case element(abbr) return
                    latex:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    latex:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    latex:inline($config, ., ("tei-add"), .)
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
                    if (ancestor::biblStruct) then
                        (
                            if (name) then
                                latex:inline($config, ., ("tei-author1"), name)
                            else
                                if (descendant-or-self::surname) then
                                    (
                                        latex:inline($config, ., ("tei-author2"), descendant-or-self::surname),
                                        latex:text($config, ., ("tei-author3"), ', '),
                                        latex:inline($config, ., ("tei-author4"), descendant-or-self::forename)
                                    )

                                else
                                    $config?apply($config, ./node()),
                            if (child::* and following-sibling::author and (count(following-sibling::author) = 1)) then
                                latex:text($config, ., ("tei-author5"), ' &#x26; ')
                            else
                                if (child::* and following-sibling::author and (count(following-sibling::author) > 1)) then
                                    latex:text($config, ., ("tei-author6"), ', ')
                                else
                                    if (child::* and not(following-sibling::author)) then
                                        latex:text($config, ., ("tei-author7"), ', ')
                                    else
                                        $config?apply($config, ./node())
                        )

                    else
                        $config?apply($config, ./node())
                case element(back) return
                    latex:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl[@ana='#photo'] and following-sibling::bibl) then
                        latex:listItem($config, ., ("tei-bibl1", "list-inline-item"), .)
                    else
                        if ((parent::listBibl[@ana='#photo'] and not(following-sibling::bibl))) then
                            latex:listItem($config, ., ("tei-bibl2", "list-inline-item"), .)
                        else
                            if (parent::listBibl[@ana='#photo-estampage'] and following-sibling::bibl) then
                                latex:listItem($config, ., ("tei-bibl3", "list-inline-item"), .)
                            else
                                if (parent::listBibl[@ana='#photo-estampage'] and not(following-sibling::bibl)) then
                                    latex:listItem($config, ., ("tei-bibl4", "list-inline-item"), .)
                                else
                                    if (parent::listBibl[@ana='#rti'] and following-sibling::bibl) then
                                        latex:listItem($config, ., ("tei-bibl5", "list-inline-item"), .)
                                    else
                                        if (parent::listBibl[@ana='#photo'] and not(following-sibling::bibl)) then
                                            latex:listItem($config, ., ("tei-bibl6", "list-inline-item"), .)
                                        else
                                            if (parent::listBibl and ancestor::div[@type='bibliography']) then
                                                (: No function found for behavior: listItemImage :)
                                                $config?apply($config, ./node())
                                            else
                                                latex:inline($config, ., ("tei-bibl8", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct) then
                        latex:inline($config, ., ("tei-biblScope"), .)
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
                        (: No function found for behavior: tooltip :)
                        $config?apply($config, ./node())
                    else
                        if (reg and not(orig)) then
                            latex:inline($config, ., ("tei-choice2"), reg)
                        else
                            $config?apply($config, ./node())
                case element(cit) return
                    (
                        latex:inline($config, ., ("tei-cit1"), quote),
                        latex:text($config, ., ("tei-cit2"), '('),
                        latex:inline($config, ., ("tei-cit3"), bibl),
                        latex:text($config, ., ("tei-cit4"), ')')
                    )

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
                    if (@type and ancestor::biblStruct) then
                        (
                            if (@type='cover') then
                                latex:inline($config, ., ("tei-date1"), .)
                            else
                                (),
                            if (@type='published') then
                                (
                                    latex:text($config, ., ("tei-date2"), ' (published '),
                                    latex:inline($config, ., ("tei-date3"), .),
                                    latex:text($config, ., ("tei-date4"), ')')
                                )

                            else
                                ()
                        )

                    else
                        if (text()) then
                            latex:inline($config, ., ("tei-date5"), .)
                        else
                            if (@when and not(text())) then
                                latex:inline($config, ., ("tei-date6"), @when)
                            else
                                if (text()) then
                                    latex:inline($config, ., ("tei-date8"), .)
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
                    if (ancestor::biblStruct) then
                        (
                            if (name) then
                                latex:inline($config, ., ("tei-editor1"), .)
                            else
                                if (descendant-or-self::surname) then
                                    (
                                        latex:inline($config, ., ("tei-editor2"), descendant-or-self::forename),
                                        latex:text($config, ., ("tei-editor3"), ' '),
                                        latex:inline($config, ., ("tei-editor4"), descendant-or-self::surname)
                                    )

                                else
                                    $config?apply($config, ./node()),
                            if (following-sibling::editor and (count(following-sibling::editor) = 1)) then
                                latex:text($config, ., ("tei-editor5"), ' &#x26; ')
                            else
                                if (following-sibling::editor and (count(following-sibling::editor) > 1)) then
                                    latex:text($config, ., ("tei-editor6"), ', ')
                                else
                                    if (not(following-sibling::editor)) then
                                        latex:text($config, ., ("tei-editor7"), ', ')
                                    else
                                        $config?apply($config, ./node())
                        )

                    else
                        if (ancestor::titleStmt and not(following-sibling::editor)) then
                            (
                                latex:inline($config, ., ("tei-editor8"), persName),
                                latex:text($config, ., ("tei-editor9"), '. ')
                            )

                        else
                            if (ancestor::titleStmt and @role='general' and (count(following-sibling::editor[@role='general']) = 1)) then
                                (
                                    latex:inline($config, ., ("tei-editor10"), persName),
                                    latex:text($config, ., ("tei-editor11"), ' and ')
                                )

                            else
                                if (ancestor::titleStmt and @role='contributor' and (count(following-sibling::editor[@role='contributor']) = 1)) then
                                    (
                                        latex:inline($config, ., ("tei-editor12"), persName),
                                        latex:text($config, ., ("tei-editor13"), ' and ')
                                    )

                                else
                                    if (ancestor::titleStmt and @role='general' and following-sibling::editor[@role='general']) then
                                        (
                                            latex:inline($config, ., ("tei-editor14"), persName),
                                            latex:text($config, ., ("tei-editor15"), ', ')
                                        )

                                    else
                                        if (ancestor::titleStmt and @role='general' and following-sibling::editor[@role='contributor']) then
                                            (
                                                latex:inline($config, ., ("tei-editor16"), persName),
                                                latex:text($config, ., ("tei-editor17"), ', ')
                                            )

                                        else
                                            if (ancestor::titleStmt and @role='contributor' and following-sibling::editor[@role='contributor']) then
                                                (
                                                    latex:inline($config, ., ("tei-editor18"), persName),
                                                    latex:text($config, ., ("tei-editor19"), ', ')
                                                )

                                            else
                                                if (surname or forename) then
                                                    (
                                                        latex:inline($config, ., ("tei-editor20"), surname),
                                                        if (surname and forename) then
                                                            latex:text($config, ., ("tei-editor21"), ', ')
                                                        else
                                                            (),
                                                        latex:inline($config, ., ("tei-editor22"), forename),
                                                        if (count(parent::*/editor) = 1) then
                                                            latex:text($config, ., ("tei-editor23"), ', ed. ')
                                                        else
                                                            (),
                                                        if (count(parent::*/editor) > 1) then
                                                            latex:text($config, ., ("tei-editor24"), ', and ')
                                                        else
                                                            ()
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
                    if (@place='marginleft') then
                        latex:inline($config, ., ("tei-fw1", "fw"), .)
                    else
                        if (@place='marginright') then
                            latex:inline($config, ., ("tei-fw2", "fw"), .)
                        else
                            $config?apply($config, ./node())
                case element(g) return
                    if (@type) then
                        latex:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if (@reason='lost' and @unit='line' and @quantity=1) then
                        latex:inline($config, ., ("tei-gap1"), '.')
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
                                                        if (@reason='lost' and @extent='unknown') then
                                                            latex:inline($config, ., ("tei-gap10", "italic"), .)
                                                        else
                                                            if (@unit='aksarapart' and @quantity=1) then
                                                                latex:inline($config, ., ("tei-gap11", "aksarapart"), '.')
                                                            else
                                                                if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='lost') then
                                                                    latex:inline($config, ., ("tei-gap12"), ' +')
                                                                else
                                                                    if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='illegible') then
                                                                        latex:inline($config, ., ("tei-gap13"), ' ?')
                                                                    else
                                                                        if ((@reason='lost' or @reason='illegible') and @extent='unknown') then
                                                                            latex:inline($config, ., ("tei-gap14"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||        @reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                        else
                                                                            if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::*[1][local-name()='lb']) then
                                                                                latex:inline($config, ., ("tei-gap15", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||        @reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                            else
                                                                                if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and preceding-sibling::*[1][local-name()='lb']) then
                                                                                    latex:inline($config, ., ("tei-gap16", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||        ')' || ' ' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || ' ' || $sep )
                                                                                else
                                                                                    if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::text()[1]) then
                                                                                        latex:inline($config, ., ("tei-gap17", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'        else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if        (following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||        ')' else (string-join((for $i in 1 to xs:integer($quantity) return ' ' || $charToRepeat),' ')) || $sep)
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
                    latex:inline($config, ., ("tei-lb5", "lineNumber"), (
    latex:text($config, ., ("tei-lb6"), ' ('),
    latex:inline($config, ., ("tei-lb7"), if (@n) then @n else count(preceding-sibling::lb) + 1),
    latex:text($config, ., ("tei-lb8"), ') ')
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
                        latex:list($config, ., ("tei-listBibl1", "list-group", "master-bibliography"), biblStruct)
                    else
                        if (@ana='#photo-estampage') then
                            latex:block($config, ., ("tei-listBibl2"), .)
                        else
                            if (@ana='#photo') then
                                latex:block($config, ., ("tei-listBibl3"), .)
                            else
                                if (@ana='#rti') then
                                    latex:block($config, ., ("tei-listBibl4"), .)
                                else
                                    if (ancestor::div[@type='bibliography']) then
                                        latex:list($config, ., ("tei-listBibl5"), .)
                                    else
                                        if (bibl) then
                                            latex:list($config, ., ("tei-listBibl6"), bibl)
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
                    if (child::choice and ancestor::biblStruct) then
                        latex:inline($config, ., ("tei-name1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (./choice/reg[@type='simplified']) then
            latex:inline($config, ., ("tei-name2"), choice/reg[@type='simplified'])
        else
            (),
        latex:text($config, ., ("tei-name3"), ' '),
        if (./choice/reg[@type='simplified']) then
            latex:inline($config, ., ("tei-name4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        latex:inline($config, ., ("tei-name5"), .)
                case element(note) return
                    if (@type='tags' and ancestor::biblStruct) then
                        latex:omit($config, ., ("tei-note1"), .)
                    else
                        if (@type='tag' and ancestor::biblStruct) then
                            latex:omit($config, ., ("tei-note2"), .)
                        else
                            if (@type='accessed' and ancestor::biblStruct) then
                                latex:omit($config, ., ("tei-note3"), .)
                            else
                                if (@type='thesisType' and ancestor::biblStruct) then
                                    latex:omit($config, ., ("tei-note4"), .)
                                else
                                    if (not(@type) and ancestor::biblStruct) then
                                        latex:omit($config, ., ("tei-note5"), .)
                                    else
                                        if (preceding-sibling::*[1][local-name()='relatedItem']) then
                                            (
                                                latex:text($config, ., ("tei-note6"), '. '),
                                                latex:inline($config, ., ("tei-note7"), .),
                                                latex:text($config, ., ("tei-note8"), ' '),
                                                latex:link($config, ., ("tei-note9"), 'See related item',  '?tabs=no&amp;odd=' || request:get-parameter('odd', ()) || '?' || ../relatedItem/ref/@target)
                                            )

                                        else
                                            if (@type='url' and ancestor::biblStruct) then
                                                (
                                                    latex:text($config, ., ("tei-note10"), '. URL: <'),
                                                    latex:link($config, ., ("tei-note11"), ., ()),
                                                    latex:text($config, ., ("tei-note12"), '>')
                                                )

                                            else
                                                if ((ancestor::listApp or ancestor::listBibl) and (preceding-sibling::*[1][local-name() ='lem' or local-name()='rdg'] or parent::bibl)) then
                                                    (
                                                        latex:inline($config, ., ("tei-note13", (ancestor::div/@type || '-note')), .)
                                                    )

                                                else
                                                    if (parent::notesStmt and child::text()[normalize-space(.)]) then
                                                        latex:listItem($config, ., ("tei-note14"), .)
                                                    else
                                                        if (not(ancestor::biblStruct) and parent::bibl) then
                                                            latex:inline($config, ., ("tei-note15"), .)
                                                        else
                                                            latex:inline($config, ., ("tei-note16"), .)
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
                                if ($parameters?headerType='epidoc' and parent::div[@type='bibliography']) then
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
                                                    if (parent::div[@type='bibliography']) then
                                                        latex:omit($config, ., ("tei-p11"), .)
                                                    else
                                                        latex:block($config, ., ("tei-p12"), .)
                case element(pb) return
                    if (@type and $parameters?break='Physical') then
                        (: No function found for behavior: milestone :)
                        $config?apply($config, ./node())
                    else
                        if (@type and $parameters?break='Logical') then
                            (: No function found for behavior: milestone :)
                            $config?apply($config, ./node())
                        else
                            latex:omit($config, ., ("tei-pb3"), .)
                case element(pc) return
                    latex:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    latex:block($config, ., ("tei-postscript"), .)
                case element(publisher) return
                    if (ancestor::biblStruct) then
                        (
                            latex:inline($config, ., ("tei-publisher1"), .),
                            if (parent::imprint/date) then
                                latex:text($config, ., ("tei-publisher2"), ', ')
                            else
                                ()
                        )

                    else
                        latex:inline($config, ., ("tei-publisher3"), .)
                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        (
                            latex:inline($config, ., ("tei-pubPlace1"), .),
                            if (parent::imprint/pubPlace) then
                                latex:text($config, ., ("tei-pubPlace2"), ': ')
                            else
                                ()
                        )

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
                    if (@rend='no-link') then
                        latex:inline($config, ., ("tei-ref1"), .)
                    else
                        if (ancestor::div[@type='translation']) then
                            latex:block($config, ., ("tei-ref2", "translation-ref"), .)
                        else
                            if (bibl[ptr[@target]]) then
                                latex:inline($config, ., ("tei-ref3"), bibl/ptr)
                            else
                                if (starts-with(@target, concat('#', $config:project-code))) then
                                    latex:link($config, ., ("tei-ref4"), ., substring-after(@target,'#') || '.xml' || '?odd='|| request:get-parameter('odd', ()))
                                else
                                    if (not(@target)) then
                                        latex:inline($config, ., ("tei-ref5"), .)
                                    else
                                        latex:link($config, ., ("tei-ref6"), @target, @target)
                case element(reg) return
                    if (@type='popular') then
                        (
                            latex:text($config, ., ("tei-reg1"), '['),
                            latex:inline($config, ., ("tei-reg2"), .),
                            latex:text($config, ., ("tei-reg3"), ']')
                        )

                    else
                        if (@type='1' or @type='2' or @type='3'or @type='4'or @type='5'or @type='6' or @type='7') then
                            (
                                latex:text($config, ., ("tei-reg4"), '['),
                                latex:inline($config, ., ("tei-reg5"), .),
                                latex:text($config, ., ("tei-reg6"), ']')
                            )

                        else
                            if (@type='simplified' or not(@type)) then
                                (
                                    latex:inline($config, ., ("tei-reg7"), .),
                                    if (following-sibling::reg) then
                                        latex:text($config, ., ("tei-reg8"), ' ')
                                    else
                                        ()
                                )

                            else
                                latex:inline($config, ., ("tei-reg9"), reg)
                case element(relatedItem) return
                    (
                        latex:text($config, ., ("tei-relatedItem1"), '. '),
                        latex:inline($config, ., ("tei-relatedItem2"), .),
                        if (following-sibling::note) then
                            (
                                latex:text($config, ., ("tei-relatedItem3"), '. '),
                                latex:inline($config, ., ("tei-relatedItem4"), following-sibling::note)
                            )

                        else
                            ()
                    )

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
                        if (@type='graphemic') then
                            latex:inline($config, ., ("tei-seg2", "seg"), .)
                        else
                            if (@type='phonetic') then
                                latex:inline($config, ., ("tei-seg3", "seg"), .)
                            else
                                if (@type='phonemic') then
                                    latex:inline($config, ., ("tei-seg4", "seg"), .)
                                else
                                    if (@type='translatedlines') then
                                        latex:inline($config, ., ("tei-seg5"), .)
                                    else
                                        latex:inline($config, ., ("tei-seg6"), .)
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
                    latex:omit($config, ., ("tei-supplied6"), .)
                case element(table) return
                    latex:table($config, ., ("tei-table"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            latex:inline($config, ., ("tei-fileDesc1", "header-short"), sourceDesc/msDesc/msIdentifier/idno),
                            latex:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        latex:title($config, ., ("tei-fileDesc36"), titleStmt)
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
                case element(analytic) return
                    if (ancestor::biblStruct) then
                        (
                            latex:inline($config, ., ("tei-analytic1"), author),
                            if (following-sibling::*) then
                                latex:text($config, ., ("tei-analytic2"), ', ')
                            else
                                (),
                            latex:inline($config, ., ("tei-analytic3"), title)
                        )

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
                    latex:block($config, ., ("tei-biblStruct1"), (
    (
        latex:inline($config, ., ("tei-biblStruct2"), if (.//title[@type='short']) then
    (: No function found for behavior: bibl-link :)
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
                        (),
                    if (@type='manuscript') then
                        latex:inline($config, ., ("tei-biblStruct27"), monogr/title[@level='u'])
                    else
                        (),
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
                case element(dimensions) return
                    if (ancestor::supportDesc or ancestor::layoutDesc) then
                        (
                            latex:inline($config, ., ("tei-dimensions1"), .),
                            if (@unit) then
                                latex:inline($config, ., ("tei-dimensions2"), @unit)
                            else
                                ()
                        )

                    else
                        latex:inline($config, ., ("tei-dimensions3"), .)
                case element(edition) return
                    if (ancestor::biblStruct) then
                        (
                            latex:text($config, ., ("tei-edition1"), '. '),
                            latex:inline($config, ., ("tei-edition2"), .)
                        )

                    else
                        $config?apply($config, ./node())
                case element(forename) return
                    if (child::choice and ancestor::biblStruct) then
                        latex:inline($config, ., ("tei-forename1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (choice/reg[@type='simplified']) then
            latex:inline($config, ., ("tei-forename2"), choice/reg[@type='simplified'])
        else
            (),
        latex:text($config, ., ("tei-forename3"), ' '),
        if (choice/reg[@type='simplified']) then
            latex:inline($config, ., ("tei-forename4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        latex:inline($config, ., ("tei-forename5"), .)
                case element(height) return
                    if (parent::dimensions and @precision='unknown') then
                        latex:omit($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            latex:inline($config, ., ("tei-height2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions and not(following-sibling::*)) then
                                latex:inline($config, ., ("tei-height3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                    latex:inline($config, ., ("tei-height4"), .)
                                else
                                    $config?apply($config, ./node())
                case element(width) return
                    if (parent::dimensions and count(following-sibling::*) >= 1) then
                        latex:inline($config, ., ("tei-width1"), if (@extent) then concat('(',@extent,') ',.) else .)
                    else
                        if (parent::dimensions) then
                            latex:inline($config, ., ("tei-width2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                latex:inline($config, ., ("tei-width3"), .)
                            else
                                $config?apply($config, ./node())
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
                            if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                latex:inline($config, ., ("tei-dim3"), .)
                            else
                                $config?apply($config, ./node())
                case element(handDesc) return
                    latex:inline($config, ., ("tei-handDesc"), .)
                case element(handNote) return
                    latex:inline($config, ., ("tei-handNote"), let $finale := if (ends-with(normalize-space(.),'.')) then () else if (*[text()[normalize-space(.)]]) then '.* ' else () return (.,$finale))
                case element(idno) return
                    if ($parameters?header='short') then
                        latex:inline($config, ., ("tei-idno1"), .)
                    else
                        if (ancestor::publicationStmt) then
                            latex:inline($config, ., ("tei-idno2"), .)
                        else
                            latex:inline($config, ., ("tei-idno3"), .)
                case element(imprint) return
                    if (ancestor::biblStruct) then
                        (
                            latex:inline($config, ., ("tei-imprint1"), pubPlace),
                            latex:inline($config, ., ("tei-imprint2"), publisher),
                            if (following-sibling::date) then
                                latex:text($config, ., ("tei-imprint3"), ', ')
                            else
                                (),
                            latex:inline($config, ., ("tei-imprint4"), date),
                            if (biblScope[@unit='page']) then
                                latex:text($config, ., ("tei-imprint5"), ': ')
                            else
                                (),
                            latex:inline($config, ., ("tei-imprint6"), biblScope[@unit='page'])
                        )

                    else
                        $config?apply($config, ./node())
                case element(layout) return
                    latex:inline($config, ., ("tei-layout"), .)
                (: There should be no dot before note if this element follows immediately after lem. This rule should be refined and limited to cases where lem had no source or rend. :)
                case element(lem) return
                    if (ancestor::listApp) then
                        (
                            latex:inline($config, ., ("tei-lem1"), .),
                            if (@rend and not(following-sibling::*[1][local-name()='rdg'])) then
                                latex:inline($config, ., ("tei-lem2", "bibl-rend"), if (ends-with(@rend,'.')) then substring-before(@rend,'.') else @rend)
                            else
                                (),
                            if (@rend and following-sibling::*[1][local-name()='rdg']) then
                                latex:inline($config, ., ("tei-lem3", "bibl-rend"), @rend)
                            else
                                (),
                            if (@source) then
                                (: No function found for behavior: bibl-initials-for-ref :)
                                $config?apply($config, ./node())
                            else
                                (),
                            if (starts-with(@resp,concat($config:project-code,'-part:'))) then
                                latex:inline($config, ., ("tei-lem5"), substring-after(@resp,concat($config:project-code,'-part:')))
                            else
                                (),
                            if (starts-with(@resp,'#')) then
                                latex:link($config, ., ("tei-lem6"), substring-after(@resp,'#'),  '?odd=' || request:get-parameter('odd', ()) || '&amp;view=' || request:get-parameter('view', ()) || '&amp;id='|| @resp)
                            else
                                (),
                            if (not(following-sibling::*[1][local-name() = ('rdg', 'note')]) or (@source or @rend)) then
                                latex:inline($config, ., ("tei-lem7", "period"), '.')
                            else
                                ()
                        )

                    else
                        latex:inline($config, ., ("tei-lem8"), .)
                case element(licence) return
                    latex:omit($config, ., ("tei-licence"), .)
                case element(listApp) return
                    if (parent::div[@type='commentary']) then
                        (: No function found for behavior: list-app :)
                        $config?apply($config, ./node())
                    else
                        (: More than one model without predicate found for ident listApp. Choosing first one. :)
                        (
                            if (parent::div[@type='apparatus'] and @corresp) then
                                latex:inline($config, ., ("tei-listApp1", "textpart-label"), let $id := substring-after(@corresp,'#') return preceding::div[@type='edition']//div[@type='textpart'][@xml:id=$id]/@n)
                            else
                                (),
                            if (parent::div[@type='apparatus']) then
                                (: No function found for behavior: list-app :)
                                $config?apply($config, ./node())
                            else
                                ()
                        )

                case element(notesStmt) return
                    latex:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    latex:inline($config, ., ("tei-objectDesc"), .)
                case element(persName) return
                    if (ancestor::div[@type]) then
                        latex:link($config, ., ("tei-persName1"), ., ())
                    else
                        if (ancestor::person and @type) then
                            latex:inline($config, ., ("tei-persName2"), .)
                        else
                            if (ancestor::person) then
                                latex:inline($config, ., ("tei-persName3"), .)
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
                        (
                            latex:inline($config, ., ("tei-series1"), title),
                            if (biblScope) then
                                latex:text($config, ., ("tei-series2"), ', ')
                            else
                                (),
                            latex:inline($config, ., ("tei-series3"), biblScope),
                            latex:text($config, ., ("tei-series4"), ', ')
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
                                    if (@type='defect') then
                                        latex:inline($config, ., ("tei-space5"), '□')
                                    else
                                        $config?apply($config, ./node())
                case element(supportDesc) return
                    latex:inline($config, ., ("tei-supportDesc"), .)
                case element(surname) return
                    if (child::choice and ancestor::biblStruct) then
                        latex:inline($config, ., ("tei-surname1"), if (descendant::reg[@type='simplified'] and descendant::reg[@type='popular']) then
    (
        if (choice/reg[@type='simplified']) then
            latex:inline($config, ., ("tei-surname2"), choice/reg[@type='simplified'])
        else
            (),
        latex:text($config, ., ("tei-surname3"), ' '),
        if (choice/reg[@type='simplified']) then
            latex:inline($config, ., ("tei-surname4"), choice/reg[@type='popular'])
        else
            ()
    )

else
    $config?apply($config, ./node()))
                    else
                        latex:inline($config, ., ("tei-surname5"), .)
                case element(surrogates) return
                    latex:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    latex:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    latex:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' return concat(normalize-space(.),$finale))
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
                case element(placeName) return
                    if (ancestor::div[@type] or ancestor::origPlace) then
                        latex:link($config, ., ("tei-placeName"), ., ())
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

