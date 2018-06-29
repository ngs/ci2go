((login, password) => {
window.document.querySelectorAll('[name="login"]')[0].value = login;
window.document.querySelectorAll('[name="password"]')[0].value = password;
 return "(form => { form.submit(); return 'OK' })(window.document.querySelectorAll('form[action=\"/session\"]')[0])";
})
