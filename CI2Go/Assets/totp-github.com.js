((token) => {
window.document.querySelectorAll('[name="otp"]')[0].value = token;
return "(form => { form.submit(); return 'OK' })(window.document.querySelectorAll('form[action=\"/sessions/two-factor\"]')[0])";
})
