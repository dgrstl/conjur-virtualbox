# This will allow `puppet module install` from Windows hosts as
# detailed here: https://docs.puppetlabs.com/windows/troubleshooting.html#error-messages

& certutil -addstore Root C:\vagrant\scripts\certs\GeoTrust_Global_CA.pem
