import module namespace m='http://www.tei-c.org/pm/models/sai-customizations/epub' at '/db/apps/SAI/transform/sai-customizations-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/sai-customizations.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)