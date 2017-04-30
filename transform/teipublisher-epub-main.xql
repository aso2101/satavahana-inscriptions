import module namespace m='http://www.tei-c.org/pm/models/teipublisher/epub' at '/db/apps/SAI/transform/teipublisher-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/teipublisher.css"],
    "collection": "/db/apps/SAI/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)