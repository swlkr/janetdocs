(function() {
    function printRaw(text) {
        var element = window.Module.outputElement;
        if (element) {
            element.innerHTML += text;
            element.scrollTop = element.scrollHeight; // focus on bottom
        } else {
            console.log("No output element.  Tried to print: " + text);
        }
    }

    function htmlEscape(text) {
        //text = ansi_up.ansi_to_html(text);
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;")
            .replace('\n', '<br>', 'g');
    }

    function cleanContentEditableInput(text) {
        text = text.replace(/\u00A0/g, " ");
        return text;
    }

    function print(text) {
        if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
        printRaw(htmlEscape(text));
    }

    function run_janet_code(code, outputElement) {
        outputElement.innerHTML = "";
        window.Module.outputElement = outputElement;
        let cleanCode = cleanContentEditableInput(code);
        let result = window.run_janet(cleanCode);
        if (result != 0)
            window.Module.printErr("ERROREXIT: " + result + "\n");
    }

    var Module = {
        outputElement: null,
        preRun: [function() {console.log("prerun");}],
        print: function(x) {
            print(x + '\n');
        },
        printErr: function(text) {
            if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
            printRaw('<span style="color:#E55;">' + htmlEscape(text + '\n') + '</span>')
        },
        postRun: [function() {
            console.log("starting postrun");
            window.run_janet_code = run_janet_code;
            window.run_janet = Module.cwrap("run_janet", 'number', ['string']);
            console.log("finished postrun");
        }],
    };

    window.Module = Module;
})();
