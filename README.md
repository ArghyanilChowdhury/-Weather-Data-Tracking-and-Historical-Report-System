Step-by-Step Guide for running this project in Linux:

1. Install curl (if not installed): 

curl should be pre-installed on your Linux Distribution, but if not, you can install it with:

"sudo dnf install curl"

Check if it’s installed by running:

"curl --version"

2. Sign Up and Get Your API Key from OpenWeatherMap:

a) Sign up at OpenWeatherMap and get an API key.
b) Save the API key as you'll need it for the script.

3. Create the Bash Script:

Open a terminal and use a text editor to create a new file called weather_checker.sh:

"nano weather_checker.sh"

This opens the nano editor where you can enter the code.

4. Write the Weather Checker Script:

Copy and paste the code from "weather_checker.sh", replacing YOUR_API_KEY with your OpenWeatherMap API key.

5. Make the Script Executable:

To run the script, you need to make it executable:

"chmod +x weather_checker.sh"

6. Run the Script:

Now, you can use the script to check the weather:

"./weather_checker.sh"


The aim of this practical is to develop a weather data tracking and retrieval system that 
fetches real-time weather information for specified cities using the OpenWeatherMap API. 
The project enables storage of weather data in JSON format, allowing users to access both 
current weather conditions and historical records. Additionally, the system provides 
functionality to search and display past weather reports by city, date, or date range, 
facilitating easy access to comprehensive weather information.
