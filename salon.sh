#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to the Salmon Salon"

echo -e "\nWhich service would you like to choose?"

# list of services from db, services table

MAIN_MENU() {

  if [[ $1 ]]
    then
    echo $1
  fi

  
  LIST_OF_SERVICES=$($PSQL "SELECT service_id, name FROM services") 
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  SERVICE_NAME_SELECTED=null
  if [[ $SERVICE_ID_SELECTED == '1' ]] 
  then 
    SERVICE_NAME_SELECTED="cut"
  elif [[ $SERVICE_ID_SELECTED == '2' ]] 
  then 
    SERVICE_NAME_SELECTED="wash"
  elif [[ $SERVICE_ID_SELECTED == '3' ]] 
  then 
    SERVICE_NAME_SELECTED="dye"
  fi
  
  MAKE_APPOINTMENT
}
  
MAKE_APPOINTMENT() {

  #check if service_id exists
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_AVAILABLE ]]
  then 
   MAIN_MENU "Please pick an existing service."
   return
  else
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nGreat! A $(echo "$SERVICE_SELECTED" | sed -r 's/^ *| *$//g') it is."
  fi

GET_NUMBER
}

GET_NUMBER() {

  echo -e "What's your phone number?"
  read CUSTOMER_PHONE

  # check if number exists
  PHONE_EXISTS=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $PHONE_EXISTS ]]
    then
    echo "I see this is your first time booking with us. Please provide your name below:"
    read NAME_GIVEN
    echo -e "Thank you, $(echo $NAME_GIVEN | sed -r 's/^ *| *$//g'). We can't wait to see you!"
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$NAME_GIVEN')")
    CUSTOMER_NAME=$NAME_GIVEN
  else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  echo "Looking forward to seeing you again, $CUSTOMER_NAME."
  fi

SET_TIME "$CUSTOMER_NAME"

}

SET_TIME() {
  local NAME=$1
  echo -e "\nWhat time would you like to come in?"
  read SERVICE_TIME
  echo -e "I have put you down for a $(echo $SERVICE_SELECTED | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $NAME | sed -r 's/^ *| *$//g')."

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
}


MAIN_MENU

