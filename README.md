# SQL ANALYSIS

# INTRODUCTION
Zomato, a leading restaurant aggregator and food delivery platform, hosts a vast database of restaurants across various cities. However, merely listing restaurants does not guarantee high customer engagement, successful online orders or satisfactory dining experiences. Understanding key business metrics such as online delivery adoption, table booking trends, customer ratings, and voting patterns is crucial for improving platform performance, restaurant recommendations, and overall user experience.

# Objective
This project aims to generate data-driven insights from Zomato’s restaurant dataset by analyzing critical factors affecting restaurant performance, consumer engagement and service adoption. Specifically :

**IF METROPOLITAN CITIES ARE PERFORMING BETTER THAN THE TIER 2 AND TIER 3 CITIES?**

**What are the factors that are contributing to Metropolitan cities success ACROSS CITIES?**

**DOES HIGHER RATING = MORE VOTES ?**

**Compare the total number of restaurants in each category → Are there just more poor-rated restaurants, leading to higher vote counts?**

**Which cities and localities exhibit high online delivery adoption?**

**Are cities with high online delivery usage also high in table bookings?**

**Which localities have a high number of restaurants but low engagement (low votes, low ratings)?**

**Which cities have the highest number of low-rated restaurants, and what are the potential contributing factors?**

**What are the top-performing localities in each city based on high customer engagement (votes & ratings)?**

**What are the top 5 localities in each city where there is high user engagement and the rating_text is good,very good and excellent?**


# Data Cleaning Process
Before conducting analysis, extensive data cleaning was performed on the Zomato dataset to ensure accuracy and consistency. The following key steps were taken:

**Duplicate Removal**
Identified and removed duplicate restaurant entries based on Restaurant_ID to prevent redundancy in analysis.
Eliminated rows with Country_Code values outside of India and UAE to focus on relevant regions.
Dropped the unnecessary INDEX column to optimize storage and performance.

**Data Type Standardization**

Checked and adjusted column data types for consistency, such as increasing VARCHAR length for Rank_Class to accommodate diverse labels.
Adding New Features

**Categorization for Insights**

Classified restaurants into Very Good, Average, and Poor based on Aggregate_Rating.
Segmented Indian cities into Metropolitan, Tier 2, and Tier 3 categories for comparative analysis.
By ensuring clean, structured, and standardized data, we laid a strong foundation for meaningful analysis and insights generation.

# Expected Insights & Applications
**City-wise and locality-wise segmentation to understand customer behavior and service preferences.**
**Identification of areas with low engagement, allowing Zomato to implement targeted marketing campaigns.**
**Data-driven restaurant recommendations based on consumer feedback, leading to better dining experiences.**
**Strategic insights for expansion and partnerships in emerging markets with high engagement potential.**

