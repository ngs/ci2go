((email, password) => {
window.$('[name=token]').val(email);
return "($ => { $('#second-factor-form').trigger('submit'); return 'OK' })(window.$)";
})
