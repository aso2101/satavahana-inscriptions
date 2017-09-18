//Sets up force directed graph   d3 v3 
var w = 900,
    h = 400,
    damper = 0.1,
    padding = 10,
    color = d3.scale.category20c();
    
var d3xquery = {
    version: "d3xquery.js version 2017-09-07"
}

d3xquery.initialGraph = function (json) {
    //Now in render() function
    svg = d3.select("#graph").append("svg:svg").attr("preserveAspectRatio", "xMinYMin meet").attr("viewBox", "0 0 " + w + " " + h).classed("svg-content-responsive", true);    
    //Tooltip for mouseover
    tooltip = d3.select("body").append("div").attr("class", "toolTip").style("position", "absolute").style("z-index", "10").style("visibility", "hidden").style("background-color", "white").style("padding", "5px").text("a simple tooltip");
    forcegraph(json);
};


function forcegraph(json) {
    //Var for edges
    var edges =[];
    
    //Relationship is mapped to type in edges.
    json.links.forEach(function (e) {
            var sourceNode = json.nodes.filter(function (n) {
                return n.id === e.source;
            })[0],
            targetNode = json.nodes.filter(function (n) {
                return n.id === e.target;
            })[0];
            //Check for and suppress null values
            if (sourceNode != null && targetNode != null){
                edges.push({
                    source: sourceNode,
                    target: targetNode,
                    type: e.relationship
                });                
            }
    });
           
    //Set force graph variables
    var force = d3.layout.force().nodes(json.nodes).links(edges).size([w, h]).linkDistance([150]).charge([-500]).theta(0.1).gravity(0.05).start();
        
    //Add links for relationships
    var link = svg.selectAll("line").data(force.links()).enter().append("svg:line").attr("class", "link forceNode").attr("id", function (d, i) {
            return 'edge' + i
        }).style("stroke", "#ccc").call(force.drag);
        
    //Add svg:g to group nodes and nodelabels
    var node = svg.selectAll(".node").data(force.nodes()).enter().append("svg:g").call(force.drag);
        
    //Add circles to group
    var circle = node.append("svg:circle").attr("r", "15")
        .attr("class", "forceNode").style("fill", function (d) {
            return color(d.id);
        }).style("stroke", function (d) {
            return d3.rgb(color(d.id)).darker();
        }).on("click", function (d) {
            getNodeInfo(d.id);
        }).on("mouseover", function (d) {
            d3.select(this).attr("r", function (d) {
                return (d.weight * .75) + 15
            });
        }).on("mouseout", function (d) {
            d3.select(this).attr("r", function (d) {
                return (d.weight * .5) + 6
            });
        }).call(force.drag);
    
    //Label nodes/circles    
    var nodelabels = node.append("svg:text").attr({
            "x": function (d) {
                return d.x - 20;
            },
            "y": function (d) {
                return d.y - 10;
            },
            "class": "nodelabel forceNode",
            "stroke": "#666666"
        }).text(function (d) {
            return d.name;
        });
    
    //Create edges    
    var edgepaths = svg.selectAll(".edgepath").data(edges).enter().append('svg:path').attr({
            'd': function (d) {
                return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y
            },
            'class': 'edgepath forceNode',
            'fill-opacity': 0,
            'stroke-opacity': 0,
            'fill': 'blue',
            'stroke': 'red',
            'id': function (d, i) {
                return 'edgepath' + i
            }
        }).style("pointer-events", "none");
    
    //Label edges    
    var edgelabels = svg.selectAll(".edgelabel").data(edges).enter().append('svg:text').style("pointer-events", "none").attr({
            'class': 'edgelabel forceNode',
            'id': function (d, i) {
                return 'edgelabel' + i
            },
            'dx': 50,
            'dy': 0,
            'font-size': 10,
            'fill': '#aaa'
        });
   //Label edges, add text     
   edgelabels.append('svg:textPath').attr('xlink:href', function (d, i) {
            return '#edgepath' + i
        }).style("pointer-events", "none").text(function (d, i) {
            return d.type
        });
        
    //Connecting linked nodes on click, fade in out relationships
    node.on("mouseover", fade(.1));
    node.on("mouseout", fade(1));
    var linkedByIndex = { };
        
    edges.forEach(function (d) {
            linkedByIndex[d.source.index + "," + d.target.index] = 1;
    });
        
    function isConnected(a, b) {
            return linkedByIndex[a.index + "," + b.index] || linkedByIndex[b.index + "," + a.index] || a.index == b.index;
    }
        
    function neighboring(a, b) {
            return edges.some(function (d) {
                return (d.source === a && d.target === b) || (d.source === b && d.target === a) ? d.type: d.type;
            });
    }
        
    //Highlight related
    function fade(opacity) {
            return function (d) {
                node.style("stroke-opacity", function (o) {
                    thisOpacity = isConnected(d, o) ? 1: opacity;
                    this.setAttribute('fill-opacity', thisOpacity);
                    return thisOpacity;
                    return isConnected(d, o);
                });
                
                link.style("stroke-opacity", opacity).style("stroke-opacity", function (o) {
                    return o.source === d || o.target === d ? 1: opacity;
                });
                
                edgelabels.style("fill-opacity", opacity).style("fill-opacity", function (o) {
                    return o.source === d || o.target === d ? 1: opacity;
                });
            };
    };
        
    //Return names and descriptions
    //Trying to get relationships
    function getNodeInfo(uri) {
            $.get("get-names.xql", {
                id: uri
            }).done(function (data) {
                $("#info-box").html(data);
            });
    }
        
        
    force.on("tick", function () {
            circle.attr("cx", function (d) {
                return d.x = Math.max(15, Math.min(w - 15, d.x));
            }).attr("cy", function (d) {
                return d.y = Math.max(15, Math.min(h - 15, d.y));
            });
            node.attr("cx", function (d) {
                return d.x = Math.max(15, Math.min(w - 15, d.x));
            }).attr("cy", function (d) {
                return d.y = Math.max(15, Math.min(h - 15, d.y));
            });
            
            link.attr({
                "x1": function (d) {
                    return d.source.x;
                },
                "y1": function (d) {
                    return d.source.y;
                },
                "x2": function (d) {
                    return d.target.x;
                },
                "y2": function (d) {
                    return d.target.y;
                }
            });
            
            nodelabels.attr("x", function (d) {
                return d.x + 10;
            }).attr("y", function (d) {
                return d.y;
            });
            
            edgepaths.attr('d', function (d) {
                var path = 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y;
                //console.log(d)
                return path
            });
            
            edgelabels.attr('transform', function (d, i) {
                if (d.target.x < d.source.x) {
                    bbox = this.getBBox();
                    rx = bbox.x + bbox.width / 2;
                    ry = bbox.y + bbox.height / 2;
                    return 'rotate(180 ' + rx + ' ' + ry + ')';
                } else {
                    return 'rotate(0)';
                }
            });
    });

//Create filter based on type
    createFilter();
    // Method to create the filter, generate checkbox options on fly
    // force.links()
    //unique links: http://stackoverflow.com/questions/28572015/how-to-select-unique-values-in-d3-js-from-data
    //use d3.map to get unique values from data
    function createFilter() {
              d3.select(".filterContainer").selectAll("div")
                .data(d3.map(edges, function(d){return d.type;}).keys())
                .enter()  
                .append("div")
                .attr("class", "checkbox-container")
                .append("label")
                .each(function (d) {
                       d3.select(this).append("svg:rect")
                            .attr("width", 10)
                            .attr("height", 10)
                      // create checkbox for each data
                      d3.select(this).append("input")
                        .attr("type", "checkbox")
                        .attr("id", function (d) {
                            return "chk_" + d;
                         })
                         .attr("class", function (d) {
                            return "chk " + d;
                         })
                        .attr("checked", true)
                        .on("click", function (d, i) {
                            // register on click event
                            var lVisibility = this.checked ? "visible" : "hidden";
                            filterGraph(d, lVisibility);
                         })
                      d3.select(this).append("span")
                          .text(function (d) {
                              return d;
                          });
              });
              $("#sidebar").show();
              console.log(d3.map(force.links, function(d){return d.type;}).keys());
          }
          
    function filterGraph(aType, aVisibility) {
            // change the visibility of the connection path
            link.style("visibility", function (o) {
                var lOriginalVisibility = $(this).css("visibility");
                return o.type === aType ? aVisibility : lOriginalVisibility;
            });
            
            edgelabels.style("visibility", function (o) {
                var lOriginalVisibility = $(this).css("visibility");
                return o.type === aType ? aVisibility : lOriginalVisibility;
            });
    
            // change the visibility of the node
            // if all the links with that node are invisibile, the node should also be invisible
            // otherwise if any link related to that node is visibile, the node should be visible
            node.style("visibility", function (o, i) {
                var lHideNode = true;
                link.each(function (d, i) {
                    if (d.source === o || d.target === o) {
                        if ($(this).css("visibility") === "visible") {
                            lHideNode = false;
                            // we need show the text for this circle
                            d3.select(d3.selectAll(".nodeText")[0][i]).style("visibility", "visible");
                            return "visible";
                        }
                    }
                });
                
                if (lHideNode) {
                    // we need hide the text for this circle 
                    d3.select(d3.selectAll(".nodeText")[0][i]).style("visibility", "hidden");
                    return "hidden";
                }
            });
        }
};
