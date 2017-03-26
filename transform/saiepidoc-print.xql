(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/SAI/resources/odd/compiled/saiepidoc.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/tei-simple/models/saiepidoc.odd/fo";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace skos='http://www.w3.org/2004/02/skos/core#';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/css.xql";

import module namespace fo="http://www.tei-c.org/tei-simple/xquery/functions/fo" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/fo-functions.xql";

import module namespace ext-fo="http://www.tei-c.org/tei-simple/xquery/ext-fo" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/../modules/ext-fo.xql";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["fo","print"],
                "odd": "/db/apps/SAI/resources/odd/compiled/saiepidoc.odd",
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
                        (: No function found for behavior: xml-tab :)
                        $config?apply($config, ./node())
                    else
                        fo:block($config, ., ("tei-ab2"), .)
                case element(ab) return
                    fo:block($config, ., ("tei-ab"), .)
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
                case element(addSpan) return
                    fo:anchor($config, ., ("tei-addSpan"), ., @xml:id)
                case element(am) return
                    fo:inline($config, ., ("tei-am"), .)
                case element(anchor) return
                    fo:anchor($config, ., ("tei-anchor"), ., @xml:id)
                case element(argument) return
                    fo:block($config, ., ("tei-argument"), .)
                case element(back) return
                    fo:block($config, ., ("tei-back"), .)
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
                                    fo:listItem($config, ., ("tei-bibl4"), .)
                                else
                                    fo:inline($config, ., ("tei-bibl5", "bibl"), .)
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
                    if (child::quote and child::bibl) then
                        (: Insert citation :)
                        fo:cit($config, ., ("tei-cit"), .)
                    else
                        $config?apply($config, ./node())
                case element(closer) return
                    fo:block($config, ., ("tei-closer"), .)
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
                            if (text()) then
                                fo:inline($config, ., ("tei-date4"), .)
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
                    if (ancestor::TEI[@type='general-biblio']) then
                        fo:section($config, ., ("tei-div1", (bibliography-top)), .)
                    else
                        if (@type='bibliography') then
                            (
                                fo:heading($config, ., ("tei-div1"), 'Secondary bibliography'),
                                fo:section($config, ., ("tei-div2", "bibliography-secondary"), listBibl)
                            )

                        else
                            if (not((@type='textpart') or (@type='apparatus'))) then
                                (
                                    fo:heading($config, ., ("tei-div1", (@type)), concat(upper-case(substring(@type,1,1)),substring(@type,2))),
                                    fo:section($config, ., ("tei-div2", (@type)), .)
                                )

                            else
                                if (@type='apparatus') then
                                    (
                                        fo:section($config, ., ("tei-div", (@type)), .)
                                    )

                                else
                                    if (@type='edition') then
                                        (
                                            fo:section($config, ., ("tei-div", (@type)), .)
                                        )

                                    else
                                        if (@type='textpart') then
                                            fo:block($config, ., ("tei-div2"), .)
                                        else
                                            fo:block($config, ., ("tei-div3"), .)
                case element(docAuthor) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        fo:omit($config, ., ("tei-docAuthor1"), .)
                    else
                        fo:inline($config, ., ("tei-docAuthor2"), .)
                case element(docDate) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        fo:omit($config, ., ("tei-docDate1"), .)
                    else
                        fo:inline($config, ., ("tei-docDate2"), .)
                case element(docEdition) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        fo:omit($config, ., ("tei-docEdition1"), .)
                    else
                        fo:inline($config, ., ("tei-docEdition2"), .)
                case element(docImprint) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        fo:omit($config, ., ("tei-docImprint1"), .)
                    else
                        fo:inline($config, ., ("tei-docImprint2"), .)
                case element(docTitle) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        fo:omit($config, ., ("tei-docTitle1"), .)
                    else
                        fo:block($config, ., css:get-rendition(., ("tei-docTitle2")), .)
                case element(epigraph) return
                    fo:block($config, ., ("tei-epigraph"), .)
                case element(ex) return
                    fo:inline($config, ., ("tei-ex"), .)
                case element(expan) return
                    fo:inline($config, ., ("tei-expan"), .)
                case element(figDesc) return
                    fo:inline($config, ., ("tei-figDesc"), .)
                case element(figure) return
                    if (head) then
                        fo:figure($config, ., ("tei-figure1"), *[not(self::head)], head/node())
                    else
                        fo:block($config, ., ("tei-figure2"), .)
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
                    if (ancestor::p or ancestor::ab) then
                        fo:inline($config, ., ("tei-fw1"), .)
                    else
                        fo:block($config, ., ("tei-fw2"), .)
                case element(g) return
                    if (@type) then
                        fo:inline($config, ., ("tei-g"), @type)
                    else
                        $config?apply($config, ./node())
                case element(gap) return
                    if ((@reason='lost' and @unit='line' and @quantity=1) and not(child::certainty)) then
                        fo:inline($config, ., ("tei-gap1", "italic"), .)
                    else
                        if ((@reason='lost' and @unit='line' and child::certainty[@locus='name']) and not(@quantity=1)) then
                            fo:inline($config, ., ("tei-gap2", "italic"), .)
                        else
                            if ((@reason='lost' and @unit='line' and not(@quantity=1)) and not(child::certainty[@locus='name'])) then
                                fo:inline($config, ., ("tei-gap3", "italic"), .)
                            else
                                if (@reason='lost' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                    fo:inline($config, ., ("tei-gap4", "italic"), .)
                                else
                                    if ((@reason='illegible' and @unit='line' and @quantity=1) and not(child::certainty)) then
                                        fo:inline($config, ., ("tei-gap5", "italic"), .)
                                    else
                                        if ((@reason='illegible' and @unit='line' and child::certainty[@locus='name']) and not(@quantity=1)) then
                                            fo:inline($config, ., ("tei-gap6", "italic"), .)
                                        else
                                            if ((@reason='illegible' and @unit='line' and not(@quantity=1)) and not(child::certainty[@locus='name'])) then
                                                fo:inline($config, ., ("tei-gap7", "italic"), .)
                                            else
                                                if (@reason='illegible' and @unit='line' and child::certainty[@locus] and @quantity=1) then
                                                    fo:inline($config, ., ("tei-gap8", "italic"), .)
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
                case element(gi) return
                    fo:inline($config, ., ("tei-gi"), .)
                case element(graphic) return
                    if (parent::facsimile and $parameters?teiHeader-type='epidoc') then
                        fo:link($config, ., ("tei-graphic1"), ., ())
                    else
                        fo:graphic($config, ., ("tei-graphic2"), ., @url, (), (), 0.5, desc)
                case element(group) return
                    fo:block($config, ., ("tei-group"), .)
                case element(handShift) return
                    fo:inline($config, ., ("tei-handShift"), .)
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
                                        if (parent::div) then
                                            fo:heading($config, ., ("tei-head6"), .)
                                        else
                                            fo:block($config, ., ("tei-head7"), .)
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
                    if ($parameters?break='Logical') then
                        (: No function found for behavior: breakPyu :)
                        $config?apply($config, ./node())
                    else
                        if ($parameters?break='Physical') then
                            (: No function found for behavior: breakPyu :)
                            $config?apply($config, ./node())
                        else
                            fo:block($config, ., ("tei-l3"), .)
                case element(label) return
                    fo:inline($config, ., ("tei-label"), .)
                case element(lb) return
                    if ($parameters?break='Physical') then
                        (: No function found for behavior: breakPyu :)
                        $config?apply($config, ./node())
                    else
                        if ($parameters?break='Logical') then
                            (: No function found for behavior: breakPyu :)
                            $config?apply($config, ./node())
                        else
                            fo:inline($config, ., ("tei-lb3", "lineNumber"), (
    fo:text($config, ., ("tei-lb1"), ' ('),
    fo:inline($config, ., ("tei-lb2"), if (@n) then @n else count(preceding-sibling::lb) + 1),
    fo:text($config, ., ("tei-lb3"), ') ')
)
)
                case element(lg) return
                    if (@met or @n) then
                        (
                            fo:inline($config, ., ("tei-lg1", "verse-number"), @n),
                            fo:block($config, ., ("tei-lg2", "verse-meter"), @met),
                            fo:inline($config, ., ("tei-lg3", "verse-block"), .)
                        )

                    else
                        fo:block($config, ., ("tei-lg", "block"), .)
                case element(list) return
                    if (@rendition) then
                        fo:list($config, ., css:get-rendition(., ("tei-list1")), item)
                    else
                        if (not(@rendition)) then
                            fo:list($config, ., ("tei-list2"), item)
                        else
                            $config?apply($config, ./node())
                case element(listBibl) return
                    if (ancestor::div[@type='genBibliography'] and child::biblStruct) then
                        (: No function found for behavior: xsl-biblio :)
                        $config?apply($config, ./node())
                    else
                        if (child::biblStruct) then
                            fo:list($config, ., ("tei-listBibl2", "list-group"), biblStruct)
                        else
                            if (ancestor::surrogates or ancestor::div[@type='bibliography']) then
                                (: No function found for behavior: :)
                                $config?apply($config, ./node())
                            else
                                if (bibl) then
                                    fo:list($config, ., ("tei-listBibl4"), bibl)
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
                    fo:inline($config, ., ("tei-name"), .)
                case element(note) return
                    if (ancestor::div[@type='apparatus'] or ancestor::div[@type='commentary']) then
                        fo:inline($config, ., ("tei-note1"), .)
                    else
                        if (ancestor::teiHeader and text()[normalize-space(.)]) then
                            fo:listItem($config, ., ("tei-note2"), .)
                        else
                            if (@type='tags' and ancestor::biblStruct) then
                                fo:omit($config, ., ("tei-note3"), .)
                            else
                                if (@type='accessed' and ancestor::biblStruct) then
                                    fo:omit($config, ., ("tei-note4"), .)
                                else
                                    if (ancestor::biblStruct) then
                                        (
                                            fo:inline($config, ., ("tei-note1"), ', '),
                                            (: No function found for behavior: :)
                                            $config?apply($config, ./node())
                                        )

                                    else
                                        fo:inline($config, ., ("tei-note5"), .)
                case element(num) return
                    fo:inline($config, ., ("tei-num"), .)
                case element(opener) return
                    fo:block($config, ., ("tei-opener"), .)
                case element(orig) return
                    fo:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (parent::div[@type='bibliography']) then
                        fo:inline($config, ., ("tei-p1"), .)
                    else
                        if (parent::support) then
                            fo:inline($config, ., ("tei-p2"), .)
                        else
                            if (parent::provenance) then
                                fo:inline($config, ., ("tei-p3"), .)
                            else
                                fo:block($config, ., ("tei-p4"), .)
                case element(pb) return
                    fo:break($config, ., css:get-rendition(., ("tei-pb")), ., 'page', (concat(if(@n) then     concat(@n,' ') else '',if(@facs) then     concat('@',@facs) else '')))
                case element(pc) return
                    fo:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    fo:block($config, ., ("tei-postscript"), .)
                case element(q) return
                    if (l) then
                        fo:block($config, ., css:get-rendition(., ("tei-q1")), .)
                    else
                        if (ancestor::p or ancestor::cell) then
                            fo:inline($config, ., css:get-rendition(., ("tei-q2")), .)
                        else
                            fo:block($config, ., css:get-rendition(., ("tei-q3")), .)
                case element(quote) return
                    if (ancestor::p or ancestor::note) then
                        (: If it is inside a paragraph or a note then it is inline, otherwise it is block level :)
                        fo:inline($config, ., css:get-rendition(., ("tei-quote1")), .)
                    else
                        (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                        fo:block($config, ., css:get-rendition(., ("tei-quote2")), .)
                case element(ref) return
                    if (not(@target)) then
                        fo:inline($config, ., ("tei-ref1"), .)
                    else
                        if (not(text())) then
                            fo:link($config, ., ("tei-ref2"), @target, @target)
                        else
                            fo:link($config, ., ("tei-ref3"), .,  if (starts-with(@target, "#")) then request:get-parameter("doc", ()) || "?odd=" || request:get-parameter("odd", ()) || "&amp;view=" || request:get-parameter("view", ()) || "&amp;id=" ||
                            substring-after(@target, '#') else @target )
                case element(reg) return
                    fo:inline($config, ., ("tei-reg"), .)
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
                        fo:inline($config, ., ("tei-seg1"), .)
                    else
                        if (@type='graphemic') then
                            fo:inline($config, ., ("tei-seg2"), .)
                        else
                            if (@type='phonetic') then
                                fo:inline($config, ., ("tei-seg3"), .)
                            else
                                if (@type='phonemic') then
                                    fo:inline($config, ., ("tei-seg4"), .)
                                else
                                    if (@type='t1') then
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
                case element(space) return
                    if (@type='horizontal') then
                        fo:inline($config, ., ("tei-space1"), '◊')
                    else
                        if (@type='binding-hole') then
                            fo:inline($config, ., ("tei-space2"), '◯')
                        else
                            fo:inline($config, ., ("tei-space3"), .)
                case element(speaker) return
                    fo:block($config, ., ("tei-speaker"), .)
                case element(spGrp) return
                    fo:block($config, ., ("tei-spGrp"), .)
                case element(stage) return
                    fo:block($config, ., ("tei-stage"), .)
                case element(subst) return
                    fo:inline($config, ., ("tei-subst"), .)
                case element(supplied) return
                    if (parent::choice) then
                        fo:inline($config, ., ("tei-supplied1"), .)
                    else
                        if (@reason='omitted') then
                            fo:inline($config, ., ("tei-supplied2"), .)
                        else
                            fo:inline($config, ., ("tei-supplied3"), .)
                case element(supplied) return
                    fo:inline($config, ., ("tei-supplied"), .)
                case element(table) return
                    fo:table($config, ., ("tei-table"), .)
                case element(profileDesc) return
                    fo:omit($config, ., ("tei-profileDesc"), .)
                case element(revisionDesc) return
                    if ($parameters?teiHeader-type='epidoc') then
                        fo:omit($config, ., ("tei-revisionDesc"), .)
                    else
                        (
                            fo:block($config, ., ("tei-revisionDesc"), concat('Last modified on: ',change[position()=last()]/@when))
                        )

                case element(encodingDesc) return
                    fo:omit($config, ., ("tei-encodingDesc"), .)
                case element(teiHeader) return
                    fo:omit($config, ., ("tei-teiHeader2"), .)
                case element(author) return
                    if (ancestor::teiHeader) then
                        fo:block($config, ., ("tei-author1"), .)
                    else
                        if (ancestor::biblStruct) then
                            fo:inline($config, ., ("tei-author2"), if (surname or forename) then
    (
        fo:text($config, ., ("tei-author1"), surname),
        fo:text($config, ., ("tei-author2"), ', '),
        fo:text($config, ., ("tei-author3"), forename)
    )

else
    if (name) then
        fo:text($config, ., ("tei-author"), name)
    else
        $config?apply($config, ./node()))
                        else
                            $config?apply($config, ./node())
                case element(availability) return
                    fo:block($config, ., ("tei-availability"), .)
                case element(edition) return
                    if (ancestor::teiHeader) then
                        fo:block($config, ., ("tei-edition"), .)
                    else
                        $config?apply($config, ./node())
                case element(idno) return
                    if (ancestor::biblStruct) then
                        fo:omit($config, ., ("tei-idno1"), .)
                    else
                        if ($parameters?header='short' and @type='filename') then
                            fo:inline($config, ., ("tei-idno2"), .)
                        else
                            if (ancestor::publicationStmt) then
                                fo:inline($config, ., ("tei-idno3"), .)
                            else
                                fo:inline($config, ., ("tei-idno4"), .)
                case element(publicationStmt) return
                    if ($parameters?header='short') then
                        fo:inline($config, ., ("tei-publicationStmt"), .)
                    else
                        $config?apply($config, ./node())
                case element(publisher) return
                    (: More than one model without predicate found for ident publisher. Choosing first one. :)
                    (
                        if (ancestor::biblStruct) then
                            fo:text($config, ., ("tei-publisher1"), ': ')
                        else
                            (),
                        if (ancestor::biblStruct) then
                            fo:inline($config, ., ("tei-publisher2"), .)
                        else
                            ()
                    )

                case element(pubPlace) return
                    if (ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-pubPlace"), .)
                    else
                        $config?apply($config, ./node())
                case element(seriesStmt) return
                    fo:block($config, ., ("tei-seriesStmt"), .)
                case element(fileDesc) return
                    if ($parameters?header='short') then
                        (
                            fo:inline($config, ., ("tei-fileDesc1", "header-short"), publicationStmt),
                            fo:inline($config, ., ("tei-fileDesc2", "header-short"), titleStmt)
                        )

                    else
                        if (ancestor::TEI[@type='general-biblio']) then
                            fo:paragraph($config, ., ("tei-fileDesc1"), sourceDesc)
                        else
                            $config?apply($config, ./node())
                case element(titleStmt) return
                    fo:heading($config, ., ("tei-titleStmt2"), .)
                case element(TEI) return
                    fo:document($config, ., ("tei-TEI"), .)
                case element(text) return
                    fo:body($config, ., ("tei-text"), .)
                case element(time) return
                    fo:inline($config, ., ("tei-time"), .)
                case element(title) return
                    if ($parameters?header='short') then
                        fo:inline($config, ., ("tei-title1"), .)
                    else
                        if (parent::titleStmt/parent::fileDesc) then
                            (
                                if (preceding-sibling::title) then
                                    fo:text($config, ., ("tei-title1"), ' — ')
                                else
                                    (),
                                fo:inline($config, ., ("tei-title2"), .)
                            )

                        else
                            if ((@level='a' or @level='s') and ancestor::biblStruct) then
                                fo:inline($config, ., ("tei-title2"), .)
                            else
                                if ((@level='j' or @level='m')  and ancestor::biblStruct) then
                                    fo:inline($config, ., ("tei-title3"), .)
                                else
                                    if (not(@level) and parent::bibl) then
                                        fo:inline($config, ., ("tei-title4"), .)
                                    else
                                        if (@type='short' and ancestor::biblStruct) then
                                            fo:inline($config, ., ("tei-title5", "vedette"), .)
                                        else
                                            fo:inline($config, ., ("tei-title6"), .)
                case element(titlePage) return
                    fo:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    fo:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    fo:block($config, ., ("tei-trailer"), .)
                case element(unclear) return
                    fo:inline($config, ., ("tei-unclear"), .)
                case element(w) return
                    fo:inline($config, ., ("tei-w"), .)
                case element(additional) return
                    if ($parameters?teiHeader-type='epidoc') then
                        fo:block($config, ., ("tei-additional"), .)
                    else
                        $config?apply($config, ./node())
                case element(app) return
                    if (ancestor::div[@type='edition']) then
                        (
                            if (lem) then
                                fo:inline($config, ., ("tei-app1"), lem)
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
                    fo:omit($config, ., ("tei-authority"), .)
                case element(biblScope) return
                    if (ancestor::biblStruct and @unit='series') then
                        (
                            if (@unit='series') then
                                fo:inline($config, ., ("tei-biblScope"), .)
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct and @unit='volume') then
                            (
                                if (monogr/author or monogr/editor) then
                                    fo:text($config, ., ("tei-biblScope1"), ', ')
                                else
                                    (),
                                if (@unit='volume') then
                                    fo:inline($config, ., ("tei-biblScope2"), .)
                                else
                                    (),
                                if (@unit='volume') then
                                    fo:text($config, ., ("tei-biblScope3"), ', ')
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct and @unit='page') then
                                (
                                    if (@unit='page') then
                                        fo:inline($config, ., ("tei-biblScope"), .)
                                    else
                                        ()
                                )

                            else
                                $config?apply($config, ./node())
                case element(biblStruct) return
                    if (parent::listBibl) then
                        fo:listItem($config, ., ("tei-biblStruct"), (
    fo:block($config, ., ("tei-biblStruct"), (
    if (./@type) then
        fo:inline($config, ., ("tei-biblStruct1"), @type)
    else
        (),
    if (./@xml:id) then
        fo:inline($config, ., ("tei-biblStruct2"), @xml:id)
    else
        ()
)
),
    (
        fo:block($config, ., ("tei-biblStruct"), if (.//title[@type='short']) then
    fo:inline($config, ., ("tei-biblStruct"), .//title[@type='short'])
else
    (
        if (.//author/surname) then
            fo:text($config, ., ("tei-biblStruct1"), .//author/surname)
        else
            if (.//author/name) then
                fo:text($config, ., ("tei-biblStruct2"), .//author/name)
            else
                $config?apply($config, ./node()),
        fo:text($config, ., ("tei-biblStruct1"), ' '),
        fo:inline($config, ., ("tei-biblStruct2"), monogr/imprint/date)
    )
)
    )
,
    (
        if (@type='journalArticle' or @type='bookSection' or @type='encyclopediaArticle') then
            (
                fo:inline($config, ., ("tei-biblStruct1"), analytic/author),
                fo:text($config, ., ("tei-biblStruct2"), ', '),
                fo:inline($config, ., ("tei-biblStruct3"), analytic/title[@level='a']),
                fo:text($config, ., ("tei-biblStruct4"), ', '),
                if (@type='bookSection' or @type='encyclopediaArticle') then
                    (
                        if (@type='bookSection' or @type='encyclopediaArticle') then
                            fo:text($config, ., ("tei-biblStruct1"), 'in ')
                        else
                            (),
                        fo:inline($config, ., ("tei-biblStruct2"), monogr/title[@level='m']),
                        fo:text($config, ., ("tei-biblStruct3"), ', '),
                        if (monogr/author) then
                            fo:text($config, ., ("tei-biblStruct4"), 'by ')
                        else
                            (),
                        fo:inline($config, ., ("tei-biblStruct5"), monogr/author),
                        if (monogr/editor) then
                            fo:text($config, ., ("tei-biblStruct6"), 'edited by ')
                        else
                            (),
                        fo:inline($config, ., ("tei-biblStruct7"), monogr/editor)
                    )

                else
                    (),
                if (@type='journalArticle') then
                    (
                        fo:inline($config, ., ("tei-biblStruct1"), monogr/title[@level='j']),
                        fo:text($config, ., ("tei-biblStruct2"), ', ')
                    )

                else
                    (),
                if (.//series) then
                    fo:inline($config, ., ("tei-biblStruct5"), series)
                else
                    (),
                if (.//monogr/imprint) then
                    fo:inline($config, ., ("tei-biblStruct6"), monogr/imprint)
                else
                    (),
                if (.//note) then
                    (
                        if (./note) then
                            fo:inline($config, ., ("tei-biblStruct1"), ./note)
                        else
                            (),
                        if (.//imprint/note) then
                            fo:inline($config, ., ("tei-biblStruct2"), ./note)
                        else
                            (),
                        if (not(ends-with(.//note,'.'))) then
                            fo:inline($config, ., ("tei-biblStruct3"), '.')
                        else
                            ()
                    )

                else
                    ()
            )

        else
            if (@type='book') then
                (
                    fo:inline($config, ., ("tei-biblStruct1"), monogr/author),
                    fo:text($config, ., ("tei-biblStruct2"), ', '),
                    fo:inline($config, ., ("tei-biblStruct3"), monogr/title[@level='m']),
                    fo:text($config, ., ("tei-biblStruct4"), ', '),
                    if (monogr/imprint) then
                        (
                            fo:inline($config, ., ("tei-biblStruct"), monogr/imprint)
                        )

                    else
                        (),
                    if (note) then
                        (
                            fo:inline($config, ., ("tei-biblStruct1"), note),
                            if (not(ends-with(note,'.'))) then
                                fo:inline($config, ., ("tei-biblStruct2"), '.')
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
                            fo:inline($config, ., ("tei-dimensions1"), .)
                        else
                            (),
                        if (@unit) then
                            fo:inline($config, ., ("tei-dimensions2"), @unit)
                        else
                            ()
                    )

                case element(editor) return
                    if (ancestor::teiHeader) then
                        fo:block($config, ., ("tei-editor1"), .)
                    else
                        if (ancestor::biblStruct) then
                            fo:inline($config, ., ("tei-editor2"), if (surname or forename) then
    (
        fo:text($config, ., ("tei-editor1"), surname),
        fo:text($config, ., ("tei-editor2"), ', '),
        fo:text($config, ., ("tei-editor3"), forename)
    )

else
    if (name) then
        fo:text($config, ., ("tei-editor"), name)
    else
        $config?apply($config, ./node()))
                        else
                            $config?apply($config, ./node())
                case element(height) return
                    if (parent::dimensions and following-sibling::*) then
                        fo:inline($config, ., ("tei-height1"), .)
                    else
                        if (parent::dimensions and not(following-sibling::*)) then
                            fo:inline($config, ., ("tei-height2"), .)
                        else
                            fo:inline($config, ., ("tei-height3"), .)
                case element(width) return
                    if (parent::dimensions and count(following-sibling::*) >= 1) then
                        fo:inline($config, ., ("tei-width1"), .)
                    else
                        if (parent::dimensions) then
                            fo:inline($config, ., ("tei-width2"), .)
                        else
                            fo:inline($config, ., ("tei-width3"), .)
                case element(depth) return
                    if (parent::dimensions and following-sibling::*) then
                        fo:inline($config, ., ("tei-depth1"), .)
                    else
                        if (parent::dimensions) then
                            fo:inline($config, ., ("tei-depth2"), .)
                        else
                            fo:inline($config, ., ("tei-depth3"), .)
                case element(dim) return
                    if (@type='diameter' and (parent::dimensions and following-sibling::*)) then
                        fo:inline($config, ., ("tei-dim1"), .)
                    else
                        if (@type='diameter' and (parent::dimensions and not(following-sibling::*))) then
                            fo:inline($config, ., ("tei-dim2"), .)
                        else
                            fo:inline($config, ., ("tei-dim3"), .)
                case element(imprint) return
                    if (ancestor::biblStruct[@type='book']) then
                        (
                            if (pubPlace) then
                                fo:inline($config, ., ("tei-imprint1"), pubPlace)
                            else
                                (),
                            if (publisher) then
                                fo:inline($config, ., ("tei-imprint2"), publisher)
                            else
                                (),
                            if ((pubPlace or publisher) and (date)) then
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
                                (),
                            if (not(ancestor::biblStruct//note)) then
                                fo:inline($config, ., ("tei-imprint6"), '.')
                            else
                                ()
                        )

                    else
                        if (ancestor::biblStruct[@type='journalArticle']) then
                            (
                                if (biblScope[@unit='volume']) then
                                    fo:inline($config, ., ("tei-imprint1"), biblScope[@unit='volume'])
                                else
                                    (),
                                if (biblScope[@unit='issue']) then
                                    fo:inline($config, ., ("tei-imprint2"), biblScope[@unit='issue'])
                                else
                                    (),
                                if (date) then
                                    fo:inline($config, ., ("tei-imprint3"), date)
                                else
                                    (),
                                if (../biblScope[@unit='page']) then
                                    fo:text($config, ., ("tei-imprint4"), ': ')
                                else
                                    (),
                                if (note) then
                                    fo:inline($config, ., ("tei-imprint5"), note)
                                else
                                    (),
                                if (not(ancestor::biblStruct//note)) then
                                    fo:inline($config, ., ("tei-imprint6"), '.')
                                else
                                    ()
                            )

                        else
                            if (ancestor::biblStruct[@type='encyclopediaArticle'] or ancestor::biblStruct[@type='bookSection']) then
                                (
                                    if (biblScope[@unit='volume']) then
                                        fo:inline($config, ., ("tei-imprint1"), biblScope[@unit='volume'])
                                    else
                                        (),
                                    if (following-sibling::*) then
                                        fo:text($config, ., ("tei-imprint2"), ', ')
                                    else
                                        (),
                                    if (pubPlace) then
                                        fo:inline($config, ., ("tei-imprint3"), pubPlace)
                                    else
                                        (),
                                    if (following-sibling::biblScope[@unit='page']) then
                                        fo:text($config, ., ("tei-imprint4"), ': ')
                                    else
                                        (),
                                    if (publisher) then
                                        fo:inline($config, ., ("tei-imprint5"), publisher)
                                    else
                                        (),
                                    if (date) then
                                        fo:text($config, ., ("tei-imprint6"), ', ')
                                    else
                                        (),
                                    if (date) then
                                        fo:inline($config, ., ("tei-imprint7"), date)
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        fo:text($config, ., ("tei-imprint8"), ': ')
                                    else
                                        (),
                                    if (biblScope[@unit='page']) then
                                        fo:inline($config, ., ("tei-imprint9"), biblScope[@unit='page'])
                                    else
                                        (),
                                    if (note) then
                                        fo:inline($config, ., ("tei-imprint10"), note)
                                    else
                                        (),
                                    if (not(ancestor::biblStruct//note)) then
                                        fo:inline($config, ., ("tei-imprint11"), '.')
                                    else
                                        ()
                                )

                            else
                                $config?apply($config, ./node())
                case element(layout) return
                    fo:inline($config, ., ("tei-layout"), p)
                case element(licence) return
                    fo:omit($config, ., ("tei-licence"), .)
                case element(listApp) return
                    if (@rendition) then
                        fo:list($config, ., css:get-rendition(., ("tei-listApp1")), app)
                    else
                        if (not(@rendition)) then
                            fo:list($config, ., ("tei-listApp2"), app)
                        else
                            $config?apply($config, ./node())
                case element(msDesc) return
                    fo:inline($config, ., ("tei-msDesc"), .)
                case element(notesStmt) return
                    fo:list($config, ., ("tei-notesStmt"), .)
                case element(objectDesc) return
                    fo:inline($config, ., ("tei-objectDesc"), .)
                case element(persName) return
                    if (ancestor::titleStmt and parent::respStmt/following-sibling::respStmt) then
                        fo:inline($config, ., ("tei-persName1"), (concat(normalize-space(.),', ')))
                    else
                        if (ancestor::titleStmt and not(parent::respStmt/following-sibling::respStmt)) then
                            fo:inline($config, ., ("tei-persName2"), (concat(normalize-space(.),'. ')))
                        else
                            fo:inline($config, ., ("tei-persName3"), .)
                case element(physDesc) return
                    fo:inline($config, ., ("tei-physDesc"), .)
                case element(provenance) return
                    if (parent::history) then
                        fo:inline($config, ., ("tei-provenance"), .)
                    else
                        $config?apply($config, ./node())
                case element(ptr) return
                    if (parent::bibl) then
                        (: No function found for behavior: refbibl :)
                        $config?apply($config, ./node())
                    else
                        if (ancestor::provenance and not(text())) then
                            fo:inline($config, ., ("tei-ptr2"), let $target := substring-after(@target, '#') return ancestor::teiHeader//msIdentifier//idno[@xml:id=$target])
                        else
                            if (not(text())) then
                                fo:link($config, ., ("tei-ptr3"), @target, ())
                            else
                                $config?apply($config, ./node())
                case element(rdg) return
                    fo:inline($config, ., ("tei-rdg"), .)
                case element(respStmt) return
                    if (ancestor::titleStmt and count(child::resp[@type='editor'] >= 1)) then
                        fo:inline($config, ., ("tei-respStmt1"), persName)
                    else
                        fo:inline($config, ., ("tei-respStmt2"), .)
                case element(series) return
                    if (ancestor::biblStruct) then
                        fo:inline($config, ., ("tei-series"), if (series) then
    (
        fo:text($config, ., ("tei-series1"), ', '),
        fo:text($config, ., ("tei-series2"), title[@level='s']),
        fo:text($config, ., ("tei-series3"), ', '),
        fo:text($config, ., ("tei-series4"), biblScope)
    )

else
    $config?apply($config, ./node()))
                    else
                        $config?apply($config, ./node())
                case element(supportDesc) return
                    fo:inline($config, ., ("tei-supportDesc"), .)
                case element(surrogates) return
                    fo:block($config, ., ("tei-surrogates"), .)
                case element(surplus) return
                    fo:inline($config, ., ("tei-surplus"), .)
                case element(textLang) return
                    fo:inline($config, ., ("tei-textLang"), let $finale := if (ends-with(normalize-space(.),'.')) then () else '. ' 
                            return 
                            concat(normalize-space(.),$finale)
                        )
                case element(term) return
                    fo:inline($config, ., ("tei-term"), .)
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

