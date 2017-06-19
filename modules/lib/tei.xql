xquery version "3.1";

(: Output TEI XML version of the data :)

import module namespace config="http://www.tei-c.org/tei-simple/config" at "../config.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: may need to test for data type (inscription, person, place, bibl) :)
collection($config:remote-root)//id(request:get-parameter('id', ''))