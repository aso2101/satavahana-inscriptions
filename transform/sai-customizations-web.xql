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

import module namespace ext-html="http://www.hisoma.mom.fr/labs/epigraphy" at "xmldb:exist:///db/apps/SAI/modules/ext-html.xql";

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
                                                html:block($config, ., ("tei-ab7", "well"), .)
                                            else
                                                html:block($config, ., ("tei-ab8"), .)
                case element(abbr) return
                    html:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    html:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    if (@place='below') then
                        html:inline($config, ., ("tei-add"), .)
                    else
                        $config?apply($config, ./node())
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
                    if (ancestor::teiHeader) then
                        html:block($config, ., ("tei-author1"), .)
                    else
                        if (ancestor::biblStruct) then
                            html:inline($config, ., ("tei-author2"), if (surname or forename) then
    (
        html:inline($config, ., ("tei-author3"), surname),
        if (surname and forename) then
            html:text($config, ., ("tei-author4"), ', ')
        else
            (),
        html:inline($config, ., ("tei-author5"), forename),
        if (following-sibling::* or position()=last()) then
            html:text($config, ., ("tei-author6"), ', ')
        else
            ()
    )

else
    if (name) then
        (
            if (addName) then
                (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                html:inline($config, ., ("tei-author7"), normalize-space(concat(name,' (',addName,')')))
            else
                (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                html:inline($config, ., ("tei-author8"), name),
            if (following-sibling::*[2][local-name()='imprint']) then
                html:inline($config, ., ("tei-author9"), ' +and+ ')
            else
                if (following-sibling::* or position()=last()) then
                    html:text($config, ., ("tei-author10"), ', ')
                else
                    $config?apply($config, ./node())
        )

    else
        $config?apply($config, ./node()))
                        else
                            $config?apply($config, ./node())
                case element(back) return
                    html:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl[@ana='#photo']) then
                        ext-html:listItemImage($config, ., ("tei-bibl1"), ., (), 'photo_camera')
                    else
                        if (parent::listBibl[@ana='#photo-estampage']) then
                            ext-html:listItemImage($config, ., ("tei-bibl2"), ., (), 'monochrome_photos')
                        else
                            if (parent::listBibl[@ana='#rti']) then
                                ext-html:listItemImage($config, ., ("tei-bibl3"), ., (), 'camera_enhance')
                            else
                                if (parent::listBibl and ancestor::div[@type='bibliography']) then
                                    ext-html:listItemImage($config, ., ("tei-bibl4"), ., (), 'bookmark')
                                else
                                    if (parent::cit) then
                                        html:inline($config, ., ("tei-bibl5"), .)
                                    else
                                        if (parent::listBibl) then
                                            html:listItem($config, ., ("tei-bibl6"), .)
                                        else
                                            (: More than one model without predicate found for ident bibl. Choosing first one. :)
                                            html:inline($config, ., ("tei-bibl7", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct and @unit='series') then
                        (
                            html:inline($config, ., ("tei-biblScope1"), .),
                            if (following-sibling::*) then
                                html:text($config, ., ("tei-biblScope2"), ', ')
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct and @unit='volume') then
                            (
                                if (preceding-sibling::*) then
                                    html:text($config, ., ("tei-biblScope3"), ', ')
                                else
                                    (),
                                if (ancestor::biblStruct and not(following-sibling::biblScope[1][@unit='issue'])) then
                                    html:inline($config, ., ("tei-biblScope4"), .)
                                else
                                    (),
                                if (ancestor::biblStruct and following-sibling::biblScope[1][@unit='issue']) then
                                    html:inline($config, ., ("tei-biblScope5"), .)
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct and @unit='issue') then
                                (
                                    html:inline($config, ., ("tei-biblScope6"), .),
                                    if (following-sibling::*) then
                                        html:text($config, ., ("tei-biblScope7"), ', ')
                                    else
                                        ()
                                )

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
                        html:alternate($config, ., ("tei-choice4"), ., corr[1], sic[1])
                    else
                        if (abbr and expan) then
                            html:alternate($config, ., ("tei-choice5"), ., expan[1], abbr[1])
                        else
                            if (orig and reg) then
                                html:alternate($config, ., ("tei-choice6"), ., reg[1], orig[1])
                            else
                                $config?apply($config, ./node())
                case element(cit) return
                    if (ancestor::teiHeader) then
                        (: No function found for behavior: :)
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, ./node())
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
                    if (@type='published') then
                        html:text($config, ., ("tei-date3"), concat(' (published ',.,')'))
                    else
                        if (@when) then
                            (: desactive le comportement alternate de tei_simplePrint :)
                            html:inline($config, ., ("tei-date4"), .)
                        else
                            if (text()) then
                                html:inline($config, ., ("tei-date5"), .)
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
                        if (@type='textpart') then
                            html:block($config, ., ("tei-div4", "textpart"), .)
                        else
                            if (@type='bibliography') then
                                (
                                    if (listBibl) then
                                        html:heading($config, ., ("tei-div5"), 'Secondary bibliography', 3)
                                    else
                                        (),
                                    ext-html:section($config, ., ("tei-div6", "bibliography-secondary"), (), listBibl)
                                )

                            else
                                if (@type='translation' and *[text()[normalize-space(.)]]) then
                                    (
                                        html:heading($config, ., ("tei-div7"),  let $plural := if (count(ab) > 1) then 's' else () return concat(upper-case(substring(@type,1,1)),substring(@type,2),$plural) , 3),
                                        ext-html:section($config, ., ("tei-div8", "translation"), (), .)
                                    )

                                else
                                    if (@type='edition') then
                                        ext-html:section($config, ., ("tei-div9", (@type)), (), if (div[@type='textpart']) then
    html:block($config, ., ("tei-div10", (@type)), .)
else
    html:block($config, ., ("tei-div11", "diveditionnormal"), .))
                                    else
                                        if (@type='apparatus') then
                                            (
                                                ext-html:separator($config, ., ("tei-div12", ('apparatus-sep')), ''),
                                                ext-html:section($config, ., ("tei-div13", (@type)), (), .)
                                            )

                                        else
                                            if (@type='commentary' and not(p ='' or listApp/* ='')) then
                                                (
                                                    html:heading($config, ., ("tei-div14", (@type)), concat(upper-case(substring(@type,1,1)),substring(@type,2)), 3),
                                                    ext-html:section($config, ., ("tei-div15", (@type)), (), .)
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
                    if (ancestor::titleStmt and @role='general' and (count(following-sibling::editor[@role='general']) = 1)) then
                        html:inline($config, ., ("tei-editor1"), persName)
                    else
                        if (ancestor::titleStmt and @role='contributor' and (count(following-sibling::editor[@role='contributor']) = 1)) then
                            html:inline($config, ., ("tei-editor2"), persName)
                        else
                            if (ancestor::titleStmt and @role='general' and following-sibling::editor[@role='general']) then
                                html:inline($config, ., ("tei-editor3"), persName)
                            else
                                if (ancestor::titleStmt and @role='contributor' and following-sibling::editor[@role='contributor']) then
                                    html:inline($config, ., ("tei-editor4"), persName)
                                else
                                    if (surname or forename) then
                                        (
                                            html:inline($config, ., ("tei-editor5"), surname),
                                            if (surname and forename) then
                                                html:text($config, ., ("tei-editor6"), ', ')
                                            else
                                                (),
                                            html:inline($config, ., ("tei-editor7"), forename),
                                            if (count(parent::*/editor) = 1) then
                                                html:text($config, ., ("tei-editor8"), ', ed. ')
                                            else
                                                (),
                                            if (count(parent::*/editor) > 1) then
                                                html:text($config, ., ("tei-editor9"), ', and ')
                                            else
                                                ()
                                        )

                                    else
                                        if (name) then
                                            (
                                                if (addName) then
                                                    (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                                                    html:inline($config, ., ("tei-editor10"), normalize-space(concat(name,' (',addName,')')))
                                                else
                                                    (: doesn't use element spec for addName because of whitespace caused by linefeed in xml :)
                                                    html:inline($config, ., ("tei-editor11"), name),
                                                if (count(parent::*/editor) = 1) then
                                                    html:text($config, ., ("tei-editor12"), ', ed., ')
                                                else
                                                    if (following-sibling::*[2][local-name()='imprint']) then
                                                        html:inline($config, ., ("tei-editor13"), ' =and= ')
                                                    else
                                                        if (following-sibling::* or position()=last()) then
                                                            html:text($config, ., ("tei-editor14"), ', eds., ')
                                                        else
                                                            $config?apply($config, ./node())
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
                    html:inline($config, ., ("tei-figDesc"), .)
                case element(figure) return
                    if (head or @rendition='simple:display') then
                        html:block($config, ., ("tei-figure1"), .)
                    else
                        html:inline($config, ., ("tei-figure2"), .)
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
                    html:block($config, ., ("tei-fw"), .)
                case element(g) return
                    if (@type) then
                        html:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if (@reason='lost' and @unit='line' and @quantity=1) then
                        html:text($config, ., ("tei-gap1"), '.')
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
                                                                    html:inline($config, ., ("tei-gap12"), '+')
                                                                else
                                                                    if ((@unit='character' or @unit='chars') and @quantity=1 and @reason='illegible') then
                                                                        html:inline($config, ., ("tei-gap13"), '?')
                                                                    else
                                                                        if ((@reason='lost' or @reason='illegible') and @extent='unknown') then
                                                                            html:inline($config, ., ("tei-gap14"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||
							@reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                        else
                                                                            if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::*[1][local-name()='lb']) then
                                                                                html:inline($config, ., ("tei-gap15", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision = 'low') then ' ' || '([about] ' || @quantity || ' ' || $unit || ' ' ||
							@reason || ')' else ' ' || (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || $sep )
                                                                            else
                                                                                if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and preceding-sibling::*[1][local-name()='lb']) then
                                                                                    html:inline($config, ., ("tei-gap16", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||
							')' || ' ' else (string-join((for $i in 1 to xs:integer($quantity) return $charToRepeat),' ')) || ' ' || $sep )
                                                                                else
                                                                                    if ((@unit='character' or @unit='akṣara' or @unit='chars') and (@reason='lost' or @reason='illegible') and @quantity and following-sibling::text()[1]) then
                                                                                        html:inline($config, ., ("tei-gap17", "italic"),  let $charToRepeat := if (@reason = 'lost') then '+' else if (@reason='illegible') then '?' else () let $unit := if (@quantity > 1) then @unit || 's'
							else @unit let $quantity := if (@precision = 'low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason || ')' else @quantity let $sep := if
							(following-sibling::*[1][local-name()='lb'][@break='no']) then '' else ' ' return if (@precision ='low') then '([about] ' || @quantity || ' ' || $unit || ' ' || @reason ||
							')' else (string-join((for $i in 1 to xs:integer($quantity) return ' ' || $charToRepeat),' ')) || $sep)
                                                                                    else
                                                                                        $config?apply($config, ./node())
                case element(graphic) return
                    ext-html:graphic($config, ., ("tei-graphic"), @url)
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
                                                    html:link($config, ., ("tei-head8"), ., @n)
                                                else
                                                    $config?apply($config, ./node())
                case element(hi) return
                    if (@rendition) then
                        html:inline($config, ., css:get-rendition(., ("tei-hi1")), .)
                    else
                        if (not(@rendition)) then
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
                        ext-html:breakPyu($config, ., ("tei-lb1", (if (@break='no') then 'break-no' else ())), ., 'line', 'yes', if (@n) then @n else count(preceding-sibling::lb) + 1)
                    else
                        if ($parameters?break='Physical') then
                            ext-html:breakPyu($config, ., ("tei-lb2", (if (@break='no') then 'break-no' else ())), ., 'line', 'yes', if (@n) then @n else count(preceding-sibling::lb) + 1)
                        else
                            if (ancestor::lg and $parameters?break='Logical') then
                                ext-html:breakPyu($config, ., ("tei-lb3", (if (@break='no') then 'break-no' else ())), ., 'line', 'no', if (@n) then @n else count(preceding-sibling::lb) + 1)
                            else
                                if ($parameters?break='Logical') then
                                    ext-html:breakPyu($config, ., ("tei-lb4", (if (@break='no') then 'break-no' else ())), ., 'line', 'no', if (@n) then @n else count(preceding-sibling::lb) + 1)
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
                        html:list($config, ., ("tei-listBibl1", "list-group"), biblStruct)
                    else
                        if (ancestor::surrogates or ancestor::div[@type='bibliography']) then
                            html:list($config, ., ("tei-listBibl2"), .)
                        else
                            if (bibl) then
                                html:list($config, ., ("tei-listBibl3"), bibl)
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
                    if (child::choice) then
                        html:inline($config, ., ("tei-name1"), (
    if (choice/reg[@type='simplified']) then
        html:inline($config, ., ("tei-name2"), choice/reg[@type='simplified'])
    else
        (),
    html:text($config, ., ("tei-name3"), ' '),
    if (choice/reg[@type='simplified']) then
        html:inline($config, ., ("tei-name4"), choice/reg[@type='popular'])
    else
        ()
)
)
                    else
                        html:inline($config, ., ("tei-name5"), .)
                case element(note) return
                    if (parent::notesStmt and child::text()[normalize-space(.)]) then
                        html:listItem($config, ., ("tei-note1"), .)
                    else
                        if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                            (
                                html:inline($config, ., ("tei-note2", (ancestor::div/@type || '-note')), .)
                            )

                        else
                            if (not(ancestor::biblStruct) and parent::bibl) then
                                html:inline($config, ., ("tei-note3"), .)
                            else
                                if (@type='tags' and ancestor::biblStruct) then
                                    html:omit($config, ., ("tei-note4"), .)
                                else
                                    if (@type='accessed' and ancestor::biblStruct) then
                                        html:omit($config, ., ("tei-note5"), .)
                                    else
                                        if (@type='thesisType' and ancestor::biblStruct) then
                                            html:omit($config, ., ("tei-note6"), .)
                                        else
                                            if (not(@type='url') and ancestor::biblStruct) then
                                                html:omit($config, ., ("tei-note7"), .)
                                            else
                                                if (ancestor::biblStruct and @type='url') then
                                                    (
                                                        html:text($config, ., ("tei-note8"), '. URL: <'),
                                                        html:link($config, ., ("tei-note9"), ., .),
                                                        html:text($config, ., ("tei-note10"), '>')
                                                    )

                                                else
                                                    if (ancestor::biblStruct and not(preceding-sibling::*[not(@type='tags')][ends-with(.,'.')])) then
                                                        html:inline($config, ., ("tei-note11"), '. ')
                                                    else
                                                        if (ancestor::listApp) then
                                                            html:inline($config, ., ("tei-note12"), .)
                                                        else
                                                            html:inline($config, ., ("tei-note13"), .)
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
                                if (parent::div[@type='bibliography']) then
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
                                                if ($parameters?header='short') then
                                                    html:omit($config, ., ("tei-p10"), .)
                                                else
                                                    html:block($config, ., ("tei-p11"), .)
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
                    (: More than one model without predicate found for ident publisher. Choosing first one. :)
                    (
                        if (ancestor::biblStruct and preceding-sibling::pubPlace) then
                            html:text($config, ., ("tei-publisher1"), ': ')
                        else
                            (),
                        if (ancestor::biblStruct) then
                            html:inline($config, ., ("tei-publisher2"), normalize-space(.))
                        else
                            ()
                    )

                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        html:inline($config, ., ("tei-pubPlace"), .)
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
                        if (ancestor::p or ancestor::note) then
                            (: If it is inside a paragraph or a note then it is inline, otherwise it is block level :)
                            html:inline($config, ., css:get-rendition(., ("tei-quote2")), .)
                        else
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            html:block($config, ., css:get-rendition(., ("tei-quote3")), .)
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
                                if (starts-with(@target,'#EIAD')) then
                                    (: For corpus internal links (refs starts with '#'). To customize with corpus prefix (here 'EIAD') but needs declare namespace somewhere for config: :)
                                    html:link($config, ., ("tei-ref4"), ., substring-after(@target,'#') || '.xml' || "?odd=" || request:get-parameter("odd", ()))
                                else
                                    if (not(@target)) then
                                        html:inline($config, ., ("tei-ref5"), .)
                                    else
                                        html:link($config, ., ("tei-ref6"), @target, @target)
                case element(reg) return
                    if (ancestor::biblStruct and @type='popular') then
                        html:inline($config, ., ("tei-reg1"), .)
                    else
                        if (ancestor::biblStruct and @type='simplified') then
                            html:inline($config, ., ("tei-reg2"), .)
                        else
                            $config?apply($config, ./node())
                case element(relatedItem) return
                    html:inline($config, ., ("tei-relatedItem"), .)
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
                            if (@reason='omitted') then
                                html:inline($config, ., ("tei-supplied3", ('supplied')), .)
                            else
                                if (@reason='lost' and not(ancestor::seg[@type='join'])) then
                                    html:inline($config, ., ("tei-supplied4", ('supplied')), .)
                                else
                                    if (ancestor::seg[@type='join']) then
                                        (: No function found for behavior: :)
                                        $config?apply($config, ./node())
                                    else
                                        html:inline($config, ., ("tei-supplied6", ('supplied')), .)
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
        html:heading($config, ., ("tei-fileDesc4"), 'Metadata ', 3),
        ext-html:dt($config, ., ("tei-fileDesc5"), 'Support '),
        ext-html:dd($config, ., ("tei-fileDesc6"), (
    html:inline($config, ., ("tei-fileDesc7"), sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support),
    html:inline($config, ., ("tei-fileDesc8"), sourceDesc/msDesc/physDesc/decoDesc )
)
),
        ext-html:dt($config, ., ("tei-fileDesc9"), 'Text '),
        ext-html:dd($config, ., ("tei-fileDesc10"), (
    html:inline($config, ., ("tei-fileDesc11"), sourceDesc/msDesc/msContents/msItem/textLang),
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
        ext-html:dt($config, ., ("tei-fileDesc15"), 'Origin '),
        ext-html:dd($config, ., ("tei-fileDesc16"), let $finale := if (ends-with(sourceDesc/msDesc/history/origin/origPlace,'.')) then () else '. ' return
										concat(sourceDesc/msDesc/history/origin/origPlace,$finale)),
        ext-html:dt($config, ., ("tei-fileDesc17"), 'Provenance'),
        ext-html:dd($config, ., ("tei-fileDesc18"), sourceDesc/msDesc/history/provenance),
        ext-html:dt($config, ., ("tei-fileDesc19"), 'Visual Documentation'),
        ext-html:dd($config, ., ("tei-fileDesc20"), sourceDesc/msDesc/additional),
        if (notesStmt/note[text()[normalize-space(.)]]) then
            ext-html:dt($config, ., ("tei-fileDesc21"), 'Note ')
        else
            (),
        if (notesStmt/note[text()[normalize-space(.)]]) then
            ext-html:dd($config, ., ("tei-fileDesc22"), notesStmt)
        else
            (),
        if (titleStmt/editor[@role='general'] or titleStmt/editor[@role='contributor']) then
            ext-html:dt($config, ., ("tei-fileDesc23"), 'Editors ')
        else
            (),
        if (titleStmt/editor[@role='general'] or titleStmt/editor[@role='contributor']) then
            (: See elementSpec/@ident='editor' for details. :)
            ext-html:dd($config, ., ("tei-fileDesc24"), if (titleStmt/editor[@role='general'] and titleStmt/editor[@role='contributor']) then
    (
        html:inline($config, ., ("tei-fileDesc25"), titleStmt/editor[@role='general']),
        html:inline($config, ., ("tei-fileDesc26", "textInline"), ', with contributions by '),
        html:inline($config, ., ("tei-fileDesc27"), titleStmt/editor[@role='contributor']),
        html:inline($config, ., ("tei-fileDesc28", "textInline"), '. ')
    )

else
    if (titleStmt/editor[@role='general'] and not(titleStmt/editor[@role='contributor'])) then
        (
            html:inline($config, ., ("tei-fileDesc29"), titleStmt/editor[@role='general']),
            html:inline($config, ., ("tei-fileDesc30", "textInline"), '. ')
        )

    else
        if (titleStmt/editor[@role='contributor'] and not(titleStmt/editor[@role='general'])) then
            (
                html:inline($config, ., ("tei-fileDesc31"), titleStmt/editor[@role='contributor'])
            )

        else
            html:inline($config, ., ("tei-fileDesc32", "textInline"), '. '))
        else
            ()
    )
,
    if (../..//div[@type='bibliography']/p[text()[normalize-space(.)]]) then
        (
            ext-html:dt($config, ., ("tei-fileDesc33"), 'Publication history'),
            ext-html:dd($config, ., ("tei-fileDesc34"), ../..//div[@type='bibliography']/p)
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
                        html:block($config, ., ("tei-teiHeader3"), .)
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
                    html:block($config, ., ("tei-biblStruct1"), (
    (
        html:inline($config, ., ("tei-biblStruct2"), if (.//title[@type='short']) then
    ext-html:bibl-link($config, ., ("tei-biblStruct3"), .//title[@type='short'], @xml:id)
else
    (
        if (.//author/surname) then
            html:inline($config, ., ("tei-biblStruct4"), .//author/surname)
        else
            if (.//author/name) then
                html:inline($config, ., ("tei-biblStruct5"), .//author/name)
            else
                $config?apply($config, ./node()),
        html:text($config, ., ("tei-biblStruct6"), ' '),
        html:inline($config, ., ("tei-biblStruct7"), monogr/imprint/date)
    )
)
    )
,
    (
        if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle') then
            (
                html:inline($config, ., ("tei-biblStruct8"), analytic/author),
                if (analytic/title[@level='a']) then
                    (
                        html:inline($config, ., ("tei-biblStruct9"), analytic/title[@level='a']),
                        html:text($config, ., ("tei-biblStruct10"), ', ')
                    )

                else
                    if (not(analytic/title[@level='a']) and relatedItem[@type='reviewOf']) then
                        (
                            (: When it is a review of another bibliographic entry: so there's is no analytic/title[@level='a']. :)
                            html:link($config, ., ("tei-biblStruct11"), relatedItem/ref, ()),
                            html:text($config, ., ("tei-biblStruct12"), ', ')
                        )

                    else
                        $config?apply($config, ./node()),
                if (@type='bookSection' or @type='encyclopediaArticle') then
                    (
                        if (@type='bookSection' or @type='encyclopediaArticle') then
                            html:text($config, ., ("tei-biblStruct13"), 'in ')
                        else
                            (),
                        html:inline($config, ., ("tei-biblStruct14"), monogr/title[@level='m']),
                        html:text($config, ., ("tei-biblStruct15"), ', '),
                        if (monogr/author) then
                            html:text($config, ., ("tei-biblStruct16"), 'by ')
                        else
                            (),
                        html:inline($config, ., ("tei-biblStruct17"), monogr/author),
                        if (monogr/editor) then
                            html:inline($config, ., ("tei-biblStruct18"), monogr/editor)
                        else
                            ()
                    )

                else
                    (),
                if (@type='journalArticle') then
                    (
                        html:inline($config, ., ("tei-biblStruct19"), monogr/title[@level='j']),
                        html:text($config, ., ("tei-biblStruct20"), ', ')
                    )

                else
                    (),
                if (.//series) then
                    html:inline($config, ., ("tei-biblStruct21"), series)
                else
                    (),
                if (.//monogr/imprint) then
                    html:inline($config, ., ("tei-biblStruct22"), monogr/imprint)
                else
                    ()
            )

        else
            if (@type='book' or @type='manuscript' or @type='thesis' or @type='report') then
                (
                    html:inline($config, ., ("tei-biblStruct23"), monogr/author),
                    html:inline($config, ., ("tei-biblStruct24"), monogr/editor),
                    html:inline($config, ., ("tei-biblStruct25"), monogr/respStmt),
                    if (@type='book' or @type='thesis' or @type='report') then
                        html:inline($config, ., ("tei-biblStruct26"), monogr/title[@level='m'])
                    else
                        (),
                    if (@type='manuscript') then
                        html:inline($config, ., ("tei-biblStruct27"), monogr/title[@level='u'])
                    else
                        (),
                    html:text($config, ., ("tei-biblStruct28"), ', '),
                    if (.//series) then
                        html:inline($config, ., ("tei-biblStruct29"), series)
                    else
                        (),
                    if (.//series/biblScope[@unit='volume']) then
                        html:inline($config, ., ("tei-biblStruct30"), biblScope[@unit='volume'])
                    else
                        (),
                    if (monogr/imprint) then
                        (
                            if (@type='manuscript') then
                                html:text($config, ., ("tei-biblStruct31"), ' manuscript ')
                            else
                                (),
                            if (@type='thesis') then
                                html:text($config, ., ("tei-biblStruct32"), ' unpublished Ph.D., ')
                            else
                                (),
                            html:inline($config, ., ("tei-biblStruct33"), monogr/imprint)
                        )

                    else
                        (),
                    if (note) then
                        (
                            html:inline($config, ., ("tei-biblStruct34"), note)
                        )

                    else
                        ()
                )

            else
                if (@type='journal') then
                    (
                        html:inline($config, ., ("tei-biblStruct35"), monogr/title[@level='j']),
                        html:text($config, ., ("tei-biblStruct36"), ', '),
                        if (monogr/imprint) then
                            (
                                html:inline($config, ., ("tei-biblStruct37"), monogr/imprint)
                            )

                        else
                            (),
                        if (note) then
                            (
                                html:inline($config, ., ("tei-biblStruct38"), note)
                            )

                        else
                            ()
                    )

                else
                    if (@type='webpage') then
                        (
                            html:inline($config, ., ("tei-biblStruct39"), monogr/author),
                            html:inline($config, ., ("tei-biblStruct40"), monogr/title[not(@type='short')]),
                            html:text($config, ., ("tei-biblStruct41"), ', '),
                            if (monogr/idno[@type='url'] or note[@type='url']) then
                                (
                                    html:text($config, ., ("tei-biblStruct42"), 'retrieved on '),
                                    html:inline($config, ., ("tei-biblStruct43"), monogr/note[@type='accessed']/date),
                                    html:text($config, ., ("tei-biblStruct44"), ' from <'),
                                    if (monogr/idno[@type='url']) then
                                        html:inline($config, ., ("tei-biblStruct45"), */idno)
                                    else
                                        if (note[@type='url']) then
                                            html:inline($config, ., ("tei-biblStruct46"), note[@type='url'])
                                        else
                                            $config?apply($config, ./node()),
                                    html:text($config, ., ("tei-biblStruct47"), '>')
                                )

                            else
                                (),
                            if (note) then
                                (
                                    if (note) then
                                        html:inline($config, ., ("tei-biblStruct48"), note)
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
                html:inline($config, ., ("tei-biblStruct49"), */idno[@type='url'])
            else
                ()
        )

    else
        (),
    if (.//*[position()=last()][not(local-name()='note')][not(ends-with(normalize-space(text()),'.'))]) then
        html:text($config, ., ("tei-biblStruct50"), '.')
    else
        (),
    if (.//note[position()=last()][@type='thesisType' or @type='url' or @type='tags']) then
        html:text($config, ., ("tei-biblStruct51"), '.')
    else
        ()
)
)
                case element(dimensions) return
                    if (ancestor::support) then
                        (
                            html:inline($config, ., ("tei-dimensions1"), .),
                            if (@unit) then
                                html:inline($config, ., ("tei-dimensions2"), @unit)
                            else
                                ()
                        )

                    else
                        if (ancestor::layoutDesc) then
                            (
                                if (not(preceding-sibling::dimensions)) then
                                    html:text($config, ., ("tei-dimensions3"), ' Inscribed area: ')
                                else
                                    (),
                                html:inline($config, ., ("tei-dimensions4"), .),
                                if (following-sibling::dimensions) then
                                    html:text($config, ., ("tei-dimensions5"), ';')
                                else
                                    (),
                                if (@unit) then
                                    html:inline($config, ., ("tei-dimensions6"), @unit)
                                else
                                    (),
                                if (@extent) then
                                    html:inline($config, ., ("tei-dimensions7"), @extent)
                                else
                                    ()
                            )

                        else
                            html:inline($config, ., ("tei-dimensions8"), .)
                case element(height) return
                    if (parent::dimensions and @precision='unknown') then
                        html:omit($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and following-sibling::*) then
                            html:inline($config, ., ("tei-height2"), if (@extent) then concat('(',@extent,') ',.) else .)
                        else
                            if (parent::dimensions and following-sibling::*) then
                                html:inline($config, ., ("tei-height3"), if (@extent) then concat('(',@extent,') ',.) else .)
                            else
                                if (parent::dimensions and not(following-sibling::*)) then
                                    html:inline($config, ., ("tei-height4"), if (@extent) then concat('(',@extent,') ',.) else .)
                                else
                                    if (not(ancestor::layoutDesc or ancestor::supportDesc)) then
                                        html:inline($config, ., ("tei-height5"), .)
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
                    html:inline($config, ., ("tei-handNote"), .)
                case element(idno) return
                    if (ancestor::biblStruct[@type='webpage'] and @type='url') then
                        html:link($config, ., ("tei-idno1"), ., ())
                    else
                        if (ancestor::biblStruct and @type='url') then
                            (
                                html:text($config, ., ("tei-idno2"), '. URL: <'),
                                html:link($config, ., ("tei-idno3"), ., ()),
                                html:text($config, ., ("tei-idno4"), '>')
                            )

                        else
                            if ($parameters?header='short') then
                                html:inline($config, ., ("tei-idno5"), .)
                            else
                                if (ancestor::publicationStmt) then
                                    html:inline($config, ., ("tei-idno6"), .)
                                else
                                    html:inline($config, ., ("tei-idno7"), .)
                case element(imprint) return
                    if (ancestor::biblStruct[@type='book' or @type='journal' or @type='manuscript' or @type='report' or @type='thesis']) then
                        (
                            if (pubPlace) then
                                html:inline($config, ., ("tei-imprint1"), pubPlace)
                            else
                                (),
                            if (publisher) then
                                html:inline($config, ., ("tei-imprint2"), publisher)
                            else
                                (),
                            if (date and (pubPlace or publisher)) then
                                html:text($config, ., ("tei-imprint3"), ', ')
                            else
                                (),
                            if (date) then
                                html:inline($config, ., ("tei-imprint4"), date)
                            else
                                (),
                            if (note) then
                                html:inline($config, ., ("tei-imprint5"), note)
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct[@type='journalArticle']) then
                            (
                                if (biblScope[@unit='volume']) then
                                    html:inline($config, ., ("tei-imprint6"), biblScope[@unit='volume'])
                                else
                                    (),
                                if (following-sibling::*[1][@unit='issue']) then
                                    html:text($config, ., ("tei-imprint7"), ', ')
                                else
                                    (),
                                if (biblScope[@unit='issue']) then
                                    html:inline($config, ., ("tei-imprint8"), biblScope[@unit='issue'])
                                else
                                    (),
                                if (date) then
                                    html:inline($config, ., ("tei-imprint9"), date)
                                else
                                    (),
                                if (biblScope[@unit='page']) then
                                    html:inline($config, ., ("tei-imprint10"), biblScope[@unit='page'])
                                else
                                    (),
                                if (note) then
                                    html:inline($config, ., ("tei-imprint11"), note)
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct[@type='encyclopediaArticle'] or ancestor::biblStruct[@type='bookSection']) then
                                (
                                    if (biblScope[@unit='volume']) then
                                        html:inline($config, ., ("tei-imprint12"), biblScope[@unit='volume'])
                                    else
                                        (),
                                    if (pubPlace) then
                                        html:inline($config, ., ("tei-imprint13"), pubPlace)
                                    else
                                        (),
                                    if (publisher) then
                                        html:inline($config, ., ("tei-imprint14"), publisher)
                                    else
                                        (),
                                    if (date) then
                                        html:text($config, ., ("tei-imprint15"), ', ')
                                    else
                                        (),
                                    if (date) then
                                        html:inline($config, ., ("tei-imprint16"), date)
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        html:inline($config, ., ("tei-imprint17"), biblScope[@unit='page'])
                                    else
                                        (),
                                    if (note) then
                                        html:inline($config, ., ("tei-imprint18"), note)
                                    else
                                        ()
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
                                (: No function found for behavior: bibl-initials-for-ref :)
                                $config?apply($config, ./node())
                            else
                                (),
                            if (starts-with(@resp,'eiad-part:')) then
                                html:inline($config, ., ("tei-lem5"), substring-after(@resp,'eiad-part:'))
                            else
                                (),
                            if (starts-with(@resp,'#')) then
                                html:link($config, ., ("tei-lem6"), substring-after(@resp,'#'),  "?odd=" || request:get-parameter("odd", ()) || "&amp;view=" || request:get-parameter("view", ()) || "&amp;id=" || @resp )
                            else
                                (),
                            if (not(following-sibling::*[1][local-name()='rdg']) and (@source or @rend)) then
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
                        ext-html:list-app($config, ., ("tei-listApp2"), .)
                    else
                        (: More than one model without predicate found for ident listApp. Choosing first one. :)
                        (
                            if (parent::div[@type='apparatus']) then
                                ext-html:list-app($config, ., ("tei-listApp1"), .)
                            else
                                ()
                        )

                case element(msDesc) return
                    html:inline($config, ., ("tei-msDesc"), .)
                case element(notesStmt) return
                    html:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    html:inline($config, ., ("tei-objectDesc"), .)
                case element(orgName) return
                    html:inline($config, ., ("tei-orgName"), .)
                case element(persName) return
                    if (ancestor::div[@type]) then
                        ext-html:link2($config, ., ("tei-persName"), ., ())
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
                        ext-html:refbibl($config, ., ("tei-ptr1"), @target, @target)
                    else
                        if (not(parent::bibl) and not(text()) and @target[starts-with(.,'#')]) then
                            (: No function found for behavior: resolve-pointer :)
                            $config?apply($config, ./node())
                        else
                            if (not(text())) then
                                html:link($config, ., ("tei-ptr3"), @target, ())
                            else
                                $config?apply($config, ./node())
                case element(rdg) return
                    if (ancestor::listApp) then
                        (
                            html:inline($config, ., ("tei-rdg1"), .),
                            if (@source and ancestor::listApp) then
                                ext-html:refbibl($config, ., ("tei-rdg2", "author-initials"), @source, .)
                            else
                                ()
                        )

                    else
                        $config?apply($config, ./node())
                case element(respStmt) return
                    if (ancestor::titleStmt and count(child::resp[@type='editor'] >= 1)) then
                        html:inline($config, ., ("tei-respStmt1"), persName)
                    else
                        html:inline($config, ., ("tei-respStmt2"), .)
                case element(series) return
                    if (ancestor::biblStruct) then
                        html:inline($config, ., ("tei-series1"), (
    html:inline($config, ., ("tei-series2"), title[@level='s']),
    html:inline($config, ., ("tei-series3"), biblScope)
)
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
                                    $config?apply($config, ./node())
                case element(supportDesc) return
                    html:inline($config, ., ("tei-supportDesc"), .)
                case element(surrogates) return
                    html:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    html:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    html:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' return concat(normalize-space(.),$finale) )
                case element(titleStmt) return
                    if ($parameters?header='short') then
                        (
                            html:link($config, ., ("tei-titleStmt3"), title[1], $parameters?doc)
                        )

                    else
                        html:block($config, ., ("tei-titleStmt4"), .)
                case element(facsimile) return
                    if ($parameters?modal='true') then
                        ext-html:image-modals($config, ., ("tei-facsimile1"), graphic)
                    else
                        (
                            html:heading($config, ., ("tei-facsimile2"), 'Facsimiles ', 3),
                            ext-html:images($config, ., ("tei-facsimile3"), graphic)
                        )

                case element(person) return
                    (
                        ext-html:dt($config, ., ("tei-person1"), 'Reconstructed spellings '),
                        ext-html:dd($config, ., ("tei-person2"), persName),
                        ext-html:dt($config, ., ("tei-person3"), 'Attested spellings ')
                    )

                case element(placeName) return
                    if (ancestor::div[@type]) then
                        ext-html:link2($config, ., ("tei-placeName"), ., ())
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

