# Mail Check

Check whether an email or domain belongs to a free, professional or disposable mail provider.

```sh
➲ encoded=$(echo nick@x.a.betr.co | base64)
➲ curl -s "http://localhost:3000/mail_check/$encoded" | json_pp
```

```json
{
  "status": "disposable",
  "match": "subdomain",
  "score": -0.875,
  "found": 2,
  "free": 0,
  "disposable": 14,
  "summarize": true,
  "ascii": "x.a.betr.co",
  "unicode": "x.a.betr.co",
  "domain": "betr.co",
  "tld": "co",
  "data": {
     "betr.co": {
        "free": 0,
        "disposable": 9
     },
     "a.betr.co": {
        "disposable": 5,
        "free": 0
     }
  },
  "read_more": "https://github.com/nikhgupta/mail_provider",
}
```
