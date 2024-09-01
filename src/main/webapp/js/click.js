// script.js
document.querySelector('body').addEventListener('click', function(event) {
    var parent = window.opener || window.parent;

    parent.postMessage(JSON.stringify({
        event: 'clickDrawio'
    }), '*');
});