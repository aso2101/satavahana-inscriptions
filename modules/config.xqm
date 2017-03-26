xquery version "3.0";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://www.tei-c.org/tei-simple/config";

import module namespace http="http://expath.org/ns/http-client" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";

declare namespace templates="http://exist-db.org/xquery/templates";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";
declare namespace jmx="http://exist-db.org/jmx";

declare variable $config:default-view := "div";

(:
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root :=
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $config:data-root := "/db/apps/SAI-data/data/";

declare variable $config:remote-root:= substring-before($config:app-root,"SAI") || "SAI-data";
declare variable $config:remote-data-root:= $config:remote-root || "/data";
declare variable $config:remote-context-root:= $config:remote-root || "/contextual";
declare variable $config:remote-img-root:= $config:remote-root || "/images";
declare variable $config:person-authority:= doc(concat($config:remote-context-root, "/listPerson.xml"));
declare variable $config:person-authority-dir:= $config:remote-context-root || "/Persons";
declare variable $config:place-authority:= doc(concat($config:remote-context-root, "/listPlace.xml"));
declare variable $config:place-authority-dir:= $config:remote-context-root || "/Places";
declare variable $config:bibl-authority:= doc(concat($config:remote-context-root, "/listBibl.xml"));
declare variable $config:inventory := doc(concat($config:remote-root, "/textInventory.xml"));
declare variable $config:remote-download-root:= $config:remote-root || "/download";

declare variable $config:odd := "saiepidoc.odd";

declare variable $config:odd-root := $config:app-root || "/resources/odd";
declare variable $config:compiled-odd-root := $config:odd-root || "/compiled";

declare variable $config:output := "transform";

declare variable $config:output-root := $config:app-root || "/" || $config:output;

declare variable $config:module-config := doc($config:odd-root || "/configuration.xml")/*;

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};

(: Try to dynamically determine data directory by calling JMX. :)
declare function config:get-data-dir() as xs:string? {
    try {
        let $request := <http:request method="GET" href="http://localhost:{request:get-server-port()}/{request:get-context-path()}/status?c=disk"/>
        let $response := http:send-request($request)
        return
            if ($response[1]/@status = "200") then
                $response[2]//jmx:DataDirectory/string()
            else
                ()
    } catch * {
        ()
    }
};

declare function config:get-repo-dir() {
    let $dataDir := config:get-data-dir()
    let $pkgRoot := $config:expath-descriptor/@abbrev || "-" || $config:expath-descriptor/@version
    return
        if ($dataDir) then
            $dataDir || "/expathrepo/" || $pkgRoot
        else
            ()
};


declare function config:get-fonts-dir() as xs:string? {
    let $repoDir := config:get-repo-dir()
    return
        if ($repoDir) then
            $repoDir || "/resources/fonts"
        else
            ()
};