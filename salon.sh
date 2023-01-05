#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Barney's Turbo Mowers ~~~~~\n"
echo -e "Welcome to Barney's Turbo Mowers, how can I help you?\n"
  # echo -e "\n1) cut\n2) shave\n3) style\n4) color\n5) harvest"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo -e "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  # if input does not exist in services
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
  then
    # Send back to main menu if selected service input does not exist.
    MAIN_MENU "Service not found. Which treatment would you like?"
  else
    # Ask for phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT TRIM(name) 
                            FROM customers 
                            WHERE phone = '$CUSTOMER_PHONE'")
    # if the customer is not saved to the db yet
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Ask for name
      echo -e "\nOh you are a new customer. Come up with your name, friend."
      read CUSTOMER_NAME
      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone)
                                        VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    # Get selected service name
    SERVICE=$($PSQL "SELECT TRIM(name) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # Ask for appointment time
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # echo this is your data $CUSTOMER_ID $CUSTOMER_NAME
    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time)
                                        VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
