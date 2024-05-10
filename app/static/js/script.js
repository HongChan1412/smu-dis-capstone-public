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


