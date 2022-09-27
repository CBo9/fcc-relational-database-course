#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"


MAIN_MENU(){
    # display parameter if present
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    echo -e "\n~~ Welcome to our salon ~~\n"
    echo -e "Choose a service:\n"

    # get services and display list then ask for selection
    SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
    echo "$SERVICES" | sed 's/|/) /g'
    read SERVICE_ID_SELECTED

    # if not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        # send to main menu
        MAIN_MENU "It is not a valid service ID. Try again."
    else
        # check for service in services table
        SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

        # if service not found
        if [[ -z $SERVICE ]]
        then
            # send to main menu
            MAIN_MENU "The ID you entered in not associated with any service."
        else
            # ask for phone number
            echo -e "\nEnter your phone number:"
            read CUSTOMER_PHONE

            # get name if phone exists
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

            # if customer not registered
            if [[ -z $CUSTOMER_NAME ]]
            then
                # get name
                echo -e "\nPlease enter your name:"
                read CUSTOMER_NAME

                # insert new customer
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
            fi

            # get customer id
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

            # ask for time
            echo -e "\nAt what time would you like to come to the salon?"
            read SERVICE_TIME

            # insert new appointment
            INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
            echo -e "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
    fi
}

MAIN_MENU