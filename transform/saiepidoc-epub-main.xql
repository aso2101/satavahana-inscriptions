import module namespace m='http://www.tei-c.org/tei-simple/models/saiepidoc.odd/epub' at '/db/apps/SAI/transform/saiepidoc-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/saiepidoc.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)