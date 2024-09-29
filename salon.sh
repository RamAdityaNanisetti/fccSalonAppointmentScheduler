#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  echo -e $1

  SERVICES=$($PSQL " SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU

read SERVICE_ID_SELECTED
SERVICE_AVAILABILITY=$($PSQL " SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED ")
if [[ -z $SERVICE_AVAILABILITY ]]
then
 MAIN_MENU "\nPlease select a valid service\n"
 else
  echo -e "\n Please enter your phone number"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL " SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' ")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\n Please enter your name"
    read CUSTOMER_NAME
    echo "$($PSQL " INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ")"
    CUSTOMER_ID=$($PSQL " SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' ")
  else 
    CUSTOMER_NAME=$($PSQL " SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' ")
  fi
  
  echo -e "\n Please enter the time"
  read SERVICE_TIME
  echo "$($PSQL " INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ")"
  SERVICE=$($PSQL " SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED ")
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
fi
