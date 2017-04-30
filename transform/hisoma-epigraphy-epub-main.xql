import module namespace m='http://www.tei-c.org/pm/models/hisoma-epigraphy/epub' at '/db/apps/SAI/transform/hisoma-epigraphy-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/hisoma-epigraphy.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)