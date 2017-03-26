$('.app').each(function() { // Notice the .each() loop, discussed below
    $(this).qtip({
        content: {
            text: $(this).find('.appcontainer') // Use the "div" element next to this for the content
        }
    });
});