xquery version "3.0";
(:~ 
 : d3xquery to display family tree using dTree
 : See: https://github.com/ErikGartner/dTree
 :)

module namespace d3xquery = "http://expath.org/ns/d3xquery";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "../config.xqm";
import module namespace functx="http://www.functx.com";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:~
 : Transform relation data into JSON for dTree
:)
declare function d3xquery:build-familyTree-data($id as xs:string?) {
if($id != '') then
    let $json-xml :=
        <root json:array="true">
            <name>{d3xquery:get-name($id)}</name>
            {d3xquery:get-family($id)}
        </root>
    return fn:serialize($json-xml,
                <output:serialization-parameters>
                    <output:method value="json"/>
                    <output:indent value="yes"/>
                    <output:media-type value="application/json"/>
                </output:serialization-parameters>)
else <message>No root node defined. </message>
};

declare function d3xquery:get-name($id as xs:string?){
    if (collection($config:remote-context-root)//tei:person[@xml:id=$id])
        then collection($config:remote-context-root)//tei:person[@xml:id=$id][1]/tei:persName[1]/text()
    else $id
};

declare function d3xquery:get-family($id as xs:string){
    <marriages json:array="true">{(d3xquery:get-spouse($id),d3xquery:get-child($id))}</marriages>
};

declare function d3xquery:get-spouse($id as xs:string){
    for $relation in collection($config:remote-root)//tei:relation[functx:contains-word(@mutual,concat('#',replace($id,'#','')))][@name='spouse']
    for $spouse in tokenize($relation/@mutual,' ')[not(. = concat('#',replace($id,'#','')))]
    let $current-id := replace($spouse,'#','')
    return
    <spouse>
        <name>{d3xquery:get-name($current-id)}</name>
    </spouse>
};

declare function d3xquery:get-child($id as xs:string){
    for $relation in collection($config:remote-root)//tei:relation[functx:contains-word(@active,concat('#',replace($id,'#','')))][@name='parent']
    for $child in tokenize($relation/@passive,' ')
    let $current-id := replace($child,'#','')
    return 
        (
        <children json:array="true">{
            (<name>{d3xquery:get-name($current-id)}</name>,
            d3xquery:get-family($current-id))}
        </children>
        )
};

(:~
 : Output HTML for inclusion on person pages
:)
declare function d3xquery:build-familyTree-html($id as xs:string?) as node()* {
    (<h4>Family Tree</h4>,
    <div id="graph-container" style="margin-left:-5em;"> 
        <script>
            <![CDATA[ 
            $( document ).ready(function() {
            ]]>
                var treeData = {d3xquery:build-familyTree-data($id)};
            <![CDATA[     
                dTree.init(treeData, {target: "#graph",debug: true,height: 400,width: 1200,callbacks: {nodeClick: function(name, extra) {console.log(name);}},
                margin: {
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: -250
                }
                }); 
            });
            ]]>
        </script>
        <div id="graph"></div>
    </div>)
}; 
