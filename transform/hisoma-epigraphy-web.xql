(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/SAI/resources/odd/hisoma-epigraphy.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/hisoma-epigraphy/web";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace xi='http://www.w3.org/2001/XInclude';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["web"],
                "odd": "/db/apps/SAI/resources/odd/hisoma-epigraphy.odd",
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
                        (: No function found for behavior: xml-tab :)
                        $config?apply($config, ./node())
                    else
                        html:block($config, ., ("tei-ab2"), .)
                case element(ab) return
                    html:block($config, ., ("tei-ab"), .)
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
                    if (ancestor::teiHeader) then
                        html:block($config, ., ("tei-author1"), .)
                    else
                        if (ancestor::biblStruct) then
                            html:inline($config, ., ("tei-author2"), if (surname or forename) then
    (
        html:text($config, ., ("tei-author3"), surname),
        html:text($config, ., ("tei-author4"), ', '),
        html:text($config, ., ("tei-author5"), forename)
    )

else
    if (name) then
        html:text($config, ., ("tei-author6"), name)
    else
        $config?apply($config, ./node()))
                        else
                            $config?apply($config, ./node())
                case element(back) return
                    html:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl[@type='photo']) then
                        (: No function found for behavior: listItemImage :)
                        $config?apply($config, ./node())
                    else
                        if (parent::listBibl[@type='estampage']) then
                            (: No function found for behavior: listItemImage :)
                            $config?apply($config, ./node())
                        else
                            if (parent::listBibl and ancestor::div[@type='bibliography']) then
                                (: No function found for behavior: listItemImage :)
                                $config?apply($config, ./node())
                            else
                                if (parent::listBibl) then
                                    html:listItem($config, ., ("tei-bibl4"), .)
                                else
                                    html:inline($config, ., ("tei-bibl5", "bibl"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct and @unit='series') then
                        (
                            if (@unit='series') then
                                html:inline($config, ., ("tei-biblScope1"), .)
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct and @unit='volume') then
                            (
                                if (monogr/author or monogr/editor) then
                                    html:text($config, ., ("tei-biblScope2"), ', ')
                                else
                                    (),
                                if (@unit='volume') then
                                    html:inline($config, ., ("tei-biblScope3"), .)
                                else
                                    (),
                                if (@unit='volume') then
                                    html:text($config, ., ("tei-biblScope4"), ', ')
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct and @unit='page') then
                                (
                                    if (@unit='page') then
                                        html:inline($config, ., ("tei-biblScope5"), .)
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
                    if (child::quote and child::bibl) then
                        (: Insert citation :)
                        html:cit($config, ., ("tei-cit"), ., ())
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
                    if (@when) then
                        (: desactive le comportement alternate de tei_simplePrint :)
                        html:inline($config, ., ("tei-date3"), .)
                    else
                        if (text()) then
                            html:inline($config, ., ("tei-date4"), .)
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
                    if (ancestor::TEI[@type='general-biblio']) then
                        html:section($config, ., ("tei-div1", (bibliography-top)), .)
                    else
                        if (@type='bibliography') then
                            (
                                html:heading($config, ., ("tei-div2"), 'Secondary bibliography', 3),
                                html:section($config, ., ("tei-div3", "bibliography-secondary"), listBibl)
                            )

                        else
                            if (not((@type='textpart') or (@type='apparatus'))) then
                                (
                                    html:heading($config, ., ("tei-div4", (@type)), concat(upper-case(substring(@type,1,1)),substring(@type,2)), 3),
                                    html:section($config, ., ("tei-div5", (@type)), .)
                                )

                            else
                                if (@type='apparatus') then
                                    (
                                        html:section($config, ., ("tei-div6", (@type)), .)
                                    )

                                else
                                    if (@type='edition') then
                                        (
                                            html:section($config, ., ("tei-div7", (@type)), .)
                                        )

                                    else
                                        if (@type='textpart') then
                                            html:block($config, ., ("tei-div8"), .)
                                        else
                                            html:block($config, ., ("tei-div9"), .)
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
                    if (ancestor::teiHeader) then
                        html:block($config, ., ("tei-editor1"), .)
                    else
                        if (ancestor::biblStruct) then
                            html:inline($config, ., ("tei-editor2"), if (surname or forename) then
    (
        html:text($config, ., ("tei-editor3"), surname),
        html:text($config, ., ("tei-editor4"), ', '),
        html:text($config, ., ("tei-editor5"), forename)
    )

else
    if (name) then
        html:text($config, ., ("tei-editor6"), name)
    else
        $config?apply($config, ./node()))
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
                        (: Changed to not show a blue border around the figure :)
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
                    if (ancestor::p or ancestor::ab) then
                        html:inline($config, ., ("tei-fw1"), .)
                    else
                        html:block($config, ., ("tei-fw2"), .)
                case element(g) return
                    if (@type) then
                        html:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if ((@reason='lost' and @unit='line' and @quantity=1) and not(child::certainty)) then
                        html:inline($config, ., ("tei-gap1", "italic"), .)
                    else
                        if ((@reason='lost' and @unit='line' and child::certainty[@locus='name']) and not(@quantity=1)) then
                            html:inline($config, ., ("tei-gap2", "italic"), .)
                        else
                            if ((@reason='lost' and @unit='line' and not(@quantity=1)) and not(child::certainty[@locus='name'])) then
                                html:inline($config, ., ("tei-gap3", "italic"), .)
                            else
                                if (@reason='lost' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                    html:inline($config, ., ("tei-gap4", "italic"), .)
                                else
                                    if ((@reason='illegible' and @unit='line' and @quantity=1) and not(child::certainty)) then
                                        html:inline($config, ., ("tei-gap5", "italic"), .)
                                    else
                                        if ((@reason='illegible' and @unit='line' and child::certainty[@locus='name']) and not(@quantity=1)) then
                                            html:inline($config, ., ("tei-gap6", "italic"), .)
                                        else
                                            if ((@reason='illegible' and @unit='line' and not(@quantity=1)) and not(child::certainty[@locus='name'])) then
                                                html:inline($config, ., ("tei-gap7", "italic"), .)
                                            else
                                                if (@reason='illegible' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                                    html:inline($config, ., ("tei-gap8", "italic"), .)
                                                else
                                                    if (@reason='illegible' and @unit='character' and @quantity) then
                                                        (: No function found for behavior: repeat-string :)
                                                        $config?apply($config, ./node())
                                                    else
                                                        if (@reason='lost' and @unit='character' and @quantity) then
                                                            (: No function found for behavior: repeat-string :)
                                                            $config?apply($config, ./node())
                                                        else
                                                            $config?apply($config, ./node())
                case element(graphic) return
                    if (parent::facsimile and $parameters?teiHeader-type='epidoc') then
                        html:link($config, ., ("tei-graphic1"), ., ())
                    else
                        html:graphic($config, ., ("tei-graphic2"), ., @url, (), (), 0.5, desc)
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
                                        if (parent::div) then
                                            html:heading($config, ., ("tei-head6"), ., count(ancestor::div))
                                        else
                                            html:block($config, ., ("tei-head7"), .)
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
                    if ($parameters?break='Logical') then
                        (: No function found for behavior: breakPyu :)
                        $config?apply($config, ./node())
                    else
                        if ($parameters?break='Physical') then
                            (: No function found for behavior: breakPyu :)
                            $config?apply($config, ./node())
                        else
                            html:block($config, ., ("tei-l3"), .)
                case element(label) return
                    html:inline($config, ., ("tei-label"), .)
                case element(lb) return
                    if ($parameters?break='Physical') then
                        (: No function found for behavior: breakPyu :)
                        $config?apply($config, ./node())
                    else
                        if ($parameters?break='Logical') then
                            (: No function found for behavior: breakPyu :)
                            $config?apply($config, ./node())
                        else
                            html:inline($config, ., ("tei-lb3", "lineNumber"), (
    html:text($config, ., ("tei-lb4"), ' ('),
    html:inline($config, ., ("tei-lb5"), if (@n) then @n else count(preceding-sibling::lb) + 1),
    html:text($config, ., ("tei-lb6"), ') ')
)
)
                case element(lg) return
                    if (@met or @n) then
                        (
                            html:inline($config, ., ("tei-lg1", "verse-number"), @n),
                            html:block($config, ., ("tei-lg2", "verse-meter"), @met),
                            html:inline($config, ., ("tei-lg3", "verse-block"), .)
                        )

                    else
                        html:block($config, ., ("tei-lg4", "block"), .)
                case element(list) return
                    if (@rendition) then
                        html:list($config, ., css:get-rendition(., ("tei-list1")), item)
                    else
                        if (not(@rendition)) then
                            html:list($config, ., ("tei-list2"), item)
                        else
                            $config?apply($config, ./node())
                case element(listBibl) return
                    if (ancestor::div[@type='genBibliography'] and child::biblStruct) then
                        (: No function found for behavior: xsl-biblio :)
                        $config?apply($config, ./node())
                    else
                        if (child::biblStruct) then
                            html:list($config, ., ("tei-listBibl2", "list-group"), biblStruct)
                        else
                            if (ancestor::surrogates or ancestor::div[@type='bibliography']) then
                                (: No function found for behavior: :)
                                $config?apply($config, ./node())
                            else
                                if (bibl) then
                                    html:list($config, ., ("tei-listBibl4"), bibl)
                                else
                                    $config?apply($config, ./node())
                case element(measure) return
                    html:inline($config, ., ("tei-measure"), .)
                case element(milestone) return
                    if (@unit='fragment') then
                        (: No function found for behavior: milestone :)
                        $config?apply($config, ./node())
                    else
                        if (@unit='face') then
                            (: No function found for behavior: milestone :)
                            $config?apply($config, ./node())
                        else
                            html:inline($config, ., ("tei-milestone3"), .)
                case element(name) return
                    html:inline($config, ., ("tei-name"), .)
                case element(note) return
                    if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                        html:inline($config, ., ("tei-note1"), .)
                    else
                        if (ancestor::teiHeader and text()[normalize-space(.)]) then
                            html:listItem($config, ., ("tei-note2"), .)
                        else
                            if (@type='tags' and ancestor::biblStruct) then
                                html:omit($config, ., ("tei-note3"), .)
                            else
                                if (@type='accessed' and ancestor::biblStruct) then
                                    html:omit($config, ., ("tei-note4"), .)
                                else
                                    if (ancestor::biblStruct) then
                                        (
                                            html:inline($config, ., ("tei-note5"), ', '),
                                            (: No function found for behavior: :)
                                            $config?apply($config, ./node())
                                        )

                                    else
                                        html:inline($config, ., ("tei-note7"), .)
                case element(num) return
                    html:inline($config, ., ("tei-num"), .)
                case element(opener) return
                    html:block($config, ., ("tei-opener"), .)
                case element(orig) return
                    html:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (parent::div[@type='bibliography']) then
                        html:inline($config, ., ("tei-p1"), .)
                    else
                        if (parent::support) then
                            html:inline($config, ., ("tei-p2"), .)
                        else
                            if (parent::provenance) then
                                html:inline($config, ., ("tei-p3"), .)
                            else
                                html:block($config, ., ("tei-p4"), .)
                case element(pb) return
                    html:break($config, ., css:get-rendition(., ("tei-pb")), ., 'page', (concat(if(@n) then concat(@n,' ') else '',if(@facs) then                   concat('@',@facs) else '')))
                case element(pc) return
                    html:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    html:block($config, ., ("tei-postscript"), .)
                case element(publisher) return
                    (: More than one model without predicate found for ident publisher. Choosing first one. :)
                    (
                        if (ancestor::biblStruct) then
                            html:text($config, ., ("tei-publisher1"), ': ')
                        else
                            (),
                        if (ancestor::biblStruct) then
                            html:inline($config, ., ("tei-publisher2"), .)
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
                    if (ancestor::p or ancestor::note) then
                        (: If it is inside a paragraph or a note then it is inline, otherwise it is block level :)
                        html:inline($config, ., css:get-rendition(., ("tei-quote1")), .)
                    else
                        (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                        html:block($config, ., css:get-rendition(., ("tei-quote2")), .)
                case element(ref) return
                    if (not(@target)) then
                        html:inline($config, ., ("tei-ref1"), .)
                    else
                        if (not(text())) then
                            html:link($config, ., ("tei-ref2"), @target, @target)
                        else
                            html:link($config, ., ("tei-ref3"), .,  if (starts-with(@target, "#")) then request:get-parameter("doc", ()) || "?odd=" || request:get-parameter("odd", ()) || "&amp;view=" || request:get-parameter("view", ()) || "&amp;id=" ||
                            substring-after(@target, '#') else @target )
                case element(reg) return
                    html:inline($config, ., ("tei-reg"), .)
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
                        html:inline($config, ., ("tei-seg1"), .)
                    else
                        if (@type='graphemic') then
                            html:inline($config, ., ("tei-seg2"), .)
                        else
                            if (@type='phonetic') then
                                html:inline($config, ., ("tei-seg3"), .)
                            else
                                if (@type='phonemic') then
                                    html:inline($config, ., ("tei-seg4"), .)
                                else
                                    if (@type='t1') then
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
                            html:inline($config, ., ("tei-supplied2"), .)
                        else
                            html:inline($config, ., ("tei-supplied3"), .)
                case element(supplied) return
                    html:inline($config, ., ("tei-supplied"), .)
                case element(table) return
                    html:table($config, ., ("tei-table"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            html:inline($config, ., ("tei-fileDesc1", "header-short"), publicationStmt),
                            html:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        if (ancestor::TEI[@type='general-biblio']) then
                            html:paragraph($config, ., ("tei-fileDesc3"), sourceDesc)
                        else
                            if ($parameters?teiHeader-type='epidoc') then
                                (: No function found for behavior: dl :)
                                $config?apply($config, ./node())
                            else
                                $config?apply($config, ./node())
                case element(profileDesc) return
                    html:omit($config, ., ("tei-profileDesc"), .)
                case element(revisionDesc) return
                    if ($parameters?teiHeader-type='epidoc') then
                        html:omit($config, ., ("tei-revisionDesc2"), .)
                    else
                        (
                            html:block($config, ., ("tei-revisionDesc1"), concat('Last modified on: ',change[position()=last()]/@when))
                        )

                case element(encodingDesc) return
                    html:omit($config, ., ("tei-encodingDesc"), .)
                case element(teiHeader) return
                    if ($parameters?header='short') then
                        html:block($config, ., ("tei-teiHeader3"), .)
                    else
                        if ($parameters?teiHeader-type='epidoc') then
                            html:block($config, ., ("tei-teiHeader4"), .)
                        else
                            $config?apply($config, ./node())
                case element(TEI) return
                    html:document($config, ., ("tei-TEI"), .)
                case element(text) return
                    html:body($config, ., ("tei-text"), .)
                case element(time) return
                    html:inline($config, ., ("tei-time"), .)
                case element(title) return
                    if ($parameters?header='short') then
                        html:inline($config, ., ("tei-title1"), .)
                    else
                        if (parent::titleStmt/parent::fileDesc) then
                            (
                                if (preceding-sibling::title) then
                                    html:text($config, ., ("tei-title2"), ' — ')
                                else
                                    (),
                                html:inline($config, ., ("tei-title3"), .)
                            )

                        else
                            if ((@level='a' or @level='s') and ancestor::biblStruct) then
                                html:inline($config, ., ("tei-title4"), .)
                            else
                                if ((@level='j' or @level='m')  and ancestor::biblStruct) then
                                    html:inline($config, ., ("tei-title5"), .)
                                else
                                    if (not(@level) and parent::bibl) then
                                        html:inline($config, ., ("tei-title6"), .)
                                    else
                                        if (@type='short' and ancestor::biblStruct) then
                                            html:inline($config, ., ("tei-title7", "vedette"), .)
                                        else
                                            html:inline($config, ., ("tei-title8"), .)
                case element(titlePage) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    html:block($config, ., ("tei-trailer"), .)
                case element(unclear) return
                    html:inline($config, ., ("tei-unclear"), .)
                case element(w) return
                    html:inline($config, ., ("tei-w"), .)
                case element(titleStmt) return
                    if ($parameters?header='short') then
                        (
                            html:link($config, ., ("tei-titleStmt3"), title[1], $parameters?doc),
                            html:block($config, ., ("tei-titleStmt4"), subsequence(title, 2)),
                            html:block($config, ., ("tei-titleStmt5"), author)
                        )

                    else
                        html:block($config, ., ("tei-titleStmt6"), .)
                case element(publicationStmt) return
                    if ($parameters?header='short') then
                        html:inline($config, ., ("tei-publicationStmt"), .)
                    else
                        $config?apply($config, ./node())
                case element(licence) return
                    html:omit($config, ., ("tei-licence"), .)
                case element(edition) return
                    if (ancestor::teiHeader) then
                        html:block($config, ., ("tei-edition"), .)
                    else
                        $config?apply($config, ./node())
                case element(additional) return
                    if ($parameters?teiHeader-type='epidoc') then
                        html:block($config, ., ("tei-additional"), .)
                    else
                        $config?apply($config, ./node())
                case element(app) return
                    if (ancestor::div[@type='edition']) then
                        (
                            if (lem) then
                                html:inline($config, ., ("tei-app1"), lem)
                            else
                                (),
                            (: No function found for behavior: popover :)
                            $config?apply($config, ./node())
                        )

                    else
                        if (ancestor::listApp) then
                            (: No function found for behavior: listItem-app :)
                            $config?apply($config, ./node())
                        else
                            $config?apply($config, ./node())
                case element(authority) return
                    html:omit($config, ., ("tei-authority"), .)
                case element(biblStruct) return
                    if (parent::listBibl) then
                        html:listItem($config, ., ("tei-biblStruct1"), (
    html:block($config, ., ("tei-biblStruct2"), (
    if (./@type) then
        html:inline($config, ., ("tei-biblStruct3"), @type)
    else
        (),
    if (./@xml:id) then
        html:inline($config, ., ("tei-biblStruct4"), @xml:id)
    else
        ()
)
),
    (
        html:block($config, ., ("tei-biblStruct5"), if (.//title[@type='short']) then
    html:inline($config, ., ("tei-biblStruct6"), .//title[@type='short'])
else
    (
        if (.//author/surname) then
            html:text($config, ., ("tei-biblStruct7"), .//author/surname)
        else
            if (.//author/name) then
                html:text($config, ., ("tei-biblStruct8"), .//author/name)
            else
                $config?apply($config, ./node()),
        html:text($config, ., ("tei-biblStruct9"), ' '),
        html:inline($config, ., ("tei-biblStruct10"), monogr/imprint/date)
    )
)
    )
,
    (
        if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle') then
            (
                html:inline($config, ., ("tei-biblStruct11"), analytic/author),
                html:text($config, ., ("tei-biblStruct12"), ', '),
                html:inline($config, ., ("tei-biblStruct13"), analytic/title[@level='a']),
                html:text($config, ., ("tei-biblStruct14"), ', '),
                if (@type='bookSection' or @type='encyclopediaArticle') then
                    (
                        if (@type='bookSection' or @type='encyclopediaArticle') then
                            html:text($config, ., ("tei-biblStruct15"), 'in ')
                        else
                            (),
                        html:inline($config, ., ("tei-biblStruct16"), monogr/title[@level='m']),
                        html:text($config, ., ("tei-biblStruct17"), ', '),
                        if (monogr/author) then
                            html:text($config, ., ("tei-biblStruct18"), 'by ')
                        else
                            (),
                        html:inline($config, ., ("tei-biblStruct19"), monogr/author),
                        if (monogr/editor) then
                            html:text($config, ., ("tei-biblStruct20"), 'edited by ')
                        else
                            (),
                        html:inline($config, ., ("tei-biblStruct21"), monogr/editor)
                    )

                else
                    (),
                if (@type='journalArticle') then
                    (
                        html:inline($config, ., ("tei-biblStruct22"), monogr/title[@level='j']),
                        html:text($config, ., ("tei-biblStruct23"), ', ')
                    )

                else
                    (),
                if (.//series) then
                    html:inline($config, ., ("tei-biblStruct24"), series)
                else
                    (),
                if (.//monogr/imprint) then
                    html:inline($config, ., ("tei-biblStruct25"), monogr/imprint)
                else
                    (),
                if (.//note) then
                    (
                        if (./note) then
                            html:inline($config, ., ("tei-biblStruct26"), ./note)
                        else
                            (),
                        if (.//imprint/note) then
                            html:inline($config, ., ("tei-biblStruct27"), ./note)
                        else
                            (),
                        if (not(ends-with(.//note,'.'))) then
                            html:inline($config, ., ("tei-biblStruct28"), '.')
                        else
                            ()
                    )

                else
                    ()
            )

        else
            if (@type='book') then
                (
                    html:inline($config, ., ("tei-biblStruct29"), monogr/author),
                    html:text($config, ., ("tei-biblStruct30"), ', '),
                    html:inline($config, ., ("tei-biblStruct31"), monogr/title[@level='m']),
                    html:text($config, ., ("tei-biblStruct32"), ', '),
                    if (monogr/imprint) then
                        (
                            html:inline($config, ., ("tei-biblStruct33"), monogr/imprint)
                        )

                    else
                        (),
                    if (note) then
                        (
                            html:inline($config, ., ("tei-biblStruct34"), note),
                            if (not(ends-with(note,'.'))) then
                                html:inline($config, ., ("tei-biblStruct35"), '.')
                            else
                                ()
                        )

                    else
                        ()
                )

            else
                $config?apply($config, ./node())
    )

)
)
                    else
                        $config?apply($config, ./node())
                case element(dimensions) return
                    (
                        if (ancestor::support) then
                            html:inline($config, ., ("tei-dimensions1"), .)
                        else
                            (),
                        if (@unit) then
                            html:inline($config, ., ("tei-dimensions2"), @unit)
                        else
                            ()
                    )

                case element(height) return
                    if (parent::dimensions and following-sibling::*) then
                        html:inline($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and not(following-sibling::*)) then
                            html:inline($config, ., ("tei-height2"), .)
                        else
                            html:inline($config, ., ("tei-height3"), .)
                case element(width) return
                    if (parent::dimensions and count(following-sibling::*) >= 1) then
                        html:inline($config, ., ("tei-width1"), .)
                    else
                        if (parent::dimensions) then
                            html:inline($config, ., ("tei-width2"), .)
                        else
                            html:inline($config, ., ("tei-width3"), .)
                case element(depth) return
                    if (parent::dimensions and following-sibling::*) then
                        html:inline($config, ., ("tei-depth1"), .)
                    else
                        if (parent::dimensions) then
                            html:inline($config, ., ("tei-depth2"), .)
                        else
                            html:inline($config, ., ("tei-depth3"), .)
                case element(dim) return
                    if (@type='diameter' and (parent::dimensions and following-sibling::*)) then
                        html:inline($config, ., ("tei-dim1"), .)
                    else
                        if (@type='diameter' and (parent::dimensions and not(following-sibling::*))) then
                            html:inline($config, ., ("tei-dim2"), .)
                        else
                            html:inline($config, ., ("tei-dim3"), .)
                case element(idno) return
                    if (ancestor::biblStruct) then
                        html:omit($config, ., ("tei-idno1"), .)
                    else
                        if ($parameters?header='short' and @type='filename') then
                            html:inline($config, ., ("tei-idno2"), .)
                        else
                            if (ancestor::publicationStmt) then
                                html:inline($config, ., ("tei-idno3"), .)
                            else
                                html:inline($config, ., ("tei-idno4"), .)
                case element(imprint) return
                    if (ancestor::biblStruct[@type='book']) then
                        (
                            if (pubPlace) then
                                html:inline($config, ., ("tei-imprint1"), pubPlace)
                            else
                                (),
                            if (publisher) then
                                html:inline($config, ., ("tei-imprint2"), publisher)
                            else
                                (),
                            if ((pubPlace or publisher) and (date)) then
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
                                (),
                            if (not(ancestor::biblStruct//note)) then
                                html:inline($config, ., ("tei-imprint6"), '.')
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct[@type='journalArticle']) then
                            (
                                if (biblScope[@unit='volume']) then
                                    html:inline($config, ., ("tei-imprint7"), biblScope[@unit='volume'])
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
                                if (../biblScope[@unit='page']) then
                                    html:text($config, ., ("tei-imprint10"), ': ')
                                else
                                    (),
                                if (note) then
                                    html:inline($config, ., ("tei-imprint11"), note)
                                else
                                    (),
                                if (not(ancestor::biblStruct//note)) then
                                    html:inline($config, ., ("tei-imprint12"), '.')
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct[@type='encyclopediaArticle'] or ancestor::biblStruct[@type='bookSection']) then
                                (
                                    if (biblScope[@unit='volume']) then
                                        html:inline($config, ., ("tei-imprint13"), biblScope[@unit='volume'])
                                    else
                                        (),
                                    if (following-sibling::*) then
                                        html:text($config, ., ("tei-imprint14"), ', ')
                                    else
                                        (),
                                    if (pubPlace) then
                                        html:inline($config, ., ("tei-imprint15"), pubPlace)
                                    else
                                        (),
                                    if (following-sibling::biblScope[@unit='page']) then
                                        html:text($config, ., ("tei-imprint16"), ': ')
                                    else
                                        (),
                                    if (publisher) then
                                        html:inline($config, ., ("tei-imprint17"), publisher)
                                    else
                                        (),
                                    if (date) then
                                        html:text($config, ., ("tei-imprint18"), ', ')
                                    else
                                        (),
                                    if (date) then
                                        html:inline($config, ., ("tei-imprint19"), date)
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        html:text($config, ., ("tei-imprint20"), ': ')
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        html:inline($config, ., ("tei-imprint21"), biblScope[@unit='page'])
                                    else
                                        (),
                                    if (note) then
                                        html:inline($config, ., ("tei-imprint22"), note)
                                    else
                                        (),
                                    if (not(ancestor::biblStruct//note)) then
                                        html:inline($config, ., ("tei-imprint23"), '.')
                                    else
                                        ()
                                )

                            else
                                $config?apply($config, ./node())
                case element(layout) return
                    html:inline($config, ., ("tei-layout"), p)
                case element(listApp) return
                    if (@rendition) then
                        html:list($config, ., css:get-rendition(., ("tei-listApp1")), app)
                    else
                        if (not(@rendition)) then
                            html:list($config, ., ("tei-listApp2"), app)
                        else
                            $config?apply($config, ./node())
                case element(msDesc) return
                    html:inline($config, ., ("tei-msDesc"), .)
                case element(notesStmt) return
                    html:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    html:inline($config, ., ("tei-objectDesc"), .)
                case element(persName) return
                    if (ancestor::titleStmt and parent::respStmt/following-sibling::respStmt) then
                        html:inline($config, ., ("tei-persName1"), (concat(normalize-space(.),', ')))
                    else
                        if (ancestor::titleStmt and not(parent::respStmt/following-sibling::respStmt)) then
                            html:inline($config, ., ("tei-persName2"), (concat(normalize-space(.),'. ')))
                        else
                            html:inline($config, ., ("tei-persName3"), .)
                case element(physDesc) return
                    html:inline($config, ., ("tei-physDesc"), .)
                case element(provenance) return
                    if (parent::history) then
                        html:inline($config, ., ("tei-provenance"), .)
                    else
                        $config?apply($config, ./node())
                case element(ptr) return
                    if (parent::bibl) then
                        (: No function found for behavior: refbibl :)
                        $config?apply($config, ./node())
                    else
                        if (ancestor::provenance and not(text())) then
                            html:inline($config, ., ("tei-ptr2"), let $target := substring-after(@target, '#') return ancestor::teiHeader//msIdentifier//idno[@xml:id=$target])
                        else
                            if (not(text())) then
                                html:link($config, ., ("tei-ptr3"), @target, ())
                            else
                                $config?apply($config, ./node())
                case element(rdg) return
                    html:inline($config, ., ("tei-rdg"), .)
                case element(respStmt) return
                    if (ancestor::titleStmt and count(child::resp[@type='editor'] >= 1)) then
                        html:inline($config, ., ("tei-respStmt1"), persName)
                    else
                        html:inline($config, ., ("tei-respStmt2"), .)
                case element(series) return
                    if (ancestor::biblStruct) then
                        html:inline($config, ., ("tei-series1"), if (series) then
    (
        html:text($config, ., ("tei-series2"), ', '),
        html:text($config, ., ("tei-series3"), title[@level='s']),
        html:text($config, ., ("tei-series4"), ', '),
        html:text($config, ., ("tei-series5"), biblScope)
    )

else
    $config?apply($config, ./node()))
                    else
                        $config?apply($config, ./node())
                case element(space) return
                    if (@type='horizontal') then
                        html:inline($config, ., ("tei-space1"), '◊')
                    else
                        if (@type='binding-hole') then
                            html:inline($config, ., ("tei-space2"), '◯')
                        else
                            html:inline($config, ., ("tei-space3"), .)
                case element(supportDesc) return
                    html:inline($config, ., ("tei-supportDesc"), .)
                case element(surrogates) return
                    html:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    html:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    html:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' 
                            return 
                            concat(normalize-space(.),$finale)
                        )
                case element(term) return
                    html:inline($config, ., ("tei-term"), .)
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

