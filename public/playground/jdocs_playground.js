window.addEventListener("load", function (ev) {

    console.log("setting editor...");
    window.editor = ace.edit("code");
    window.editor.session.setMode("ace/mode/clojure");
    editor.commands.addCommand({
        name: 'run',
        bindKey: {win: 'Ctrl-Enter',  mac: 'Ctrl-Enter'},
        exec: function(editor) {
            window.doRunCode();
        },
        readOnly: true // false if this command should not apply in readOnly mode
    });
    console.log("editor set");

    function doRunCode() {
        let outputEl = document.querySelector('#output');
        outputEl.innerHTML = "running...";
        let code = window.editor.getValue();
        setTimeout(function() {window.run_janet_code(code, outputEl)}, 0);
    }

    document.querySelector("#run").addEventListener("click", function (e) {
        doRunCode();
    });

    document.querySelector("#format").addEventListener("click", function (e) {
        alert("Coming soon! (we hope)");
    });

    window.doRunCode = doRunCode;
});

