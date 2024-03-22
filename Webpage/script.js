document.addEventListener("DOMContentLoaded", function() {
    fetch('https://rcc-function-app.azurewebsites.net/api/httptrigger?code=tGN5ZuCL93f420sD1MuP837Y6mfFieGMqQvnhTmHasPRAzFu-688cA%3D%3D')
    .then(response => response.json())
    .then(data => {
        document.getElementById('pageViewsCounter').innerText = "Visitor Count: "+data.count;
    })
    .catch(error => {
        console.error('Error fetching page view count:', error);
        document.getElementById('pageViewsCounter').innerText = 'Unavailable';
    });
});