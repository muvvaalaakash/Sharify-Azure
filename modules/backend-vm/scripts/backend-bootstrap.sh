#!/bin/bash
# Exit on error
set -e

# Update packages and install python, pip, git, and other tools
apt-get update
apt-get install -y python3-pip python3-venv git libpq-dev python3-dev

# Clone the repository
mkdir -p /opt
git clone https://github.com/muvvaalaakash/Shareify.git /opt/Shareify

# Create a virtual environment
python3 -m venv /opt/venv
source /opt/venv/bin/activate
pip install --upgrade pip
pip install uvicorn fastapi pydantic passlib[bcrypt] pyjwt httpx psycopg2-binary

# Set up systemd service files for each service
services=("user" "item" "inventory" "booking" "payment" "review" "api-gateway")
ports=("8001" "8002" "8003" "8004" "8005" "8006" "8000")
db_names=("users_db" "items_db" "inventory_db" "bookings_db" "payments_db" "reviews_db" "")

# Make sure directory for services exists
mkdir -p /etc/systemd/system

for i in "$${!services[@]}"; do
  name="$${services[i]}"
  port="$${ports[i]}"
  db_name="$${db_names[i]}"
  
  if [ "$name" == "api-gateway" ]; then
    workdir="/opt/Shareify/api-gateway"
    env_vars="Environment=\"USER_SERVICE_URL=http://127.0.0.1:8001\"
Environment=\"ITEM_SERVICE_URL=http://127.0.0.1:8002\"
Environment=\"INVENTORY_SERVICE_URL=http://127.0.0.1:8003\"
Environment=\"BOOKING_SERVICE_URL=http://127.0.0.1:8004\"
Environment=\"PAYMENT_SERVICE_URL=http://127.0.0.1:8005\"
Environment=\"REVIEW_SERVICE_URL=http://127.0.0.1:8006\""
  else
    workdir="/opt/Shareify/$name-service"
    # URL encode the password to prevent connection string parsing issues
    ENCODED_PASS=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''${db_password}''').replace('%', '%%'))")
    env_vars="Environment=\"DATABASE_URL=postgresql://${db_user}:$ENCODED_PASS@${db_host}/$db_name?sslmode=require\"
Environment=\"JWT_SECRET=shareify-secret-key-2024\"
Environment=\"TOKEN_EXPIRE_MINUTES=60\"
Environment=\"ITEM_SERVICE_URL=http://127.0.0.1:8002\"
Environment=\"INVENTORY_SERVICE_URL=http://127.0.0.1:8003\"
Environment=\"PAYMENT_SERVICE_URL=http://127.0.0.1:8005\""
  fi

  cat <<EOF > /etc/systemd/system/shareify-$name.service
[Unit]
Description=Shareify $name Service
After=network.target

[Service]
User=root
WorkingDirectory=$workdir
ExecStart=/opt/venv/bin/uvicorn main:app --host 0.0.0.0 --port $port
Restart=always
$env_vars

[Install]
WantedBy=multi-user.target
EOF

  if [ "$name" == "api-gateway" ]; then
    # Patch the hardcoded Kubernetes hostnames inside the Python code to use localhost loopback addresses
    sed -i -E 's/"http:\/\/shareify-([a-z]+)-service:[0-9]+"/"http:\/\/127.0.0.1:800"/g' /opt/Shareify/api-gateway/main.py
    # Specific port fixes for the sed replacement:
    sed -i 's/"http:\/\/127.0.0.1:800"/"http:\/\/127.0.0.1:8001"/g' /opt/Shareify/api-gateway/main.py | true
    # Actually, let's just do precise replacements to be safe
    sed -i 's/"http:\/\/shareify-user-service:8000"/"http:\/\/127.0.0.1:8001"/g' /opt/Shareify/api-gateway/main.py
    sed -i 's/"http:\/\/shareify-item-service:8000"/"http:\/\/127.0.0.1:8002"/g' /opt/Shareify/api-gateway/main.py
    sed -i 's/"http:\/\/shareify-inventory-service:8000"/"http:\/\/127.0.0.1:8003"/g' /opt/Shareify/api-gateway/main.py
    sed -i 's/"http:\/\/shareify-booking-service:8000"/"http:\/\/127.0.0.1:8004"/g' /opt/Shareify/api-gateway/main.py
    sed -i 's/"http:\/\/shareify-payment-service:8000"/"http:\/\/127.0.0.1:8005"/g' /opt/Shareify/api-gateway/main.py
    sed -i 's/"http:\/\/shareify-review-service:8000"/"http:\/\/127.0.0.1:8006"/g' /opt/Shareify/api-gateway/main.py
  fi

  systemctl daemon-reload
  systemctl enable shareify-$name
  systemctl start shareify-$name
done
