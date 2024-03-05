var ws;

function enableButtons() {
    document.getElementById('connect').disabled = true;
    document.getElementById('send').disabled = false;
    document.getElementById('disconnect').disabled = false;
}

function disableButtons() {
    document.getElementById('connect').disabled = false;
    document.getElementById('send').disabled = true;
    document.getElementById('disconnect').disabled = true;
}

function connect() {
    var url = "ws://localhost:8000/hc/ws/" + document.getElementById('ip').value +
        "/" + document.getElementById('port').value +
        "/" + document.getElementById('user').value +
        "/" + document.getElementById('passwd').value;
    ws = new WebSocket(url);

    ws.onopen = function(event) {
        log('Connection opened');
        enableButtons();
    };

    ws.onmessage = function(event) {
        if (event.data === 'Disconnected') {
            log('Connection closed');
            ws.close();
            disableButtons();
        } else {
            log('Received: ' + event.data);
        }
    };
}

function disconnect() {
    ws.send('disconnect');
}

function send() {
    var message = document.getElementById('command').value;
    ws.send(message);
    log('Sent: ' + message);
}

function log(text) {
    var li = document.createElement('li');
    li.innerText = text;
    document.getElementById('log').appendChild(li);
}
