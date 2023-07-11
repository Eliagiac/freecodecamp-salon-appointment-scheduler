#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES_STRING=$($PSQL "SELECT service_id, name FROM services")

PRINT_SERVICES() {
  echo "$SERVICES_STRING" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

SELECT_SERVICE() {
  PRINT_SERVICES
  read SERVICE_ID_SELECTED

  # Ensure the input is a number.
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nPlease insert a number."
    SELECT_SERVICE
  fi

  # Ensure the selected service is valid.
  VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $VALID_SERVICE ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    SELECT_SERVICE
  else
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi
}

GET_CUSTOMER_ID() {
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Add new customer if not on record.
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
}

STORE_APPOINTMENT() {
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
}

echo -e "Welcome to My Salon, how can I help you?\n"
SELECT_SERVICE

echo -e "\nWhat's your phone number?"
GET_CUSTOMER_ID

echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
STORE_APPOINTMENT

echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
