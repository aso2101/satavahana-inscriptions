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

(:
 : Display names, not ids
:)
declare function d3xquery:get-name($id as xs:string?){
    if (collection($config:remote-context-root)//tei:person[@xml:id=$id])
        then collection($config:remote-context-root)//tei:person[@xml:id=$id][1]/tei:persName[1]/text()
    else $id
};

(:~
 : Get relationship data from remote-root for specified id. 
 : @param $id required. 
:)
declare function d3xquery:get-related($id as xs:string*){
    if($id != '') then 
        if(contains($id,' ')) then
            for $id in tokenize($id,' ')
            return 
                for $relation in collection($config:remote-root)//tei:relation[matches(@mutual, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))] 
                   | collection($config:remote-root)//tei:relation[matches(@passive, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))] 
                   | collection($config:remote-root)//tei:relation[matches(@active, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))]
                   return $relation
        else 
                for $relation in collection($config:remote-root)//tei:relation[matches(@mutual, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))] 
                   | collection($config:remote-root)//tei:relation[matches(@passive, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))] 
                   | collection($config:remote-root)//tei:relation[matches(@active, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))]
                return $relation 
    else ()  
};

(:~
 : Transform relation data into JSON for dTree
:)
declare function d3xquery:build-familyTree-data($id as xs:string?) {
if($id != '') then
    let $json-xml :=
        <root json:array="true">
            {d3xquery:get-ancestors($id)}
        </root>
    return fn:serialize($json-xml,
                <output:serialization-parameters>
                    <output:method value="json"/>
                    <output:indent value="yes"/>
                    <output:media-type value="application/json"/>
                </output:serialization-parameters>)
else <message>No root node defined. </message>
};

declare function d3xquery:get-ancestors($id as xs:string){
    let $parent := collection($config:remote-root)//tei:relation[matches(@passive, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))][@name='parent'][1]
    return 
        if($parent) then 
            for $relation in $parent
            for $child in tokenize($relation/@active,' ')
            let $current-id := replace($child,'#','')
            return d3xquery:get-ancestors($current-id)
        else (<name>{d3xquery:get-name($id)}</name>,d3xquery:get-family($id))
};

declare function d3xquery:get-family($id as xs:string){
if(d3xquery:get-spouse($id)) then 
    <marriages json:array="true">{(d3xquery:get-spouse($id),d3xquery:get-child($id))}</marriages>
else d3xquery:get-child($id)    
};

declare function d3xquery:get-spouse($id as xs:string){ 
    for $relation in collection($config:remote-root)//tei:relation[matches(@mutual, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))][@name='spouse']
    for $spouse in tokenize($relation/@mutual,' ')[not(. = concat('#',replace($id,'#','')))]
    let $current-id := replace($spouse,'#','')
    return
    <spouse>
        <name>{d3xquery:get-name($current-id)}</name>
    </spouse>
};

declare function d3xquery:get-child($id as xs:string){
    for $relation in collection($config:remote-root)//tei:relation[matches(@active, concat('(^|\s)',concat('#',replace($id,'#',''),'(\s|$)')))][@name='parent']
    for $child in tokenize($relation/@passive,' ')
    let $current-id := replace($child,'#','')
    return 
        (
        <children json:array="true">{
            (<name>{d3xquery:get-name($current-id)}</name>,d3xquery:get-family($current-id))}
        </children>
        )
};

declare function d3xquery:get-expanded-data($data){
    let $uris := distinct-values((for $r in $data return tokenize($r/@active,' '), for $r in $data return tokenize($r/@passive,' '), for $r in $data return tokenize($r/@mutual,' ')))
    for $u in $uris
    return d3xquery:get-related($u)
};

(:~
 : Build JSON data from relationsips. 
 : @param $data pass in TEI relationships. 
:)
declare function d3xquery:build-json-force($data as node()*) {
let $uris := distinct-values((for $r in $data return tokenize($r/@active,' '), for $r in $data return tokenize($r/@passive,' '), for $r in $data return tokenize($r/@mutual,' ')))    
let $json-xml := 
    <root>
        <nodes>{
            for $uri in $uris
            return 
                <json:value>
                    <id>{$uri}</id>
                    <name>{replace($uri,'#','')}</name>
                </json:value>
                }
        </nodes>
        <links>{ 
            for $r in $data
            return  
                if($r/@mutual) then 
                    for $m in tokenize($r/@mutual,' ')
                    return 
                        let $node := 
                            for $p in tokenize($r/@mutual,' ')
                            where $p != $m
                            return 
                                <json:value>
                                    <source>{$m}</source>
                                    <target>{$p}</target>
                                    <relationship>{string($r/@name)}</relationship>
                                    <value>0</value>
                                </json:value>
                        return $node
                else
                    if(contains($r/@active,' ')) then 
                        if(contains($r/@passive,' ')) then 
                            for $a in tokenize($r/@active,' ') 
                            return 
                                for $p in tokenize($r/@passive,' ') 
                                return 
                                    <json:value>
                                        <source>{string($p)}</source>
                                        <target>{string($a)}</target>
                                        <relationship>{string($r/@name)}</relationship>
                                        <value>0</value>
                                    </json:value> 
                        (: multiple active, one passive :)
                        else 
                            let $passive := string($r/@passive)
                            for $a in tokenize($r/@active,' ')
                            return 
                                <json:value>
                                    <source>{string($passive)}</source>
                                    <target>{string($a)}</target>
                                    <relationship>{string($r/@name)}</relationship>
                                    <value>0</value>
                                </json:value>
                    else 
                    (: One active multiple passive :)
                        if(contains($r/@passive,' ')) then 
                            let $active := string($r/@active)
                            for $p in tokenize($r/@passive,' ')
                            return 
                                <json:value>
                                    {if(count($data) = 1) then attribute {xs:QName("json:array")} {'true'} else ()}
                                    <source>{string($p)}</source>
                                    <target>{string($active)}</target>
                                    <relationship>{string($r/@name)}</relationship>
                                    <value>0</value>
                                </json:value>
                        (: One active one passive :)            
                        else 
                            <json:value>
                                {if(count($data) = 1) then attribute {xs:QName("json:array")} {'true'} else ()}
                                <source>{string($r/@passive)}</source>
                                <target>{string($r/@active)}</target>
                                <relationship>{string($r/@name)}</relationship>
                                <value>0</value>
                            </json:value>   
                }
        </links>
    </root>   
return fn:serialize($json-xml,
            <output:serialization-parameters>
                <output:method value="json"/>
                <output:indent value="yes"/>
                <output:media-type value="application/json"/>
            </output:serialization-parameters>)
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
    </div>
    )
}; 



(:~
 : Output HTML for inclusion on person pages
:)
declare function d3xquery:build-force-html($id as xs:string?) as node()* {
    <div id="graph-container" style="margin-left:-5em;"> 
        <script>
            <![CDATA[ 
            $( document ).ready(function() {
            ]]>
                var json = {d3xquery:build-json-force(d3xquery:get-related($id))};
            <![CDATA[     
                d3xquery.initialGraph(json)
            });
            ]]>
        </script>
        <div id="graph"></div>
    </div>
}; 