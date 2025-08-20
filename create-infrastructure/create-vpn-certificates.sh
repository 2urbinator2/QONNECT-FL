## Root Zertifikat
# Create root certificate
openssl req -x509 -sha256 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout root.key \
  -out root.cer \
  -subj "/CN=VPNRoot"

# Create Client certificate
openssl req -new -nodes -newkey rsa:2048 \
  -keyout client.key \
  -out client.csr \
  -subj "/CN=VPNClient"

openssl x509 -req -in client.csr \
  -CA root.cer -CAkey root.key -CAcreateserial \
  -out client.cer -days 365 -sha256

