import module namespace m='http://www.tei-c.org/tei-simple/models/saiepidoc.odd/latex' at '/db/apps/SAI/transform/saiepidoc-latex.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "class": "article",
    "section-numbers": false(),
    "font-size": "12pt",
    "styles": ["../transform/saiepidoc.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)