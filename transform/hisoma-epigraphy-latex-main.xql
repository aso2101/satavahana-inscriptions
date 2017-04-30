import module namespace m='http://www.tei-c.org/pm/models/hisoma-epigraphy/latex' at '/db/apps/SAI/transform/hisoma-epigraphy-latex.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "class": "article",
    "section-numbers": false(),
    "font-size": "12pt",
    "styles": ["../transform/hisoma-epigraphy.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)