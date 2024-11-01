#!/bin/bash

API_KEY="63fc28e75ec11d3914e2f0d72ba6f595"
OUTPUT_FILE="weather_data.json"

# Function to get current date
get_current_date() {
    date +"%Y-%m-%d"
}

# Function to fetch and display current weather
fetch_weather() {
    local city="$1"
    local date_today=$(get_current_date)

    # Fetch weather data from the API
    response=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${API_KEY}&units=metric")
    if [[ $(echo "$response" | jq -r '.cod') == "200" ]]; then
        # Extract data
        local weather=$(echo "$response" | jq -r '.weather[0].main')
        local temp=$(echo "$response" | jq -r '.main.temp')
        local humidity=$(echo "$response" | jq -r '.main.humidity')
        local wind_speed=$(echo "$response" | jq -r '.wind.speed')

        # Display the weather report
        echo "Weather in $city:"
        echo "----------------------------"
        echo "Condition   : $weather"
        echo "Temperature : ${temp}°C"
        echo "Humidity    : ${humidity}%"
        echo "Wind Speed  : ${wind_speed} m/s"
        echo "----------------------------"

        # Prepare JSON data to save
        report=$(jq -n \
            --arg city "$city" \
            --arg date "$date_today" \
            --arg weather "$weather" \
            --arg temp "$temp" \
            --arg humidity "$humidity" \
            --arg wind_speed "$wind_speed" \
            '{
                "city": $city,
                "date": $date,
                "weather": $weather,
                "temperature": $temp,
                "humidity": $humidity,
                "wind_speed": $wind_speed
            }')

        # Append or update weather data in the JSON file
        if [ -f "$OUTPUT_FILE" ]; then
            jq --argjson report "$report" '. += [$report]' "$OUTPUT_FILE" > tmp.$$.json && mv tmp.$$.json "$OUTPUT_FILE"
        else
            echo "[$report]" > "$OUTPUT_FILE"
        fi

        echo "Weather report saved to $OUTPUT_FILE."
    else
        echo "Error fetching weather data: $(echo "$response" | jq -r '.message')"
    fi
}

# Function to search for a weather report by city and date
search_weather() {
    local city="$1"
    local date="$2"

    if [ -f "$OUTPUT_FILE" ]; then
        result=$(jq --arg city "$city" --arg date "$date" '.[] | select(.city == $city and .date == $date)' "$OUTPUT_FILE")
        if [[ -n "$result" ]]; then
            echo "Weather report for $city on $date:"
            printf "%-12s | %-15s | %-13s | %-10s | %-12s\n" "Date" "Weather" "Temperature" "Humidity" "Wind Speed"
            echo "------------------------------------------------------------------------"
            echo "$result" | jq -r '"\(.date)       | \(.weather)        | \(.temperature)°C        | \(.humidity)%        | \(.wind_speed) m/s"'
            echo "------------------------------------------------------------------------"
        else
            echo "No results found for $city on $date."
        fi
    else
        echo "No weather data available. Run the script to fetch weather information first."
    fi
}

# Function to display all records for a specific city
display_city_records() {
    local city="$1"

    if [ -f "$OUTPUT_FILE" ]; then
        results=$(jq --arg city "$city" '.[] | select(.city == $city)' "$OUTPUT_FILE")
        if [[ -n "$results" ]]; then
            echo "All weather records for $city:"
            printf "%-12s | %-15s | %-13s | %-10s | %-12s\n" "Date" "Weather" "Temperature" "Humidity" "Wind Speed"
            echo "------------------------------------------------------------------------"
            echo "$results" | jq -r '"\(.date)       | \(.weather)        | \(.temperature)°C        | \(.humidity)%        | \(.wind_speed) m/s"'
            echo "------------------------------------------------------------------------"
        else
            echo "No records found for $city."
        fi
    else
        echo "No weather data available. Run the script to fetch weather information first."
    fi
}

# Function to display records for all cities within a date range
display_records_in_range() {
    local start_date="$1"
    local end_date="$2"

    if [ -f "$OUTPUT_FILE" ]; then
        results=$(jq --arg start_date "$start_date" --arg end_date "$end_date" \
            '.[] | select(.date >= $start_date and .date <= $end_date)' "$OUTPUT_FILE")

        if [[ -n "$results" ]]; then
            echo "Weather records from $start_date to $end_date for all cities:"
            printf "%-12s | %-10s | %-15s | %-13s | %-10s | %-12s\n" "Date" "City" "Weather" "Temperature" "Humidity" "Wind Speed"
            echo "-----------------------------------------------------------------------------------------------"
            echo "$results" | jq -r '"\(.date)       | \(.city)         | \(.weather)        | \(.temperature)°C        | \(.humidity)%        | \(.wind_speed) m/s"'
            echo "-----------------------------------------------------------------------------------------------"
        else
            echo "No records found within the date range."
        fi
    else
        echo "No weather data available. Run the script to fetch weather information first."
    fi
}

# Main menu
while true; do
    echo "Choose an option:"
    echo "1. Check current weather"
    echo "2. Search past weather report by city and date"
    echo "3. Display all past records for a city"
    echo "4. Display records for all cities in a specific date range"
    echo "5. Exit"
    read -p "Enter choice [1-5]: " choice

    case $choice in
        1)
            read -p "Enter the city name: " city
            fetch_weather "$city"
            ;;
        2)
            read -p "Enter the city name: " city
            read -p "Enter the date (YYYY-MM-DD): " date
            search_weather "$city" "$date"
            ;;
        3)
            read -p "Enter the city name: " city
            display_city_records "$city"
            ;;
        4)
            read -p "Enter the start date (YYYY-MM-DD): " start_date
            read -p "Enter the end date (YYYY-MM-DD): " end_date
            display_records_in_range "$start_date" "$end_date"
            ;;
        5)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice, please enter a number between 1 and 5."
            ;;
    esac
done
