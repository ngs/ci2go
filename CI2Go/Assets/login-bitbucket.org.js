((email, password) => {
window.$('#js-email-field').val(email);
window.$('#js-password-field').val(password);
return "($ => { $('#aid-login-form').trigger('submit'); return 'OK' })(window.$)";
})
