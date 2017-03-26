import module namespace m='http://www.tei-c.org/tei-simple/models/saiepidoc.odd/web' at '/db/apps/SAI/transform/saiepidoc-web.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/saiepidoc.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)