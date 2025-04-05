
library(ggplot2)
library(scales)
chicago <- read.csv("C:/Users/roger/OneDrive/Desktop/bike_study_case/Analysis report/chicago_weather_trips_csv.csv")

###

ggplot(data = chicago, aes(x = avg_temp, y = trips)) + 
  geom_point(color = "blue", size = 2, alpha = 0.7) +  
  geom_smooth(method = "lm", color = "deepskyblue", se = FALSE) +  
  scale_y_continuous(labels = scales::comma) +  # Ensure 'scales::comma' is properly used
  labs(title = "Relationship Between Temperature and Bike Trips",
       x = "Average Temperature (°C)",
       y = "Number of Trips") + 
  theme_minimal()