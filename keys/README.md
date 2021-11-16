# Keys

To test the iframe functionality we need to add SSL to our development environment. For this we use self-signed certificates. The following section describes how to create such a certificate for dev environments running on `localhost`.

## Create and use a self signed certificate for localhost

Following this tutorial: https://www.section.io/engineering-education/how-to-get-ssl-https-for-localhost/ the following commands create a self signed certificate for localhost using **Windows PowerShell**.

We use openssl via docker: `docker run -ti --rm -v ${pwd}:/apps -w /apps alpine/openssl`

- `function Docker-Openssl { docker run -ti --rm -v ${pwd}:/apps -w /apps alpine/openssl $args }`
- `Set-Alias openssl  Docker-Openssl`
- `openssl genrsa -out CA.key`
- `openssl req -x509 -sha256 -new -nodes -days 3650 -key CA.key -out CA.pem`
- `touch localhost.ext` and edit as descriped in tutorial
- `openssl genrsa -out localhost.key`
- `openssl req -new -key localhost.key -out localhost.csr`
- `openssl x509 -req -in localhost.csr -CA CA.pem -CAkey CA.key -CAcreateserial -days 3650 -sha256 -extfile localhost.ext -out localhost.crt`
- `openssl rsa -in localhost.key -out localhost.decrypted.key`
- Add CA.pem to trusted root certificates in browser (e.g. via chrome://settings/security in Chrome) and restart browser