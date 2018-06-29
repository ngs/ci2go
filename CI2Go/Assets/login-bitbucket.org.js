((email, password) => {
window.$('#js-email-field').val(email);
window.$('#js-password-field').val(password);
return "window.$('#aid-login-form').trigger('submit')";
})
