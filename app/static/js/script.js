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
        localStorage.setItem("targetIp", document.getElementById('ip').value)
        localStorage.setItem("targetPort", document.getElementById('port').value)
        localStorage.setItem("targetUser", document.getElementById('user').value)
        localStorage.setItem("targetPasswd", document.getElementById('passwd').value)
        const targetIp = localStorage.getItem("targetIp");
        const targetPort = localStorage.getItem("targetPort");
        const targetUser = localStorage.getItem("targetUser");
        const targetPasswd = localStorage.getItem("targetPasswd");
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
    if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send('disconnect');
        // 필요하다면 여기서 ws.close()를 호출하여 명시적으로 연결을 닫을 수 있습니다.
    }
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


let lastChecked;

window.onload = function() {
    const checkboxes = document.querySelectorAll('#checkboxForm input[type="checkbox"]');

    checkboxes.forEach((checkbox) => {
        checkbox.onclick = (e) => {
            if (lastChecked && lastChecked !== checkbox) {
                lastChecked.checked = false;
            }
            lastChecked = checkbox.checked ? checkbox : null;
            
            // 체크박스 클릭할 때마다 결과를 업데이트합니다.
            showSelectedOption();
        };
    });
};

function showSelectedOption() {
    const checkboxes = document.querySelectorAll('#checkboxForm input[type="checkbox"]');
    let selectedOption = 'None';

    checkboxes.forEach((checkbox) => {
        if (checkbox.checked) {
            selectedOption = checkbox.value;
        }
    });

    document.getElementById('result').innerText = "Selected option: " + selectedOption;
}

// 버튼 토글 
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.toggle-button').forEach(function(button) {
        button.addEventListener('click', function() {
            var content = this.nextElementSibling;
            if (content.classList.contains('hidden')) {
                content.classList.replace('hidden', 'visible');
                this.textContent = '▲ Details';
            } else {
                content.classList.replace('visible', 'hidden');
                this.textContent = '▼ Details';
            }
        });
    });
});


