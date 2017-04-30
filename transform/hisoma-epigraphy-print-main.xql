import module namespace m='http://www.tei-c.org/pm/models/hisoma-epigraphy/fo' at '/db/apps/SAI/transform/hisoma-epigraphy-print.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/hisoma-epigraphy.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)