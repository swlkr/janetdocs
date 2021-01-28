(function() {
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

    function print(text, isErr=false) {
        //if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
        var element = window.Module.outputElement;
        if (typeof(element) == "string") {
            window.Module.outputElement += text;
        } else if (!element) {
            console.log("No output element.  Tried to print: " + text);
        } else {
            if (isErr) {
                element.innerHTML += '<span style="color:#E55;">' + htmlEscape(text + '\n') + '</span>';
            } else {
                element.innerHTML += htmlEscape(text);
            }
            element.scrollTop = element.scrollHeight; // focus on bottom
        }
    }

    function run_janet_for_output(code) {
        window.Module.outputElement = "";
        let cleanCode = cleanContentEditableInput(code);
        let result = window.run_janet(cleanCode);
        if (result != 0) {
            return "ERROR: " + result + "\n" + window.Module.outputElement;
        } else {
            return window.Module.outputElement;
        }
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
        preRun: [],
        print: function(x) {
            print(x + '\n', isErr=false);
        },
        printErr: function(text) {
            if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
            print(text + "\n", isErr=true);
        },
        postRun: [function() {
            window.run_janet_code = run_janet_code;
            window.run_janet_for_output = run_janet_for_output;
            window.run_janet = Module.cwrap("run_janet", 'number', ['string']);
        }],
    };

    window.Module = Module;
})();
