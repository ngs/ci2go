((deviceName) => {
fetch('/api/v1/user/token', { credentials: 'include' })
.then(r => r.json())
.then(json => {
    var labels = json.map(o => o.label),
        prefix = "Generated on CI2Go " + deviceName
        label = prefix,
        i = 0;
        while(labels.indexOf(label) >= 0) {
            label = prefix + " " + (++i);
        };
        return label
})
.then(label => fetch('/api/v1/user/token', {
    method: 'POST',
    body: JSON.stringify({ label }),
    credentials: 'include',
    headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRFToken': CSRFToken
    }}
 ))
.then(r => r.json())
.then(json => json.token)
.then(token => document.location.href = 'ci2go://ci2go.app/token/' + token)
return "OK"
})
